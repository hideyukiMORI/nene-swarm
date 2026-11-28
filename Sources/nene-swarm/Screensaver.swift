import NeNeSwarmCore
import NeNeSwarmEngine
import NeNeSwarmRender
import NeNeSwarmTerminal

/// 場面の列を一定の刻みで回す 1 本のループ（ADR 0007）。状態はすべてこの値の中にあり、ループの外へ出ない（ARC-005）。
///
/// 時計を読むのはここだけ。Core は刻みの数しか知らないので、同じシードならキーを押さない限り刻みの速さによらず同じゲームになる。
/// 移植元: NeNe Igo `Sources/nene-igo/Screensaver.swift`（コミット 3bdae35）。1 手ごとの締め切りを、決まった間隔の刻みに替えた。
/// パイロットは TITLE に入るたびに 4 名から乱数で選び、次のゲームに乗せる（Q4・ADR 0008）。
///
/// 人と AI は同じ `PilotInput` を同じ `Session.step` に渡す（FR-19・ADR 0013）。誰が操作するかは `Helm` が刻みの数で決める。
/// 遊びのキーに一度も触れなければ、乱数の引き方も画面も人の操作を入れる前と同じになる（ブラウザ版が全コマ突き合わせている）。
struct Screensaver {
    /// 描くのが遅れたときに追いつく刻みの上限（それ以上は捨てて、いまから数え直す）。
    private static let maxCatchUp = 4
    /// 人が 1 度でも操作したゲームのハイスコアの名前（FR-19。NeNe Bolt の FR-02g と同じ）。
    private static let playerName = "PLAYER"

    private let options: LaunchOptions
    private let seed: UInt64
    private let clock = ContinuousClock()
    private let started: ContinuousClock.Instant
    private var generator: SplitMix64
    private var pilotGenerator: SplitMix64
    private var persona: Persona
    private var pilot: Pilot
    private var banter = Banter()
    private var effects = Effects()
    private var banterGenerator: SplitMix64
    private var controls = Controls()
    private var helm: Helm
    private var humanPlayedThisGame = false
    private var session: Session
    private var display: DisplayOptions
    private var difficulty: Difficulty
    private var highScores = HighScoreTable.empty
    private var storage = ScoreStorage.memoryOnly
    private var previous: Grid?

    init(options: LaunchOptions, display: DisplayOptions, seed: UInt64) {
        self.options = options
        self.display = display
        self.seed = seed
        started = clock.now
        helm = Helm(handBack: options.handBackTicks)
        difficulty = options.difficulty
        generator = SplitMix64(seed: seed)
        pilotGenerator = SplitMix64(seed: seed ^ 0x5357_4152_4D21)
        session = Session(durations: options.durations)
        banterGenerator = SplitMix64(seed: seed ^ 0x4241_4E54_4552)
        switch ScoreStore.load() {
        case .loaded(let table):
            highScores = table
            storage = .file
        case .memoryOnly:
            storage = .memoryOnly
        }
        persona = Persona.roster.randomElement(using: &pilotGenerator) ?? Persona.blaster
        pilot = Pilot(persona: persona)
    }

    /// `q` か終了のシグナルが来るまで回す。
    mutating func run() {
        var next = clock.now + options.tickInterval
        draw()
        while true {
            let bytes = Console.waitForInput(milliseconds: milliseconds(until: next))
            let commands = controls.receive(bytes, at: now)
            let signals = Console.takeSignals()
            if signals.interrupted || commands.contains(.quit) {
                return
            }
            apply(commands)
            if signals.resized {
                previous = nil
            }
            var steps = 0
            while clock.now >= next, steps < Self.maxCatchUp {
                tick()
                next += options.tickInterval
                steps += 1
            }
            if clock.now >= next {
                next = clock.now + options.tickInterval
            }
            draw()
        }
    }

    private mutating func apply(_ commands: [Controls.Command]) {
        for command in commands {
            switch command {
            case .quit:
                return
            case .cycleTheme:
                display = display.cyclingTheme
            case .cycleDifficulty:
                difficulty = difficulty.next
            }
        }
    }

    /// 1 刻み進める。PLAY の間だけ、人か AI のどちらかが入力を決める。出来事はハイスコアとセリフに渡す。
    ///
    /// 人の番の間はパイロットを呼ばない（パイロットの乱数を引かない）。人が触れなければ、前と同じ順に同じ乱数を引く。
    private mutating func tick() {
        let human = controls.take(at: now)
        helm.advance(touched: human != nil)
        var input = PilotInput.idle
        if case .play(let game) = session.scene {
            if helm.isHuman {
                input = human ?? .idle
                humanPlayedThisGame = true
            } else {
                input = pilot.input(for: game, difficulty: difficulty, using: &pilotGenerator)
            }
        }
        let step = session.step(input, difficulty: difficulty, using: &generator)
        var newRecord = false
        for event in step.events {
            newRecord = record(event) || newRecord
        }
        session = step.session
        var ships: Int?
        if case .play(let game) = session.scene {
            ships = game.shipsInPlay
        }
        let hearing = Hearing(events: step.events, shipsInPlay: ships, newRecord: newRecord)
        banter.listen(hearing, persona: persona, using: &banterGenerator)
        effects.absorb(step.events)
    }

    /// 出来事を 1 つ反映する。ハイスコアの 1 位になったら true。
    private mutating func record(_ event: SessionEvent) -> Bool {
        switch event {
        case .gameStarted:
            pilot = Pilot(persona: persona)
            humanPlayedThisGame = false
        case .gameEnded(let summary):
            let name = humanPlayedThisGame ? Self.playerName : persona.name
            let entry = HighScore(
                score: summary.score, pilot: name, stage: summary.stage.number, difficulty: summary.difficulty)
            let insertion = highScores.inserting(entry)
            highScores = insertion.table
            if case .file = storage, !ScoreStore.save(highScores) {
                storage = .memoryOnly
            }
            return summary.score > 0 && insertion.rank == .ranked(1)
        case .titleShown:
            // 次のゲームのパイロットは TITLE に入ったときに決め、TITLE に出す（セリフは次のパイロットが言う）
            persona = Persona.roster.randomElement(using: &pilotGenerator) ?? Persona.blaster
        case .game:
            break
        }
        return false
    }

    /// いまの状態を描き、前のフレームとの差分だけを 1 回で書く。
    private mutating func draw() {
        let label: PilotLabel = helm.isHuman ? .player(secondsLeft: options.seconds(ticks: helm.ticksLeft)) : .autopilot
        let state = ScreenState(
            session: session, display: display, difficulty: difficulty, seed: seed, highScores: highScores,
            persona: persona, pilot: label, remarks: banter.lines, effects: effects, storage: storage)
        let grid = ScreenRenderer.render(state, size: Console.size())
        Console.write(FrameEncoder.encode(grid, previous: previous, colors: display.traits.colors))
        previous = grid
    }

    /// 起動からのミリ秒（`HeldKeys` が押しっぱなしを推し量るのに使う）。
    private var now: Int {
        let (seconds, attoseconds) = (clock.now - started).components
        return Int(seconds * 1000 + attoseconds / 1_000_000_000_000_000)
    }

    /// 締め切りまでのミリ秒（過ぎていれば 0）。
    private func milliseconds(until instant: ContinuousClock.Instant) -> Int32 {
        let (seconds, attoseconds) = (instant - clock.now).components
        let total = seconds * 1000 + attoseconds / 1_000_000_000_000_000
        return Int32(clamping: max(total, 0))
    }
}
