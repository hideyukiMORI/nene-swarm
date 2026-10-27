import NeNeSwarmCore

/// 画面の演出の状態（FR-02f・ADR 0010）。出来事から作る見た目だけの値で、ゲームの状態（Core）には入れない（ADR 0004）。
///
/// 合成ルートが刻みごとに出来事を渡して進め、Render が描く。持ち主は合成ルート（ARC-005）。
public struct Effects: Sendable, Hashable {
    /// 得点が浮かんでいる刻みの数。
    static let popupTicks = 30
    /// 得点を浮かべる最小の点数（隊列の雑魚と護衛は数が多いので出さない）。
    static let popupMinimum = 150
    /// 画面が光る刻みの数。
    static let flashTicks = 4
    /// PERFECT と TWIN WING の帯を出す刻みの数。
    static let bannerTicks = 60

    /// 演出の時計（刻みごとに 1 進む。星と点滅もこれで動く）。
    public private(set) var clock = 0
    private(set) var popups: [Popup] = []
    private(set) var flashUntil = 0
    private(set) var perfectUntil = 0
    private(set) var twinUntil = 0

    /// 何も起きていない状態。
    public init() {}

    /// 1 刻みの出来事を取り込む。
    public mutating func absorb(_ events: [SessionEvent]) {
        clock += 1
        popups.removeAll { clock - $0.born >= Effects.popupTicks }
        for case .game(let event) in events {
            absorb(event)
        }
    }

    private mutating func absorb(_ event: GameEvent) {
        switch event {
        case .enemyDestroyed(_, let points, let at):
            if points >= Effects.popupMinimum {
                popups.append(Popup(text: String(points), point: at, born: clock))
            }
            if points >= 400 {
                flashUntil = clock + Effects.flashTicks
            }
        case .saucerDestroyed(let points, let at):
            popups.append(Popup(text: String(points), point: at, born: clock))
            flashUntil = clock + Effects.flashTicks
        case .perfect:
            perfectUntil = clock + Effects.bannerTicks
            flashUntil = clock + Effects.flashTicks
        case .captiveRescued(.joined):
            twinUntil = clock + Effects.bannerTicks
        case .stageStarted, .stageCleared, .flagshipDamaged, .shipDestroyed, .wingLost, .shipCaptured, .shipRespawned,
            .captiveRescued(.reserved), .captiveLost, .captiveShot, .nearMiss, .gameOver:
            break
        }
    }

    /// 画面が光っているか。
    var isFlashing: Bool { clock < flashUntil }
    /// PERFECT の帯を出しているか。
    var showsPerfect: Bool { clock < perfectUntil }
    /// TWIN WING の帯と自機の光りを出しているか。
    var showsTwin: Bool { clock < twinUntil }
}
