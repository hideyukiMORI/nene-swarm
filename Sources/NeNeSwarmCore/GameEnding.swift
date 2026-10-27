/// ゲームの終わり方（FR-04・ADR 0005）。
public enum GameEnding: Sendable, Hashable {
    /// 残機が尽きた。
    case outOfShips
    /// 隊列が自機の段まで降りてきた。
    case invaded
    /// 刻みの数の上限に達した（安全のための上限。届いた割合は計測して ADR に書く）。
    case timeLimit
}
