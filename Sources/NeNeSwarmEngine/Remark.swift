/// パイロットの 1 回の発言。
public struct Remark: Sendable, Hashable {
    /// 話したパイロット。
    public let persona: Persona
    /// きっかけ。
    public let cue: Cue
    /// セリフ。
    public let text: String
}
