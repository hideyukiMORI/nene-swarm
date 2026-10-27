/// パイロットが 1 刻みに Core へ返せる唯一のもの（ADR 0005）。左右と引き金の組。
///
/// パイロットは Core の状態を読んでこれを返すだけで、状態を書き換えない（ARC-004）。
public struct PilotInput: Sendable, Hashable {
    /// 左右。
    public let steer: Steer
    /// 引き金。
    public let trigger: Trigger

    /// 入力を作る。
    public init(steer: Steer, trigger: Trigger) {
        self.steer = steer
        self.trigger = trigger
    }

    /// 何もしない入力。
    public static let idle = PilotInput(steer: .hold, trigger: .hold)
}
