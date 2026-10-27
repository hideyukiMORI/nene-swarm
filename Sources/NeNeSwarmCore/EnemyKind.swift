/// 敵の種類（ADR 0005）。加点の表の持ち主。
public enum EnemyKind: Sendable, Hashable, CaseIterable {
    /// 隊列の下 2 段の雑魚。
    case drone
    /// 隊列の 2 段目の護衛。
    case escort
    /// 2 発で倒れる親玉。捕獲ビームを出す（FR-02b）。
    case flagship

    /// 倒れるまでに要る弾の数。
    public var toughness: Int {
        switch self {
        case .drone, .escort: 1
        case .flagship: 2
        }
    }

    /// 倒したときの得点（隊列の中にいるか、飛んでいるか）。
    public func points(for posture: Posture) -> Int {
        switch (self, posture) {
        case (.drone, .inSwarm): 50
        case (.drone, .flying): 100
        case (.escort, .inSwarm): 80
        case (.escort, .flying): 160
        case (.flagship, .inSwarm): 150
        case (.flagship, .flying): 400
        }
    }
}
