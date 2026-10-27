import NeNeSwarmCore
import NeNeSwarmEngine

/// 盤面の中に出す文字（TITLE・GAME OVER・ステージの帯）。文字は盤面の地の上に書き、自機や敵のセルには書かない。
struct FieldCards {
    let layout: ScreenLayout
    let theme: Theme
    let effects: Effects

    /// TITLE: 題・ひとこと・ハイスコアの上位 5 件・次のゲーム。
    func title(_ state: ScreenState, into grid: inout Grid) {
        center(Wording.title, row: 3, color: theme.accent, into: &grid)
        center(Wording.tagline, row: 5, color: theme.dim, into: &grid)
        center(Wording.highScores, row: 8, color: theme.accentAlt, into: &grid)
        for rank in 0..<HighScoreTable.capacity {
            center(FieldCards.line(rank, state.highScores), row: 10 + rank, color: theme.text, into: &grid)
        }
        let next = Wording.game(state.gameNumber) + "   " + Wording.difficulty(state.difficulty)
        center(next, row: 16, color: theme.text, into: &grid)
        center("PILOT " + state.persona.name + " " + state.persona.face, row: 17, color: theme.accent, into: &grid)
        center(Wording.standby, row: 18, color: theme.dim, into: &grid)
    }

    /// GAME OVER: 終わり方・最終スコア・到達ステージ・新記録。
    func gameOver(_ summary: GameSummary, persona: Persona, highScores: HighScoreTable, into grid: inout Grid) {
        big(Wording.gameOver, top: 2, color: theme.accentAlt, into: &grid)
        center(Wording.ending(summary.ending), row: 8, color: theme.dim, into: &grid)
        center(persona.name + " " + persona.face, row: 9, color: theme.accent, into: &grid)
        center("SCORE " + Wording.digits(summary.score, 7), row: 11, color: theme.text, into: &grid)
        center("STAGE " + String(summary.stage.number), row: 12, color: theme.text, into: &grid)
        if summary.score > 0, highScores.best == summary.score {
            center(Wording.newRecord, row: 15, color: theme.accent, into: &grid)
        }
    }

    /// 大きな文字の帯（ステージの始まりと終わり・PERFECT・TWIN WING）と、倒した場所に浮かぶ得点（FR-02f）。
    func overlay(_ game: Game, into grid: inout Grid) {
        for popup in effects.popups {
            let rise = (effects.clock - popup.born) / 10
            let row = Field.cell(popup.point.y) - rise
            let column = FieldMapping.column(popup.point.x)
            write("+" + popup.text, at: (column, row), color: theme.spark, into: &grid)
        }
        if let text = banner(game) {
            big(text, top: 9, color: theme.spark, into: &grid)
        }
    }

    private func banner(_ game: Game) -> String? {
        if effects.showsPerfect {
            return Wording.perfect
        }
        if effects.showsTwin {
            return Wording.twinWing
        }
        switch game.phase {
        case .intro: return Wording.stageBanner(game.stage)
        case .cleared: return Wording.stageClear
        case .combat: return nil
        }
    }

    /// 大きな文字を盤面の真ん中に塗る（点は空白のセルの背景色）。
    private func big(_ text: String, top: Int, color: Rgb, into grid: inout Grid) {
        let left = layout.fieldColumn + (ScreenLayout.fieldWidth - BigFont.span(text)) / 2
        for (row, cells) in BigFont.pixels(text).enumerated() {
            for (offset, lit) in cells.enumerated() where lit {
                grid.paint(column: left + offset, row: layout.fieldRow + top + row, width: 1, color: color)
            }
        }
    }

    /// 盤面の中だけに文字を書く（はみ出す分は捨てる）。
    private func write(_ text: String, at position: (column: Int, row: Int), color: Rgb, into grid: inout Grid) {
        let (column, row) = position
        guard (0..<ScreenLayout.fieldHeight).contains(row), column >= 0 else {
            return
        }
        let visible = String(text.prefix(max(0, ScreenLayout.fieldWidth - column)))
        grid.write(
            visible, column: layout.fieldColumn + column, row: layout.fieldRow + row,
            colors: CellColors(foreground: color, background: theme.ground))
    }

    private static func line(_ rank: Int, _ table: HighScoreTable) -> String {
        guard rank < table.entries.count else {
            return String(rank + 1) + "  -------  ----------  --  ------"
        }
        let entry = table.entries[rank]
        let pilot = String(entry.pilot.prefix(10))
        return String(rank + 1) + "  " + Wording.digits(entry.score, 7) + "  " + pilot
            + String(repeating: " ", count: 10 - pilot.count) + "  " + Wording.digits(entry.stage, 2) + "  "
            + Wording.difficulty(entry.difficulty)
    }

    private func center(_ text: String, row: Int, color: Rgb, into grid: inout Grid) {
        let clipped = String(text.prefix(ScreenLayout.fieldWidth))
        let column = layout.fieldColumn + (ScreenLayout.fieldWidth - clipped.count) / 2
        grid.write(
            clipped, column: column, row: layout.fieldRow + row,
            colors: CellColors(foreground: color, background: theme.ground))
    }
}
