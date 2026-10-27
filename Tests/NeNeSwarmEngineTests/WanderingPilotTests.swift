import NeNeSwarmCore
import Testing

@testable import NeNeSwarmEngine

/// 仮のパイロットの入力はいつも合法で、ゲームを最後まで遊べる（REQUIREMENTS 第 3 節の入力の合法性）。
struct WanderingPilotTests {
    @Test(arguments: Difficulty.allCases)
    func everyInputIsLegalAndTheGameEnds(_ difficulty: Difficulty) {
        for seed: UInt64 in 0..<20 {
            var generator = SplitMix64(seed: seed)
            var pilotGenerator = SplitMix64(seed: seed + 1_000)
            var pilot = WanderingPilot()
            var game = Game()
            while case .running = game.status {
                let input = pilot.input(for: game, using: &pilotGenerator)
                #expect(game.canSteer(input.steer))
                if case .fire = input.trigger {
                    #expect(game.canFire)
                }
                game = game.step(input, difficulty: difficulty, using: &generator).game
            }
            #expect(game.status != .over(.timeLimit))
        }
    }

    @Test func theSameSeedGivesTheSameSequence() {
        var first = SplitMix64(seed: 7)
        var second = SplitMix64(seed: 7)
        #expect((0..<5).map { _ in first.next() } == (0..<5).map { _ in second.next() })
    }
}
