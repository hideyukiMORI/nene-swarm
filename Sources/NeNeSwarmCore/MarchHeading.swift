/// 隊列が行進する向き。
public enum MarchHeading: Sendable, Hashable {
    case left
    case right

    /// 1 歩の横の量（単位）。
    var step: Int {
        switch self {
        case .left: -Swarm.stride
        case .right: Swarm.stride
        }
    }

    /// 逆向き。
    var reversed: MarchHeading {
        switch self {
        case .left: .right
        case .right: .left
        }
    }
}
