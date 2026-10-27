/// 敵の状態（ADR 0005）。閉じた enum で、隊列にいる・急降下中・捕獲ビーム・戻り中・通り抜け・爆発中のどれか。
public enum EnemyMotion: Sendable, Hashable {
    /// 隊列の席にいる。
    case inSwarm
    /// 急降下中。
    case diving(Dive)
    /// 捕獲ビームを出している（残りの刻み）。
    case beaming(ticksLeft: Int)
    /// 画面の上から隊列の席へ戻る途中。
    case returning
    /// ボーナスステージで通り抜けている。
    case flyby(Flight)
    /// 爆発中（残りの刻み）。当たり判定は無い。
    case exploding(ticksLeft: Int)

    /// 得点を決める居方。爆発中は倒せないので呼ばない。
    public var posture: Posture {
        switch self {
        case .inSwarm, .exploding: .inSwarm
        case .diving, .beaming, .returning, .flyby: .flying
        }
    }

    /// 当たり判定があるか（爆発中だけ無い）。
    public var isSolid: Bool {
        switch self {
        case .exploding: false
        case .inSwarm, .diving, .beaming, .returning, .flyby: true
        }
    }

    /// 隊列の席にいるか。
    public var isInSwarm: Bool {
        switch self {
        case .inSwarm: true
        case .diving, .beaming, .returning, .flyby, .exploding: false
        }
    }
}
