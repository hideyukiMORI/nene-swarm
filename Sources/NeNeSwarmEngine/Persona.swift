import NeNeSwarmCore

/// パイロットの性格（FR-04・FR-15・Q6・ADR 0008）。避け方・狙い方・迷い・わざと捕まりに行くかを数で持つ。
///
/// 名前は `ファイル名.拡張子` 風で、兄弟のキャスト（Gambit・Reversi・Igo・Poker）と重ならない。
public struct Persona: Sendable, Hashable {
    /// 画面に出す名前。
    public let name: String
    /// 顔（ASCII）。
    public let face: String
    /// 弾と体当たりを何刻み先まで見て避けるか。長いほど慎重。
    let foresight: Int
    /// 1 刻みに危険を見落とす確率（千分率）。
    let blindness: Int
    /// 狙いのずれ（単位）。
    let jitter: Int
    /// 撃つときに狙いがどれだけ合っていればよいか（単位）。
    let aimTolerance: Int
    /// 捕獲ビームへわざと入りに行くか（2 機並びを狙う）。
    let seeksCapture: Bool
    /// UFO を優先して狙うか。
    let chasesSaucer: Bool
    /// トーチカの下に隠れたがるか。
    let hugsShields: Bool
    /// 台本（1 人 50 本・FR-15）。
    let script: [ScriptLine]

    /// きっかけのセリフ。
    func lines(for cue: Cue) -> [String] {
        script.filter { $0.cue == cue }.map(\.text)
    }

    /// 4 名（毎ゲーム 1 名が乗る）。
    public static let roster: [Persona] = [blaster, nervous, lucky, sniper]

    /// 撃ちまくり。慎重さは最低で、2 機並びが欲しくてビームに自分から入る。
    public static let blaster = Persona(
        name: "BLASTER.BIN", face: "(>_<)", foresight: 10, blindness: 40, jitter: 10, aimTolerance: 16,
        seeksCapture: true, chasesSaucer: false, hugsShields: false, script: blasterScript)
    /// 心配性。遠くの弾まで見て逃げ、トーチカの下に隠れる。撃つのは控えめ。
    public static let nervous = Persona(
        name: "NERVOUS.TMP", face: "(;_;)", foresight: 28, blindness: 25, jitter: 6, aimTolerance: 6,
        seeksCapture: false, chasesSaucer: false, hugsShields: true, script: nervousScript)
    /// 博打打ち。迷いが多く、UFO を追いかけ、ビームにもときどき入る。
    public static let lucky = Persona(
        name: "LUCKY.INI", face: "(^o^)", foresight: 16, blindness: 70, jitter: 14, aimTolerance: 12,
        seeksCapture: true, chasesSaucer: true, hugsShields: false, script: luckyScript)
    /// 狙撃手。先を読んで撃ち、狙いが合うまで撃たない。ビームは避ける。
    public static let sniper = Persona(
        name: "SNIPER.ISO", face: "(-_-)", foresight: 20, blindness: 30, jitter: 2, aimTolerance: 4,
        seeksCapture: false, chasesSaucer: true, hugsShields: false, script: sniperScript)
}
