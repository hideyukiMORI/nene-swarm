/// 自機が画面にいるか。
public enum ShipPresence: Sendable, Hashable {
    /// 画面にいる。
    case active(Ship)
    /// 失ったあと、次の 1 機が出るまでの残りの刻み。
    case respawning(ticksLeft: Int)
    /// 残機が尽きた。
    case lost
}
