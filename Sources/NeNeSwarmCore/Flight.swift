/// ボーナスステージの編隊の 1 機の飛び方（FR-02d）。撃たずに通り抜ける。
public struct Flight: Sendable, Hashable {
    /// いまの速さ。
    public let velocity: Velocity
    /// 飛び始めてからの刻みの数。
    public let elapsed: Int

    /// 飛び方を作る。
    public init(velocity: Velocity, elapsed: Int) {
        self.velocity = velocity
        self.elapsed = elapsed
    }
}
