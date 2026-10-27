/// 捕虜の状態（FR-02b）。捕まった自機は、捕まえた親玉の 1 段上に、半機ぶん右へずれて並ぶ（`Game.captiveHull`）。
public enum Captive: Sendable, Hashable {
    /// 捕虜はいない。
    case none
    /// 番号の親玉に捕まっている。
    case held(byEnemy: Int)
}
