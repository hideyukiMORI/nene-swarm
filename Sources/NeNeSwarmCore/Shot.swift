/// 弾 1 発。自機の弾は上へ、敵の弾は下へ進む。
public struct Shot: Sendable, Hashable {
    /// 当たり判定の幅。
    public static let width = 4
    /// 当たり判定の高さ。
    public static let height = 8

    /// 左上の位置。
    public internal(set) var position: Point
    /// 1 刻みに進む量。
    public let velocity: Velocity

    init(position: Point, velocity: Velocity) {
        self.position = position
        self.velocity = velocity
    }

    /// 当たり判定の箱。
    public var box: Box {
        Box(origin: position, width: Shot.width, height: Shot.height)
    }
}
