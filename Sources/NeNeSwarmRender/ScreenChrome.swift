/// 上端の題の帯と、下端のキーのヘルプ（FR-16: 常に出す）。
enum ScreenChrome {
    /// ` ▌NENE//SWARM  │  GAME 001  │  SEED 0x…  │  24BIT`
    static func header(_ state: ScreenState, glyphs: FrameGlyphs) -> [Segment] {
        let theme = state.display.theme
        let divider = Segment("  " + glyphs.vertical + "  ", theme.frame)
        return [
            Segment(" " + glyphs.marker + Wording.title, theme.accent), divider,
            Segment(Wording.game(state.gameNumber), theme.text), divider,
            Segment(Wording.seed(state.seed), theme.text), divider,
            Segment(Wording.colors(state.display.traits.colors), theme.dim),
        ]
    }

    /// `[q] QUIT  [t] THEME NEON  [d] DIFFICULTY NORMAL`
    static func footer(_ state: ScreenState) -> [Segment] {
        let theme = state.display.theme
        return [
            Segment(" " + Wording.quitKey, theme.accent), Segment(Wording.quitName, theme.dim),
            Segment(Wording.themeKey, theme.accent), Segment(Wording.themeName, theme.dim),
            Segment(theme.name + "  ", theme.text),
            Segment(Wording.difficultyKey, theme.accent), Segment(Wording.difficultyName, theme.dim),
            Segment(Wording.difficulty(state.difficulty), theme.text),
        ]
    }

    /// 盤面の下の COMMS（古い方は控えめな色、新しい方は話し手の色）。2 段目の配置だけ。
    static func comms(_ state: ScreenState, glyphs: FrameGlyphs) -> [[Segment]] {
        let theme = state.display.theme
        return state.remarks.enumerated().map { index, remark in
            let lead = " " + glyphs.marker + " " + remark.persona.name + " " + remark.persona.face + "  "
            guard index == state.remarks.count - 1 else {
                return [Segment(lead + remark.text, theme.dim)]
            }
            return [Segment(lead, theme.accentAlt), Segment(remark.text, theme.text)]
        }
    }
}
