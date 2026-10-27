/// 台本の 1 行（どのきっかけで言うか・何と言うか）。移植元: NeNe Igo `Sources/NeNeIgoEngine/ScriptLine.swift`（コミット 3bdae35。元は NeNe Gambit）。
struct ScriptLine: Sendable, Hashable {
    let cue: Cue
    let text: String

    init(_ cue: Cue, _ text: String) {
        self.cue = cue
        self.text = text
    }
}
