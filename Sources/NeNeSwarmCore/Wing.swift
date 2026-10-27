/// 自機の編成（FR-02b）。2 機並びは弾が 2 発ずつ・当たり判定も 2 機分で、片方に当たったら片方だけ失う。
public enum Wing: Sendable, Hashable {
    case single
    case dual

    /// 並んでいる機体の数。
    public var count: Int {
        switch self {
        case .single: 1
        case .dual: 2
        }
    }
}
