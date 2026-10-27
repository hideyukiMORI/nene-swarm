import Testing

@testable import NeNeSwarmCore

/// 同じシード・同じ入力の列からは、同じ状態の列と同じ出来事の列になる（FR-06・ARC-007）。
@Suite struct DeterminismTests {
    private func trace(seed: UInt64, difficulty: Difficulty) -> [GameStep] {
        var steps: [GameStep] = []
        _ = Playthrough.run(seed: seed, pilot: .chaser, difficulty: difficulty) { _, _, step in
            steps.append(step)
        }
        return steps
    }

    @Test(arguments: Difficulty.allCases)
    func theSameSeedReplaysTheSameGameTickByTick(_ difficulty: Difficulty) {
        for seed: UInt64 in [1, 42, 9_001] {
            let first = trace(seed: seed, difficulty: difficulty)
            #expect(!first.isEmpty)
            #expect(first == trace(seed: seed, difficulty: difficulty))
        }
    }

    @Test func differentSeedsPlayDifferentGames() {
        #expect(trace(seed: 1, difficulty: .normal) != trace(seed: 2, difficulty: .normal))
    }

    @Test func aFinishedGameDoesNotChange() {
        var game = Game()
        game.status = .over(.invaded)
        var generator = SplitMix64(seed: 3)
        let step = game.step(PilotInput(steer: .left, trigger: .fire), difficulty: .hard, using: &generator)
        #expect(step.game == game)
        #expect(step.events.isEmpty)
    }
}
