import Testing

@testable import NeNeSwarmCore

/// トーチカ（FR-02a）: 1 セルずつ欠け、欠けたセルは素通りし、ステージの始まりで戻る。
@Suite struct ShieldTests {
    private let shieldTop = Field.units(Shield.topRow)

    private func gameWithOneShield() -> Game {
        var game = Scenario.empty()
        game.shields = [Shield(leftColumn: 2)]
        return game
    }

    @Test func theShieldStartsAsAnArchOfFiveCells() {
        let shield = Shield(leftColumn: 2)
        #expect(shield.standingCount == 5)
        #expect(shield.isStanding(column: 0, row: 1) && !shield.isStanding(column: 1, row: 1))
        #expect(Shield.row().count == 4)
    }

    @Test func aShotFromBelowChipsTheLowestCellItMeetsAndStops() {
        var game = gameWithOneShield()
        game.playerShots = [Scenario.playerShot(at: Point(x: Field.units(2) + 4, y: shieldTop + 40))]
        var events: [GameEvent] = []
        game.advancePlayerShots(events: &events)
        #expect(game.playerShots.isEmpty)
        #expect(game.shields[0].standingCount == 4)
        #expect(!game.shields[0].isStanding(column: 0, row: 1))
    }

    @Test func anEnemyShotFromAboveChipsTheTopCell() {
        var game = gameWithOneShield()
        game.ship = Scenario.ship(x: Field.units(2))
        game.enemyShots = [Scenario.enemyShot(at: Point(x: Field.units(3) + 4, y: shieldTop - 10), speed: 8)]
        var events: [GameEvent] = []
        game.advanceEnemyShots(events: &events)
        #expect(game.enemyShots.isEmpty)
        #expect(!game.shields[0].isStanding(column: 1, row: 0))
        #expect(events.isEmpty)
    }

    @Test func aShotPassesThroughTheGapAndThroughChippedCells() {
        var game = gameWithOneShield()
        // 真ん中の列の下の段は元から空き。上の段を欠いてから撃つと、弾は素通りする。
        game.shields[0].chip(ShieldCell(column: 1, row: 0))
        let before = game.shields[0]
        game.playerShots = [Scenario.playerShot(at: Point(x: Field.units(3) + 4, y: shieldTop + 40))]
        var events: [GameEvent] = []
        for _ in 0..<6 {
            game.advancePlayerShots(events: &events)
        }
        #expect(game.shields[0] == before)
        #expect(game.playerShots.count == 1)
        #expect(game.playerShots[0].position.y < shieldTop)
    }

    @Test func chippedCellsStayChippedUntilTheNextStage() {
        var game = Game()
        game.shields[0].chip(ShieldCell(column: 0, row: 0))
        var generator = SplitMix64(seed: 1)
        for _ in 0..<30 {
            game = game.step(.idle, difficulty: .easy, using: &generator).game
        }
        #expect(!game.shields[0].isStanding(column: 0, row: 0))
        var events: [GameEvent] = []
        game.begin(game.stage.next, events: &events)
        #expect(game.shields == Shield.row())
        #expect(events == [.stageStarted(Stage(number: 2))])
    }

    @Test func theSwarmErasesTheCellsItTouches() {
        var game = gameWithOneShield()
        game.enemies = [Scenario.enemy(.drone, at: Point(x: Field.units(2), y: shieldTop + 4))]
        game.erodeShields()
        // 敵は 2 セル幅で、トーチカの左の 2 列の上下に触れる。右の列の 2 セルだけが残る。
        #expect(game.shields[0].standingCount == 2)
        #expect(game.shields[0].isStanding(column: 2, row: 0) && game.shields[0].isStanding(column: 2, row: 1))
    }
}
