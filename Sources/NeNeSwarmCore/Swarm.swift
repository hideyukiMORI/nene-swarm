/// 隊列の行進の状態（FR-02 a）。左右に行進し、端に着くたびに 1 段下がる。敵が減るほど速くなる。
///
/// 席の位置は `origin` と席の列・段だけで決まり、隊列にいる敵はいつもその位置にいる。
public struct Swarm: Sendable, Hashable {
    /// 隊列の列の数。
    public static let columns = 6
    /// 隊列の段の数。
    public static let rows = 4
    /// 席の横の間隔（3 セル）。
    public static let pitchX = 3 * Field.cellUnits
    /// 席の縦の間隔（2 セル）。
    public static let pitchY = 2 * Field.cellUnits
    /// 1 歩の横の量（半セル）。
    public static let stride = Field.cellUnits / 2
    /// 端で下がる量（1 セル）。
    public static let drop = Field.cellUnits
    /// 始まりの左上（盤面の真ん中・上から 2 段目のセル）。
    static let startOrigin = Point(x: (Field.width - (columns - 1) * pitchX - Enemy.width) / 2, y: Field.units(2))

    /// 席 (0, 0) の左上。
    public internal(set) var origin: Point
    /// 行進の向き。
    public internal(set) var heading: MarchHeading
    /// 次の 1 歩までの刻みの数。
    public internal(set) var countdown: Int

    init() {
        origin = Swarm.startOrigin
        heading = .right
        countdown = 1
    }

    /// 席の左上の位置。
    public func home(of slot: Slot) -> Point {
        Point(x: origin.x + slot.column * Swarm.pitchX, y: origin.y + slot.row * Swarm.pitchY)
    }

    /// 戦うステージの始まりの敵の並び（上の段に親玉 4、次に護衛 6、下 2 段に雑魚 12）。
    func roster() -> [Enemy] {
        var enemies: [Enemy] = []
        for row in 0..<Swarm.rows {
            for column in 0..<Swarm.columns where row > 0 || (1...4).contains(column) {
                let slot = Slot(column: column, row: row)
                let kind = Swarm.kind(ofRow: row)
                enemies.append(Enemy(id: enemies.count, kind: kind, slot: slot, position: home(of: slot)))
            }
        }
        return enemies
    }

    private static func kind(ofRow row: Int) -> EnemyKind {
        if row == 0 {
            return .flagship
        }
        return row == 1 ? .escort : .drone
    }
}
