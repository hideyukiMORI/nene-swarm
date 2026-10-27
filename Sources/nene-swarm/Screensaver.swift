import NeNeSwarmCore
import NeNeSwarmEngine
import NeNeSwarmRender
import NeNeSwarmTerminal

/// 場面の列を一定の刻みで回す 1 本のループ（ADR 0007）。状態はすべてこの値の中にあり、ループの外へ出ない（ARC-005）。
///
/// 時計を読むのはここだけ。Core は刻みの数しか知らないので、同じシードならキーを押さない限り刻みの速さによらず同じゲームになる。
/// 移植元: NeNe Igo `Sources/nene-igo/Screensaver.swift`（コミット 3bdae35）。1 手ごとの締め切りを、決まった間隔の刻みに替えた。
struct Screensaver {
    /// 描くのが遅れたときに追いつく刻みの上限（それ以上は捨てて、いまから数え直す）。
    private static let maxCatchUp = 4

    private let options: LaunchOptions
    private let seed: UInt64
    private let clock = ContinuousClock()
    private var generator: SplitMix64
    private var pilotGenerator: SplitMix64
    private var pilot = WanderingPilot()
    private var session: Session
    private var display: DisplayOptions
    private var difficulty: Difficulty
    private var highScores = HighScoreTable.empty
    private var previous: Grid?

    init(options: LaunchOptions, display: DisplayOptions, seed: UInt64) {
        self.options = options
        self.display = display
        self.seed = seed
        difficulty = options.difficulty
        generator = SplitMix64(seed: seed)
        pilotGenerator = SplitMix64(seed: seed ^ 0x5357_4152_4D21)
        session = Session(durations: options.durations)
    }

    /// `q` か終了のシグナルが来るまで回す。
    mutating func run() {
        var next = clock.now + options.tickInterval
        draw()
        while true {
            let intents = KeyIntent.decode(Console.waitForInput(milliseconds: milliseconds(until: next)))
            let signals = Console.takeSignals()
            if signals.interrupted || intents.contains(.quit) {
                return
            }
            apply(intents)
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

    private mutating func apply(_ intents: [KeyIntent]) {
        for intent in intents {
            switch intent {
            case .quit:
                return
            case .cycleTheme:
                display = display.cyclingTheme
            case .cycleDifficulty:
                difficulty = difficulty.next
            }
        }
    }

    /// 1 刻み進める。PLAY の間だけパイロットが入力を決める。
    private mutating func tick() {
        var input = PilotInput.idle
        if case .play(let game) = session.scene {
            input = pilot.input(for: game, using: &pilotGenerator)
        }
        let step = session.step(input, difficulty: difficulty, using: &generator)
        for event in step.events {
            record(event)
        }
        session = step.session
    }

    private mutating func record(_ event: SessionEvent) {
        switch event {
        case .gameStarted:
            pilot = WanderingPilot()
        case .gameEnded(let summary):
            let entry = HighScore(
                score: summary.score, pilot: Self.pilotName, stage: summary.stage.number, difficulty: summary.difficulty
            )
            highScores = highScores.inserting(entry).table
        case .titleShown, .game:
            break
        }
    }

    /// 仮のパイロットの名前（キャストは Phase 3-4）。
    private static let pilotName = "AUTO"

    /// いまの状態を描き、前のフレームとの差分だけを 1 回で書く。
    private mutating func draw() {
        let state = ScreenState(
            session: session, display: display, difficulty: difficulty, seed: seed, highScores: highScores,
            pilot: Self.pilotName)
        let grid = ScreenRenderer.render(state, size: Console.size())
        Console.write(FrameEncoder.encode(grid, previous: previous, colors: display.traits.colors))
        previous = grid
    }

    /// 締め切りまでのミリ秒（過ぎていれば 0）。
    private func milliseconds(until instant: ContinuousClock.Instant) -> Int32 {
        let (seconds, attoseconds) = (instant - clock.now).components
        let total = seconds * 1000 + attoseconds / 1_000_000_000_000_000
        return Int32(clamping: max(total, 0))
    }
}
