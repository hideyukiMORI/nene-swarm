/// パイロットが話すきっかけ（FR-15・ADR 0009）。
public enum Cue: Sendable, Hashable, CaseIterable {
    /// TITLE で次の出番を待っている。
    case title
    /// ステージが始まった。
    case stageStart
    /// ステージを終えた。
    case stageClear
    /// 短い間に続けて倒した。
    case streak
    /// UFO・PERFECT・飛んでいる親玉の大きな得点。
    case bigScore
    /// 敵の弾が紙一重でかすめた。
    case nearMiss
    /// 自機（か 2 機並びの片方）を失った。
    case hit
    /// 残りが 1 機になった。
    case lastShip
    /// 捕獲ビームに捕まった。
    case captured
    /// 捕虜を救出した。
    case rescued
    /// ゲームが終わった。
    case gameOver
    /// ハイスコアの 1 位になった。
    case newRecord

    /// 言う確率（百分率）。100 は必ず言う。
    var chance: Int {
        switch self {
        case .title, .hit, .lastShip, .captured, .rescued, .gameOver, .newRecord: 100
        case .bigScore: 80
        case .stageStart: 70
        case .stageClear: 60
        case .streak: 50
        case .nearMiss: 35
        }
    }

    /// 前の発言から間を置かずに言えるか（必ず言う出来事だけ）。
    var interrupts: Bool { chance == 100 }

    /// 同じ刻みに複数あるときの優先度（大きいほど先）。
    var priority: Int {
        switch self {
        case .newRecord: 12
        case .gameOver: 11
        case .captured: 10
        case .rescued: 9
        case .lastShip: 8
        case .hit: 7
        case .bigScore: 6
        case .stageClear: 5
        case .stageStart: 4
        case .streak: 3
        case .nearMiss: 2
        case .title: 1
        }
    }
}
