/// 得点を決める、敵の居方（隊列の中か、隊列の外を飛んでいるか）。
public enum Posture: Sendable, Hashable {
    case inSwarm
    case flying
}
