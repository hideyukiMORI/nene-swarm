import Testing

@testable import NeNeSwarmCore

/// 捕虜と 2 機並び（FR-02b）。自機の数（残機＋画面の自機＋捕虜）が表どおりに動くことも見る。
@Suite struct CaptureTests {
    private let beamer = Point(x: 100, y: Game.captureAltitude)

    private func beaming(over shipX: Int, wing: Wing = .single) -> Game {
        var game = Scenario.empty()
        game.ship = Scenario.ship(x: shipX, wing: wing)
        game.enemies = [Scenario.enemy(.flagship, at: beamer, motion: .beaming(ticksLeft: 30), id: 7)]
        return game
    }

    @Test func aSingleShipInTheBeamIsCapturedAndCountsAsALostShip() {
        var game = beaming(over: 100)
        let before = game.shipsInPlay
        var events: [GameEvent] = []
        game.resolveBeams(events: &events)
        #expect(events == [.shipCaptured])
        #expect(game.captive == .held(byEnemy: 7))
        #expect(game.ship == .respawning(ticksLeft: Game.respawnTicks))
        #expect(game.reserve == Game.startingReserve - 1)
        #expect(game.enemies[0].motion == .returning)
        #expect(game.shipsInPlay == before)
    }

    @Test func aShipBesideTheBeamIsNotCaptured() {
        var game = beaming(over: 100 + Enemy.width + Game.beamHalfWidth)
        var events: [GameEvent] = []
        game.resolveBeams(events: &events)
        #expect(events.isEmpty)
        #expect(game.captive == .none)
    }

    @Test func aDualShipLosesOnlyTheHullInTheBeam() {
        var game = beaming(over: 100, wing: .dual)
        let before = game.shipsInPlay
        var events: [GameEvent] = []
        game.resolveBeams(events: &events)
        #expect(events == [.shipCaptured])
        #expect(game.ship == Scenario.ship(x: 100 + Ship.width))
        #expect(game.reserve == Game.startingReserve)
        #expect(game.shipsInPlay == before)
    }

    private func holding(_ motion: EnemyMotion, shipX: Int = 200) -> Game {
        var game = Scenario.empty()
        game.ship = Scenario.ship(x: shipX)
        game.enemies = [Scenario.enemy(.flagship, at: Point(x: 100, y: 96), motion: motion, id: 7)]
        game.enemies[0].hitsLeft = 1
        game.captive = .held(byEnemy: 7)
        return game
    }

    private func shoot(_ game: inout Game, at point: Point) -> [GameEvent] {
        game.playerShots = [Scenario.playerShot(at: point)]
        var events: [GameEvent] = []
        game.advancePlayerShots(events: &events)
        return events
    }

    @Test func downingTheFlagshipInFlightRescuesTheCaptiveIntoADualShip() {
        var game = holding(Scenario.attacking)
        let before = game.shipsInPlay
        let events = shoot(&game, at: Point(x: 110, y: 120))
        #expect(
            events == [.enemyDestroyed(.flagship, points: 400, at: Point(x: 100, y: 96)), .captiveRescued(.joined)])
        #expect(game.ship == Scenario.ship(x: 200, wing: .dual))
        #expect(game.captive == .none)
        #expect(game.shipsInPlay == before)
    }

    @Test func aRescueNearTheRightEdgeKeepsBothHullsOnTheField() {
        var game = holding(.returning, shipX: Field.width - Ship.width)
        _ = shoot(&game, at: Point(x: 110, y: 120))
        guard case .active(let ship) = game.ship else {
            Issue.record("自機がいない")
            return
        }
        #expect(ship.wing == .dual)
        #expect(ship.x + ship.span <= Field.width)
    }

    @Test func aRescueWhileTheNextShipIsWaitingGoesToTheReserve() {
        var game = holding(Scenario.attacking)
        game.ship = .respawning(ticksLeft: 10)
        let before = game.shipsInPlay
        let events = shoot(&game, at: Point(x: 110, y: 120))
        #expect(events.last == .captiveRescued(.reserved))
        #expect(game.reserve == Game.startingReserve + 1)
        #expect(game.shipsInPlay == before)
    }

    @Test func downingTheFlagshipInTheSwarmLosesTheCaptive() {
        var game = holding(.inSwarm)
        let before = game.shipsInPlay
        let events = shoot(&game, at: Point(x: 110, y: 120))
        #expect(events == [.enemyDestroyed(.flagship, points: 150, at: Point(x: 100, y: 96)), .captiveLost])
        #expect(game.captive == .none)
        #expect(game.shipsInPlay == before - 1)
    }

    @Test func shootingTheCaptiveLosesIt() throws {
        var game = holding(.inSwarm)
        let hull = try #require(game.captiveHull)
        #expect(hull.origin == Point(x: 100 + Ship.width / 2, y: 96 - Ship.height))
        // 親玉の右の横を抜ける弾は、ずれて見えている捕虜の右半分に当たる。
        let events = shoot(&game, at: Point(x: 100 + Enemy.width + 2, y: hull.bottom + 4))
        #expect(events == [.captiveShot])
        #expect(game.captive == .none)
        #expect(game.enemies[0].motion.isSolid)
    }

    @Test func aDualShipHitOnOneHullKeepsTheOther() {
        var game = Scenario.empty()
        game.ship = Scenario.ship(x: 100, wing: .dual)
        game.enemyShots = [Scenario.enemyShot(at: Point(x: 110, y: Ship.top - 6))]
        let before = game.shipsInPlay
        var events: [GameEvent] = []
        game.advanceEnemyShots(events: &events)
        #expect(events == [.wingLost(.shot)])
        #expect(game.ship == Scenario.ship(x: 100 + Ship.width))
        #expect(game.reserve == Game.startingReserve)
        #expect(game.shipsInPlay == before - 1)
    }

    @Test func aDualShipFiresTwoShotsAtOnce() {
        var game = Scenario.empty()
        game.ship = Scenario.ship(x: 100, wing: .dual)
        game.pull(.fire)
        #expect(game.playerShots.count == 2)
        #expect(!game.canFire)
    }

    @Test func theBeamGrowsDownFromTheFlagshipBeforeItReachesTheShipRow() throws {
        var game = Scenario.empty()
        let flagship = Scenario.enemy(.flagship, at: beamer, motion: .beaming(ticksLeft: Game.beamTicks), id: 7)
        game.enemies = [flagship]
        let first = try #require(game.beam(of: game.enemies[0]))
        #expect(first.origin.y == flagship.box.bottom)
        #expect(first.height == Game.beamGrowth)
        game.enemies[0].motion = .beaming(ticksLeft: 1)
        let last = try #require(game.beam(of: game.enemies[0]))
        #expect(last.bottom == Field.height)
    }
}
