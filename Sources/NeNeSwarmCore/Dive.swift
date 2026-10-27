/// 急降下の途中の状態。
public struct Dive: Sendable, Hashable {
    /// 目的。
    public let purpose: DivePurpose
    /// いまの速さ。
    public let velocity: Velocity
    /// 急降下を始めてからの刻みの数。
    public let elapsed: Int

    /// 急降下の状態を作る。
    public init(purpose: DivePurpose, velocity: Velocity, elapsed: Int) {
        self.purpose = purpose
        self.velocity = velocity
        self.elapsed = elapsed
    }
}
