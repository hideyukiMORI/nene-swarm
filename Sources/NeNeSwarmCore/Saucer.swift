/// 画面の上端を横切るボーナスの敵（FR-02c）。得点は出たときに乱数で決まり、倒すまで画面には出さない。
public struct Saucer: Sendable, Hashable {
    /// 1 刻みに進む量。
    public static let speed = 3
    /// 出うる得点。
    public static let pointsTable = [300, 500, 800, 1000, 1500]

    /// 左端。
    public internal(set) var x: Int
    /// 進む向き（-1 か 1）。
    public let heading: Int
    /// 倒したときの得点。
    public let points: Int

    init(heading: Int, points: Int) {
        precondition(heading == -1 || heading == 1, "向きは -1 か 1")
        self.heading = heading
        self.points = points
        x = heading > 0 ? -Enemy.width : Field.width
    }

    /// 当たり判定の箱（一番上のセルの段）。
    public var box: Box {
        Box(origin: Point(x: x, y: 0), width: Enemy.width, height: Enemy.height)
    }
}
