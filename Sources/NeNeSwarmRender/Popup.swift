import NeNeSwarmCore

/// 倒した場所に浮かぶ得点（FR-02f）。
struct Popup: Sendable, Hashable {
    let text: String
    let point: Point
    /// 出た刻み（`Effects` の時計）。
    let born: Int
}
