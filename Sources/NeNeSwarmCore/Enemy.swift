/// 敵 1 機。外からは読むだけで、状態を変えるのは Core の 1 刻み関数だけ（ARC-004）。
public struct Enemy: Sendable, Hashable {
    /// 当たり判定の幅（2 セル）。
    public static let width = 2 * Field.cellUnits
    /// 当たり判定の高さ（1 セル）。
    public static let height = Field.cellUnits

    /// ステージの中で一意の番号。
    public let id: Int
    /// 種類。
    public let kind: EnemyKind
    /// 隊列の中の自分の席（ボーナスステージの敵は戻らないので使わない）。
    public let slot: Slot
    /// 左上の位置。
    public internal(set) var position: Point
    /// 状態。
    public internal(set) var motion: EnemyMotion
    /// 倒れるまでに要る弾の数。
    public internal(set) var hitsLeft: Int

    init(id: Int, kind: EnemyKind, slot: Slot, position: Point) {
        self.id = id
        self.kind = kind
        self.slot = slot
        self.position = position
        motion = .inSwarm
        hitsLeft = kind.toughness
    }

    /// 当たり判定の箱。
    public var box: Box {
        Box(origin: position, width: Enemy.width, height: Enemy.height)
    }
}
