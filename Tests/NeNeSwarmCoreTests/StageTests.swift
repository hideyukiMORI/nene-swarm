import Testing

@testable import NeNeSwarmCore

/// ステージ・隊列の行進・ボーナスステージ・UFO（FR-02・FR-02c・FR-02d・FR-05）。
@Suite struct StageTests {
    @Test func everyThirdStageIsABonusStage() {
        let kinds = (1...9).map { Stage(number: $0).kind }
        #expect(kinds == [.combat, .combat, .bonus, .combat, .combat, .bonus, .combat, .combat, .bonus])
    }

    @Test func theRosterHasFourFlagshipsSixEscortsAndTwelveDrones() {
        let roster = Swarm().roster()
        #expect(roster.filter { $0.kind == .flagship }.count == 4)
        #expect(roster.filter { $0.kind == .escort }.count == 6)
        #expect(roster.filter { $0.kind == .drone }.count == 12)
        #expect(Set(roster.map(\.id)).count == roster.count)
        #expect(roster.allSatisfy { $0.box.isOnField })
    }

    @Test func theSwarmMarchesDropsAtTheEdgeAndTurnsBack() {
        var game = Scenario.empty()
        game.enemies = game.swarm.roster()
        let tuning = Tuning.make(difficulty: .normal, stage: 1)
        let start = game.swarm.origin
        var drops = 0
        for _ in 0..<2_000 where drops == 0 {
            game.march(tuning: tuning)
            if game.swarm.origin.y > start.y {
                drops += 1
            }
        }
        #expect(game.swarm.origin.y == start.y + Swarm.drop)
        #expect(game.swarm.heading == .left)
        #expect(game.swarm.origin.x + (Swarm.columns - 1) * Swarm.pitchX + Enemy.width <= Field.width)
    }

    @Test func fewerEnemiesMarchFaster() {
        var full = Scenario.empty()
        full.enemies = full.swarm.roster()
        var thin = full
        thin.enemies = Array(thin.enemies.prefix(3))
        let tuning = Tuning.make(difficulty: .normal, stage: 1)
        full.march(tuning: tuning)
        thin.march(tuning: tuning)
        #expect(thin.swarm.countdown < full.swarm.countdown)
    }

    @Test func aBonusStageSendsTwentyQuietFlyersAndEndsWithoutPerfectIfNoneAreHit() {
        var game = Game()
        var events: [GameEvent] = []
        game.begin(Stage(number: 3), events: &events)
        var generator = SplitMix64(seed: 8)
        var seen: Set<Int> = []
        while game.stage.number == 3 {
            let step = game.step(.idle, difficulty: .hard, using: &generator)
            events += step.events
            game = step.game
            if game.stage.number == 3 {
                seen.formUnion(game.enemies.map(\.id))
                #expect(game.enemyShots.isEmpty)
            }
        }
        #expect(seen.count == BonusProgress.total)
        #expect(events.contains(.stageCleared(Stage(number: 3))))
        #expect(!events.contains(.perfect(bonus: BonusProgress.perfectBonus)))
        #expect(game.score == 0)
    }

    @Test func hittingEveryFlyerIsPerfect() {
        var game = Scenario.empty()
        game.stage = Stage(number: 3)
        game.bonus.spawned = BonusProgress.total
        game.bonus.hits = BonusProgress.total
        var events: [GameEvent] = []
        game.checkStageCleared(events: &events)
        #expect(events == [.perfect(bonus: BonusProgress.perfectBonus), .stageCleared(Stage(number: 3))])
        #expect(game.score == BonusProgress.perfectBonus)
        #expect(game.phase == .cleared(ticksLeft: Game.clearedTicks))
    }

    @Test func clearingTheSwarmMovesToTheNextStage() {
        var game = Scenario.empty()
        var generator = SplitMix64(seed: 4)
        var events: [GameEvent] = []
        for _ in 0...Game.clearedTicks {
            let step = game.step(.idle, difficulty: .normal, using: &generator)
            events += step.events
            game = step.game
        }
        #expect(events == [.stageCleared(Stage(number: 1)), .stageStarted(Stage(number: 2))])
        #expect(game.enemies.count == Game.rosterSize)
        #expect(game.phase == .intro(ticksLeft: Game.introTicks))
    }

    @Test func theSaucerCrossesTheTopAndLeaves() {
        var game = Scenario.empty()
        game.enemies = game.swarm.roster()
        game.saucer = .absent(ticksLeft: 1)
        var generator = SplitMix64(seed: 6)
        game.advanceSaucer(using: &generator)
        guard case .flying(let saucer) = game.saucer else {
            Issue.record("UFO が出ていない")
            return
        }
        #expect(Saucer.pointsTable.contains(saucer.points))
        var crossing = 0
        while case .flying = game.saucer {
            game.advanceSaucer(using: &generator)
            crossing += 1
        }
        #expect(crossing == (Field.width + Enemy.width) / Saucer.speed + 1)
        #expect(game.saucer == .absent(ticksLeft: Game.saucerInterval))
    }

    @Test func theSwarmReachingTheShipRowEndsTheGame() {
        var game = Scenario.empty()
        game.enemies = [Scenario.enemy(.drone, at: Point(x: 100, y: Ship.top - Enemy.height + 1))]
        var events: [GameEvent] = []
        game.checkInvasion(events: &events)
        #expect(events == [.gameOver(.invaded)])
    }
}
