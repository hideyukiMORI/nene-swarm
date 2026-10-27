/// 画面にいる自機（2 機並びなら左の機体の位置で持つ）。
public struct Ship: Sendable, Hashable {
    /// 1 機の当たり判定の幅（2 セル）。
    public static let width = 2 * Field.cellUnits
    /// 1 機の当たり判定の高さ（1 セル）。
    public static let height = Field.cellUnits
    /// 自機の上端（下から 2 段目のセル）。
    public static let top = Field.units(Field.rows - 2)
    /// 1 刻みに動ける量。
    public static let speed = 4
    /// 撃ってから次に撃てるまでの刻みの数。
    public static let reload = 8
    /// 1 機あたり画面に同時に出せる弾の数。
    public static let shotsPerHull = 2

    /// 左の機体の左端。
    public internal(set) var x: Int
    /// 編成。
    public internal(set) var wing: Wing
    /// 次に撃てるまでの刻みの数。
    public internal(set) var cooldown: Int

    init(x: Int, wing: Wing) {
        self.x = x
        self.wing = wing
        cooldown = 0
    }

    /// 盤面の真ん中に出す 1 機。
    static func centered() -> Ship {
        Ship(x: (Field.width - width) / 2, wing: .single)
    }

    /// 編成全体の幅。
    public var span: Int { Ship.width * wing.count }

    /// 機体ごとの当たり判定の箱（左から）。
    public var hulls: [Box] {
        (0..<wing.count).map { index in
            Box(origin: Point(x: x + index * Ship.width, y: Ship.top), width: Ship.width, height: Ship.height)
        }
    }

    /// 左右に動ける範囲の右端（左の機体の左端の最大）。
    public var maxX: Int { Field.width - span }
}
