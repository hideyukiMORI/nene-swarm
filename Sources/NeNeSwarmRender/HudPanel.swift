import NeNeSwarmCore

/// 右の HUD（FR-10）: スコア・1 位・ステージ・残機・難易度・パイロット・ゲームの番号と、盤面の様子。
struct HudPanel {
    let state: ScreenState
    let panel: Panel
    let theme: Theme

    /// 上から順の行（`rows` 行に満たなければ空の行で埋め、下端の枠で閉じる）。
    func lines(rows: Int) -> [[Segment]] {
        var lines = [panel.header("STATUS", title: theme.accent, frame: theme.frame, first: true)]
        lines += status().map { panel.row($0, frame: theme.frame) }
        lines.append(panel.header("SWARM", title: theme.accent, frame: theme.frame, first: false))
        lines += intel().map { panel.row($0, frame: theme.frame) }
        lines.append(panel.header("COMMS", title: theme.accent, frame: theme.frame, first: false))
        lines += comms(rows: rows - lines.count - 1).map { panel.row($0, frame: theme.frame) }
        while lines.count < rows - 1 {
            lines.append(panel.row([], frame: theme.frame))
        }
        return Array(lines.prefix(rows - 1)) + [panel.footer(frame: theme.frame)]
    }

    private func status() -> [[Segment]] {
        let game = playing
        return [
            pair("SCORE", Wording.digits(game?.score ?? lastScore, 7)),
            pair("HI", Wording.digits(max(state.highScores.best, game?.score ?? 0), 7)),
            pair("STAGE", Wording.digits(game?.stage.number ?? 1, 2)),
            pair("SHIPS", ships(game)),
            pair("LEVEL", Wording.difficulty(state.difficulty)),
            pair("PILOT", state.persona.name),
            pair("GAME", Wording.digits(state.gameNumber, 3)),
        ]
    }

    private func intel() -> [[Segment]] {
        guard let game = playing else {
            return [pair("STATE", sceneName)]
        }
        let solid = game.enemies.filter(\.motion.isSolid)
        return [
            pair("HOSTILES", Wording.digits(solid.count, 2)),
            pair("DIVING", Wording.digits(game.airborneCount, 2)),
            pair("WING", wing(game)),
            pair("CAPTIVE", game.captiveHull == nil ? "NONE" : "HELD"),
        ]
    }

    /// COMMS: 話し手の名前と顔、その下に折り返したセリフ（入りきらない分は切る）。
    private func comms(rows: Int) -> [[Segment]] {
        guard let remark = state.remark, rows > 0 else {
            return []
        }
        let width = panel.width - 4
        let head = [Segment(remark.persona.name + " ", theme.accentAlt), Segment(remark.persona.face, theme.accent)]
        let body = Wording.wrap(remark.text, width: width).map { [Segment($0, theme.text)] }
        return Array(([head] + body).prefix(rows))
    }

    private var playing: Game? {
        if case .play(let game) = state.session.scene {
            return game
        }
        return nil
    }

    private var lastScore: Int {
        if case .gameOver(let summary, _) = state.session.scene {
            return summary.score
        }
        return 0
    }

    private var sceneName: String {
        switch state.session.scene {
        case .title: "TITLE"
        case .play: "PLAY"
        case .gameOver: "GAME OVER"
        }
    }

    private func ships(_ game: Game?) -> String {
        guard let game else {
            return "--"
        }
        return Wording.digits(game.shipsInPlay, 2)
    }

    private func wing(_ game: Game) -> String {
        guard case .active(let ship) = game.ship else {
            return "----"
        }
        switch ship.wing {
        case .single: return "SINGLE"
        case .dual: return "DUAL"
        }
    }

    private func pair(_ label: String, _ value: String) -> [Segment] {
        [
            Segment(label + String(repeating: " ", count: max(9 - label.count, 1)), theme.dim),
            Segment(value, theme.text),
        ]
    }
}
