import Testing

@testable import NeNeSwarmCore

/// 手で作った場面で、当たり判定の結果が決まったとおりになることを確かめる（REQUIREMENTS 第 3 節）。
@Suite struct CollisionTests {
    private let target = Point(x: 160, y: 96)

    private func fire(_ shots: [Shot], at enemies: [Enemy]) -> (Game, [GameEvent]) {
        var game = Scenario.empty()
        game.enemies = enemies
        game.playerShots = shots
        var events: [GameEvent] = []
        game.advancePlayerShots(events: &events)
        return (game, events)
    }

    @Test func aShotThatEndsInsideTheEnemyHitsIt() {
        let (game, events) = fire(
            [Scenario.playerShot(at: Point(x: 170, y: 120))], at: [Scenario.enemy(.drone, at: target)])
        #expect(events == [.enemyDestroyed(.drone, points: 50, at: target)])
        #expect(game.score == 50)
        #expect(game.playerShots.isEmpty)
        #expect(game.enemies.first?.motion == .exploding(ticksLeft: Game.explosionTicks))
    }

    @Test func aShotJustBesideTheEnemyPassesIt() {
        let beside = Point(x: target.x + Enemy.width, y: 120)
        let (game, events) = fire([Scenario.playerShot(at: beside)], at: [Scenario.enemy(.drone, at: target)])
        #expect(events.isEmpty)
        #expect(game.playerShots.count == 1)
    }

    @Test func aShotFasterThanTheEnemyIsTallStillHitsIt() {
        // 1 刻みで 3 セル進む弾。始まりは敵の下、行き先は敵の上で、どちらの位置でも敵と重ならない。
        let shot = Scenario.playerShot(at: Point(x: 170, y: target.y + Enemy.height + 1), speed: 3 * Field.cellUnits)
        #expect(!shot.box.overlaps(Scenario.enemy(.drone, at: target).box))
        let (game, events) = fire([shot], at: [Scenario.enemy(.drone, at: target)])
        #expect(events.count == 1)
        #expect(game.playerShots.isEmpty)
    }

    @Test func thePathIsCutIntoPiecesNoTallerThanAnyBox() {
        let path = Game.path(from: Point(x: 0, y: 100), by: Velocity(dx: 0, dy: -48))
        #expect(path.count == 12)
        #expect(path.last == Point(x: 0, y: 52))
        #expect(Game.substep < Shot.height && Game.substep < Enemy.height)
    }

    @Test func twoShotsInOneTickDestroyTwoEnemies() {
        let other = Point(x: 260, y: 96)
        let (game, events) = fire(
            [Scenario.playerShot(at: Point(x: 170, y: 120)), Scenario.playerShot(at: Point(x: 270, y: 120))],
            at: [Scenario.enemy(.drone, at: target), Scenario.enemy(.escort, at: other, id: 1)])
        #expect(events.count == 2)
        #expect(game.score == 50 + 80)
    }

    @Test func aSecondShotPassesAnEnemyAlreadyExploding() {
        let (game, events) = fire(
            [Scenario.playerShot(at: Point(x: 170, y: 120)), Scenario.playerShot(at: Point(x: 176, y: 124))],
            at: [Scenario.enemy(.drone, at: target)])
        #expect(events.count == 1)
        #expect(game.playerShots.count == 1)
    }

    @Test func aFlagshipNeedsTwoHits() {
        let first = fire([Scenario.playerShot(at: Point(x: 170, y: 120))], at: [Scenario.enemy(.flagship, at: target)])
        #expect(first.1 == [.flagshipDamaged(at: target)])
        #expect(first.0.score == 0)
        var game = first.0
        game.playerShots = [Scenario.playerShot(at: Point(x: 170, y: 120))]
        var events: [GameEvent] = []
        game.advancePlayerShots(events: &events)
        #expect(events == [.enemyDestroyed(.flagship, points: 150, at: target)])
    }

    @Test func aDivingEnemyIsWorthMoreThanOneInTheSwarm() {
        let (game, _) = fire(
            [Scenario.playerShot(at: Point(x: 170, y: 120))],
            at: [Scenario.enemy(.escort, at: target, motion: Scenario.attacking)])
        #expect(game.score == 160)
    }

    @Test func anEnemyShotDestroysASingleShipAndTakesOneFromTheReserve() {
        var game = Scenario.empty()
        game.ship = Scenario.ship(x: 100)
        game.enemyShots = [Scenario.enemyShot(at: Point(x: 110, y: Ship.top - 6))]
        let before = game.shipsInPlay
        var events: [GameEvent] = []
        game.advanceEnemyShots(events: &events)
        #expect(events == [.shipDestroyed(.shot)])
        #expect(game.ship == .respawning(ticksLeft: Game.respawnTicks))
        #expect(game.reserve == Game.startingReserve - 1)
        #expect(game.shipsInPlay == before - 1)
        #expect(game.enemyShots.isEmpty)
    }

    @Test func theLastShipEndsTheGame() {
        var game = Scenario.empty()
        game.reserve = 0
        game.ship = Scenario.ship(x: 100)
        game.enemyShots = [Scenario.enemyShot(at: Point(x: 110, y: Ship.top - 6))]
        var events: [GameEvent] = []
        game.advanceEnemyShots(events: &events)
        #expect(events == [.shipDestroyed(.shot), .gameOver(.outOfShips)])
        #expect(game.status == .over(.outOfShips))
        #expect(game.ship == .lost)
    }

    @Test func aShotThatGrazesTheShipIsANearMiss() {
        var game = Scenario.empty()
        game.ship = Scenario.ship(x: 100)
        game.enemyShots = [Scenario.enemyShot(at: Point(x: 100 + Ship.width + 4, y: Ship.top + Ship.height - 2))]
        var events: [GameEvent] = []
        game.advanceEnemyShots(events: &events)
        #expect(events == [.nearMiss])
        #expect(game.shipIsActive)
    }

    @Test func aDiverThatRamsTheShipIsDestroyedWithIt() {
        var game = Scenario.empty()
        game.ship = Scenario.ship(x: 100)
        game.enemies = [Scenario.enemy(.flagship, at: Point(x: 110, y: Ship.top - 4), motion: Scenario.attacking)]
        var events: [GameEvent] = []
        game.resolveRamming(events: &events)
        #expect(
            events == [
                .enemyDestroyed(.flagship, points: 400, at: Point(x: 110, y: Ship.top - 4)), .shipDestroyed(.rammed),
            ])
    }

    @Test func anEnemyInTheSwarmDoesNotRam() {
        var game = Scenario.empty()
        game.ship = Scenario.ship(x: 100)
        game.enemies = [Scenario.enemy(.drone, at: Point(x: 110, y: Ship.top - 4))]
        var events: [GameEvent] = []
        game.resolveRamming(events: &events)
        #expect(events.isEmpty)
    }

    @Test func theSaucerPaysItsHiddenPoints() {
        var game = Scenario.empty()
        var saucer = Saucer(heading: 1, points: 800)
        saucer.x = 100
        game.saucer = .flying(saucer)
        game.playerShots = [Scenario.playerShot(at: Point(x: 110, y: 20))]
        var events: [GameEvent] = []
        game.advancePlayerShots(events: &events)
        #expect(events == [.saucerDestroyed(points: 800, at: Point(x: 100, y: 0))])
        #expect(game.score == 800)
    }
}
