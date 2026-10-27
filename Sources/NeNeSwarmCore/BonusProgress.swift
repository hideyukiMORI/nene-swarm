/// ボーナスステージの進み具合（FR-02d）。4 つの波で 5 機ずつ、合わせて 20 機が通り抜ける。
public struct BonusProgress: Sendable, Hashable {
    /// 波の数。
    public static let waves = 4
    /// 1 つの波の機数。
    public static let perWave = 5
    /// 通り抜ける機数の合計。
    public static let total = waves * perWave
    /// 1 機倒すごとの得点。
    public static let pointsPerHit = 100
    /// 全部倒したときのボーナス。
    public static let perfectBonus = 10_000

    /// 出した機数。
    public internal(set) var spawned: Int
    /// 倒した機数。
    public internal(set) var hits: Int
    /// ステージの戦いが始まってからの刻みの数。
    public internal(set) var elapsed: Int

    init() {
        spawned = 0
        hits = 0
        elapsed = 0
    }
}
