/// 誰が自機を操作しているか（FR-19・ADR 0013）。決めるのは合成ルートで、Render は HUD に出すだけ。
///
/// 移植元: NeNe Bolt `Sources/NeNeBoltRender/PilotLabel.swift`（コミット 072d08a）。AI の名前と顔は `ScreenState.persona` から出すので持たない。
public enum PilotLabel: Sendable, Hashable {
    /// AI のパイロット（`ScreenState.persona`）。
    case autopilot
    /// 人。AI に戻るまでの残りの秒。
    case player(secondsLeft: Int)
}
