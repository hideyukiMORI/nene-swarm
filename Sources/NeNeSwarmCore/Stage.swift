/// ステージ（1 から）。3 ステージごとにボーナスステージを挟む（FR-02d）。
public struct Stage: Sendable, Hashable {
    /// 番号。
    public let number: Int

    /// 番号からステージを作る。
    public init(number: Int) {
        precondition(number >= 1, "ステージは 1 から")
        self.number = number
    }

    /// 種類（3 の倍数がボーナス）。
    public var kind: StageKind {
        number % 3 == 0 ? .bonus : .combat
    }

    /// 次のステージ。
    public var next: Stage { Stage(number: number + 1) }
}
