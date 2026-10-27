import NeNeSwarmCore
import NeNeSwarmEngine

/// 盤面の中に出す文字（TITLE・GAME OVER・ステージの帯）。文字は盤面の地の上に書き、自機や敵のセルには書かない。
struct FieldCards {
    let layout: ScreenLayout
    let theme: Theme

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
        center(Wording.gameOver, row: 6, color: theme.accentAlt, into: &grid)
        center(Wording.ending(summary.ending), row: 8, color: theme.dim, into: &grid)
        center(persona.name + " " + persona.face, row: 9, color: theme.accent, into: &grid)
        center("SCORE " + Wording.digits(summary.score, 7), row: 11, color: theme.text, into: &grid)
        center("STAGE " + String(summary.stage.number), row: 12, color: theme.text, into: &grid)
        if summary.score > 0, highScores.best == summary.score {
            center(Wording.newRecord, row: 15, color: theme.accent, into: &grid)
        }
    }

    /// ステージの始まりと終わりの帯（盤面の真ん中の行）。
    func banner(_ game: Game, into grid: inout Grid) {
        switch game.phase {
        case .intro:
            center(Wording.stageBanner(game.stage), row: 10, color: theme.accent, into: &grid)
        case .cleared:
            center(Wording.stageClear, row: 10, color: theme.accent, into: &grid)
        case .combat:
            break
        }
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
