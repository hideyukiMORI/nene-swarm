/// トーチカ 1 つ（FR-02a）。3 セル × 2 段のアーチで、当たったセルが 1 つずつ欠ける。
///
/// 欠けたセルは同じステージの中では戻らず、弾は欠けたセルを素通りする。ステージの始まりで元の形に戻る。
public struct Shield: Sendable, Hashable {
    /// 幅（セル）。
    public static let columns = 3
    /// 高さ（セル）。
    public static let rows = 2
    /// 上端のセルの段。
    public static let topRow = 14
    /// 4 つのトーチカの左端のセルの列（盤面の中心に対して左右対称）。
    public static let leftColumns = [2, 8, 15, 21]
    /// 元の形（上の段は 3 セル、下の段は両端だけ）。ビットの番号は 段 × 3 ＋ 列。
    static let pristine = 0b101_111

    /// 左端のセルの列。
    public let leftColumn: Int
    /// 残っているセルのビット。
    public internal(set) var cells: Int

    init(leftColumn: Int) {
        self.leftColumn = leftColumn
        cells = Shield.pristine
    }

    /// 4 つのトーチカを元の形で並べる。
    static func row() -> [Shield] {
        leftColumns.map { Shield(leftColumn: $0) }
    }

    /// セル（トーチカの中の列と段）が残っているか。
    public func isStanding(column: Int, row: Int) -> Bool {
        cells & (1 << (row * Shield.columns + column)) != 0
    }

    /// 残っているセルの数。
    public var standingCount: Int { cells.nonzeroBitCount }

    /// 残っているセルのうち、箱と重なる最初のもの（上の段・左の列から）。
    func firstStanding(overlapping box: Box) -> ShieldCell? {
        for row in 0..<Shield.rows {
            for column in 0..<Shield.columns where isStanding(column: column, row: row) {
                let cell = ShieldCell(column: column, row: row)
                if box.overlaps(cell.box(in: self)) {
                    return cell
                }
            }
        }
        return nil
    }

    /// セルを 1 つ欠く。
    mutating func chip(_ cell: ShieldCell) {
        cells &= ~(1 << (cell.row * Shield.columns + cell.column))
    }
}
