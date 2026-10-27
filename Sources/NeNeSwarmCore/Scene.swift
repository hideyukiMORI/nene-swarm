/// 場面（FR-03）。TITLE → PLAY → GAME OVER → TITLE の順にだけ巡る。
public enum Scene: Sendable, Hashable {
    /// 題・次のパイロット・難易度・キーのヘルプ（残りの刻み）。
    case title(ticksLeft: Int)
    /// 遊んでいる。
    case play(Game)
    /// 終わったゲームのまとめを見せている（残りの刻み）。
    case gameOver(GameSummary, ticksLeft: Int)
}
