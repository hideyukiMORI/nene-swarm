import NeNeSwarmCore
import Testing

@testable import NeNeSwarmEngine
@testable import NeNeSwarmRender

/// 12 テーマの色の読みやすさ（FR-12・指示書 第 2-3 節 6・ADR 0010）。
struct ThemeContrastTests {
    /// 自機・敵・弾・トーチカ・UFO・爆発は、地に対して 3:1 以上。
    @Test(arguments: Theme.catalog)
    func spritesStandOutFromTheGround(_ theme: Theme) {
        let sprites: [(String, Rgb)] = [
            ("ship", theme.ship), ("playerShot", theme.playerShot), ("drone", theme.drone), ("escort", theme.escort),
            ("flagship", theme.flagship), ("enemyShot", theme.enemyShot), ("shield", theme.shield),
            ("saucer", theme.saucer), ("spark", theme.spark),
        ]
        for (name, color) in sprites {
            #expect(Contrast.ratio(color, theme.ground) >= 3, "\(theme.name) \(name)")
        }
    }

    /// 自機は、どの敵とも違う色（RGB の距離が 60 以上）。
    @Test(arguments: Theme.catalog)
    func theShipIsNotColoredLikeAnEnemy(_ theme: Theme) {
        for kind in EnemyKind.allCases {
            #expect(Self.distance(theme.ship, theme.color(of: kind)) >= 60, "\(theme.name) \(kind)")
        }
    }

    /// 画面のどの場面でも、英数字のセルは前景と背景が 4.5:1 以上（枠の線と記号と流れる星は飾りなので除く。Igo と同じ範囲）。
    @Test(arguments: Theme.catalog)
    func everyCharacterOnScreenIsReadable(_ theme: Theme) {
        let display = DisplayOptions(theme: theme, traits: TerminalTraits(frame: .boxDrawing, colors: .trueColor))
        var effects = Effects()
        effects.absorb([.game(.saucerDestroyed(points: 800, at: Point(x: 100, y: 0)))])
        let remark = Remark(persona: .nervous, cue: .hit, text: "Tell my cache I loved it.")
        for ticks in [0, 40, 400, 1_500, 4_000] {
            let session = ScreenRendererTests.session(ticks: ticks)
            let state = ScreenState(
                session: session, display: display, difficulty: .hard, seed: 9,
                highScores: HighScoreTable(entries: [
                    HighScore(score: 1_234, pilot: "LUCKY.INI", stage: 3, difficulty: .easy)
                ]),
                persona: .lucky, remarks: [remark], effects: effects, storage: .memoryOnly)
            let grid = ScreenRenderer.render(state, size: ScreenRendererTests.size)
            for row in 0..<grid.size.rows {
                for column in 0..<grid.size.columns {
                    let cell = grid[column, row]
                    guard cell.character.isLetter || cell.character.isNumber else {
                        continue
                    }
                    #expect(
                        Contrast.ratio(cell.foreground, cell.background) >= 4.5,
                        "\(theme.name) tick \(ticks) (\(column), \(row)) '\(cell.character)'")
                }
            }
        }
    }

    static func distance(_ a: Rgb, _ b: Rgb) -> Int {
        abs(Int(a.red) - Int(b.red)) + abs(Int(a.green) - Int(b.green)) + abs(Int(a.blue) - Int(b.blue))
    }
}
