/// 1 ゲームの状態（ADR 0005）。ゲームを進めるのは `step` の 1 経路だけで、秒を知らない（ARC-007）。
///
/// 外からは読むだけ。パイロットはこれを読んで `PilotInput` を返し、状態を書き換えない（ARC-004）。
/// 「当たったか」「ステージを終えたか」「ゲームが終わったか」の判定は、どれもこの型の中に 1 つずつある（ARC-001）。
public struct Game: Sendable, Hashable {
    /// 刻みの数の上限（30 刻み／秒で 20 分）。届いたら `.timeLimit` で終わる。
    public static let tickLimit = 36_000
    /// 始まりの残機（画面の 1 機を除く）。
    public static let startingReserve = 2
    static let introTicks = 60
    static let clearedTicks = 90
    static let respawnTicks = 60
    static let explosionTicks = 12

    /// いまのステージ。
    public internal(set) var stage: Stage
    /// ステージの中の段階。
    public internal(set) var phase: PlayPhase
    /// 続いているか。
    public internal(set) var status: GameStatus
    /// 画面の自機。
    public internal(set) var ship: ShipPresence
    /// 残機（画面の自機を除く）。
    public internal(set) var reserve: Int
    /// スコア。減らない。
    public internal(set) var score: Int
    /// 敵（爆発中を含む）。
    public internal(set) var enemies: [Enemy]
    /// 隊列の行進。
    public internal(set) var swarm: Swarm
    /// 自機の弾。
    public internal(set) var playerShots: [Shot]
    /// 敵の弾。
    public internal(set) var enemyShots: [Shot]
    /// トーチカ（ボーナスステージでも並ぶ）。
    public internal(set) var shields: [Shield]
    /// UFO。
    public internal(set) var saucer: SaucerState
    /// 捕虜。
    public internal(set) var captive: Captive
    /// ボーナスステージの進み具合。
    public internal(set) var bonus: BonusProgress
    /// 始まってからの刻みの数。
    public internal(set) var tick: Int

    /// ステージ 1 の始まりのゲームを作る。
    public init() {
        stage = Stage(number: 1)
        phase = .intro(ticksLeft: Game.introTicks)
        status = .running
        ship = .active(Ship.centered())
        reserve = Game.startingReserve
        score = 0
        swarm = Swarm()
        enemies = swarm.roster()
        playerShots = []
        enemyShots = []
        shields = Shield.row()
        saucer = .absent(ticksLeft: Game.saucerInterval)
        captive = .none
        bonus = BonusProgress()
        tick = 0
    }

    /// 1 刻み進める。乱数は引数の乱数源からだけ引く（ARC-007）。終わったゲームは変わらない。
    public func step(
        _ input: PilotInput, difficulty: Difficulty, using generator: inout some RandomNumberGenerator
    ) -> GameStep {
        var next = self
        var events: [GameEvent] = []
        if case .running = status {
            next.advance(
                input, tuning: Tuning.make(difficulty: difficulty, stage: stage.number),
                using: &generator, events: &events)
        }
        return GameStep(game: next, events: events)
    }

    /// 残機・画面の自機・捕虜を合わせた自機の数（REQUIREMENTS 第 3 節の数の保存）。
    public var shipsInPlay: Int {
        let onField: Int
        switch ship {
        case .active(let current): onField = current.wing.count
        case .respawning: onField = 1
        case .lost: onField = 0
        }
        switch captive {
        case .none: return reserve + onField
        case .held: return reserve + onField + 1
        }
    }
}
