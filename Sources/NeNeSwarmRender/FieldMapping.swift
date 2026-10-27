import NeNeSwarmCore

/// Core の座標（単位）を端末の桁と行に直す唯一の経路（ADR 0007）。1 セル＝端末の 2 桁 × 1 行で、横は半セル（8 単位）まで描き分ける。
enum FieldMapping {
    /// 端末の 1 桁の単位数。
    static let unitsPerColumn = Field.cellUnits / 2
    /// 盤面の幅（端末の桁）。
    static let columns = Field.columns * 2
    /// 盤面の高さ（端末の行）。
    static let rows = Field.rows

    /// 横の位置の桁（盤面の左端が 0。負の無限大へ丸める）。
    static func column(_ x: Int) -> Int {
        x >> (Field.cellShift - 1)
    }

    /// 縦の位置（箱の真ん中）の行（盤面の上端が 0）。
    static func row(top y: Int, height: Int) -> Int {
        Field.cell(y + height / 2)
    }
}
