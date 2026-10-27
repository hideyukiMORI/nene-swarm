/// トーチカの中の 1 セル（トーチカの中の列と段）。
struct ShieldCell: Sendable, Hashable {
    let column: Int
    let row: Int

    /// 盤面の上の当たり判定の箱。
    func box(in shield: Shield) -> Box {
        Box(
            origin: Point(x: Field.units(shield.leftColumn + column), y: Field.units(Shield.topRow + row)),
            width: Field.cellUnits,
            height: Field.cellUnits
        )
    }
}
