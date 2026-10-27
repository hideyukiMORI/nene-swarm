/// 1 ステージの中の段階。
public enum PlayPhase: Sendable, Hashable {
    /// ステージの始まりの帯を見せている（残りの刻み）。敵は動かない。
    case intro(ticksLeft: Int)
    /// 戦っている。
    case combat
    /// ステージを終えた帯を見せている（残りの刻み）。
    case cleared(ticksLeft: Int)
}
