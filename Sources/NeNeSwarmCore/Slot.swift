/// 隊列の中の席（列と段）。
public struct Slot: Sendable, Hashable {
    /// 列（0 から）。
    public let column: Int
    /// 段（0 が上）。
    public let row: Int

    /// 席を作る。
    public init(column: Int, row: Int) {
        self.column = column
        self.row = row
    }
}
