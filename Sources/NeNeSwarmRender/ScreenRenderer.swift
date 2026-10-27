/// 画面の状態と端末の大きさから、1 画面分のセルの格子を作る（ARC-011: 値を作るだけで端末を知らない）。
public enum ScreenRenderer {
    /// 画面がちょうど入る大きさ（これより小さければ 1 行の文言だけ）。
    public static let minimumSize = ScreenLayout.compact.size
    /// 2 段目の配置がちょうど入る大きさ。
    public static let largeSize = ScreenLayout.large.size

    /// 1 画面分の格子。
    public static func render(_ state: ScreenState, size: ScreenSize) -> Grid {
        let theme = state.display.theme
        var grid = Grid.filled(size, with: Cell(character: " ", foreground: theme.text, background: theme.ground))
        guard size.columns >= minimumSize.columns, size.rows >= minimumSize.rows else {
            grid.write(
                Wording.tooSmall(need: minimumSize), column: 0, row: 0,
                colors: CellColors(foreground: theme.text, background: theme.ground))
            return grid
        }
        let fitsLarge = size.columns >= largeSize.columns && size.rows >= largeSize.rows
        draw(state, layout: fitsLarge ? .large : .compact, into: &grid)
        return grid
    }

    private static func draw(_ state: ScreenState, layout: ScreenLayout, into grid: inout Grid) {
        let theme = state.display.theme
        let glyphs = FrameGlyphs.of(state.display.traits.frame)
        band(row: 0, theme: theme, into: &grid)
        grid.write(ScreenChrome.header(state, glyphs: glyphs), column: 0, row: 0, background: theme.panel)
        frame(layout, glyphs: glyphs, theme: theme, into: &grid)
        let painter = FieldPainter(layout: layout, theme: theme, effects: state.effects)
        let cards = FieldCards(layout: layout, theme: theme, effects: state.effects)
        painter.clear(&grid)
        switch state.session.scene {
        case .title:
            cards.title(state, into: &grid)
        case .play(let game):
            painter.draw(game, into: &grid)
            cards.overlay(game, into: &grid)
        case .gameOver(let summary, _):
            cards.gameOver(summary, persona: state.persona, highScores: state.highScores, into: &grid)
        }
        let hud = HudPanel(
            state: state, panel: Panel(width: layout.hudWidth, glyphs: glyphs), theme: theme, layout: layout)
        let rows = layout.frameBottom - layout.frameTop + 1
        for (offset, line) in hud.lines(rows: rows).enumerated() {
            grid.write(line, column: layout.hudColumn, row: layout.frameTop + offset, background: theme.ground)
        }
        for (offset, line) in ScreenChrome.comms(state, glyphs: glyphs).prefix(layout.commsRows).enumerated() {
            grid.write(line, column: 0, row: layout.commsRow + offset, background: theme.ground)
        }
        band(row: layout.footerRow, theme: theme, into: &grid)
        grid.write(ScreenChrome.footer(state), column: 0, row: layout.footerRow, background: theme.panel)
    }

    /// 盤面を囲む枠。
    private static func frame(_ layout: ScreenLayout, glyphs: FrameGlyphs, theme: Theme, into grid: inout Grid) {
        let colors = CellColors(foreground: theme.frame, background: theme.ground)
        let across = String(repeating: glyphs.horizontal, count: ScreenLayout.fieldWidth)
        let left = layout.fieldColumn - 1
        grid.write(glyphs.topLeft + across + glyphs.topRight, column: left, row: layout.frameTop, colors: colors)
        grid.write(
            glyphs.bottomLeft + across + glyphs.bottomRight, column: left, row: layout.frameBottom, colors: colors)
        for row in layout.fieldRow..<layout.frameBottom {
            grid.write(glyphs.vertical, column: left, row: row, colors: colors)
            grid.write(glyphs.vertical, column: layout.fieldColumn + ScreenLayout.fieldWidth, row: row, colors: colors)
        }
    }

    private static func band(row: Int, theme: Theme, into grid: inout Grid) {
        grid.paint(column: 0, row: row, width: grid.size.columns, color: theme.panel)
    }
}
