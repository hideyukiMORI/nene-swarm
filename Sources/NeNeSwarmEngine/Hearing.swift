import NeNeSwarmCore

/// 1 刻みにパイロットが聞いたこと（場面の出来事と、合成ルートだけが知る新記録）。
public struct Hearing: Sendable, Hashable {
    /// その刻みの出来事。
    public let events: [SessionEvent]
    /// 刻みのあとの自機の数（遊んでいなければ nil）。
    public let shipsInPlay: Int?
    /// そのゲームでハイスコアの 1 位になったか。
    public let newRecord: Bool

    /// 組を作る。
    public init(events: [SessionEvent], shipsInPlay: Int?, newRecord: Bool) {
        self.events = events
        self.shipsInPlay = shipsInPlay
        self.newRecord = newRecord
    }
}
