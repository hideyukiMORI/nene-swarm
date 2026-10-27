import Testing

@testable import NeNeSwarmCore

/// 場面は TITLE → PLAY → GAME OVER → TITLE の順にだけ巡り、決めた長さだけ見せる（FR-03・FR-11）。
@Suite struct SceneTests {
    private enum Kind: Equatable {
        case title
        case play
        case gameOver
    }

    private static func kind(of scene: Scene) -> Kind {
        switch scene {
        case .title: .title
        case .play: .play
        case .gameOver: .gameOver
        }
    }

    @Test func scenesCycleInOrderAndLastAsLongAsConfigured() {
        var session = Session(durations: SceneDurations(titleTicks: 3, gameOverTicks: 2))
        var generator = SplitMix64(seed: 11)
        var pilotGenerator = SplitMix64(seed: 12)
        var runs: [(Kind, Int)] = []
        var started: [Int] = []
        while session.gamesStarted < 4 {
            var input = PilotInput.idle
            if case .play(let game) = session.scene {
                input = TestPilot.random.input(for: game, using: &pilotGenerator)
            }
            let step = session.step(input, difficulty: .hard, using: &generator)
            for case .gameStarted(let number) in step.events {
                started.append(number)
            }
            let kind = SceneTests.kind(of: session.scene)
            if let last = runs.last, last.0 == kind {
                runs[runs.count - 1].1 += 1
            } else {
                runs.append((kind, 1))
            }
            session = step.session
        }
        let order = runs.map(\.0)
        #expect(order == [.title, .play, .gameOver, .title, .play, .gameOver, .title, .play, .gameOver, .title])
        #expect(runs.filter { $0.0 == .title }.allSatisfy { $0.1 == 3 })
        #expect(runs.filter { $0.0 == .gameOver }.allSatisfy { $0.1 == 2 })
        #expect(started == [1, 2, 3, 4])
    }

    @Test func theGameOverSceneCarriesTheFinalScore() {
        var session = Session(durations: SceneDurations(titleTicks: 1, gameOverTicks: 5))
        var generator = SplitMix64(seed: 2)
        var ended: [GameSummary] = []
        while ended.isEmpty {
            let step = session.step(.idle, difficulty: .hard, using: &generator)
            for case .gameEnded(let summary) in step.events {
                ended.append(summary)
            }
            session = step.session
        }
        guard case .gameOver(let summary, let ticksLeft) = session.scene else {
            Issue.record("GAME OVER になっていない")
            return
        }
        #expect(summary == ended[0])
        #expect(ticksLeft == 5)
        #expect(summary.difficulty == .hard)
    }
}
