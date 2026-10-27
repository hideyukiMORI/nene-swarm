/// 自機を失った理由。
public enum HitCause: Sendable, Hashable {
    /// 敵の弾に当たった。
    case shot
    /// 急降下の敵とぶつかった。
    case rammed
}
