/// UFO が出ているか。
public enum SaucerState: Sendable, Hashable {
    /// 出ていない。次に出るまでの残りの刻み。
    case absent(ticksLeft: Int)
    /// 横切っている。
    case flying(Saucer)
}
