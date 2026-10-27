import Testing

@testable import NeNeSwarmCore

/// 難易度とステージの効き方（FR-05・FR-14・Q7）。
@Suite struct DifficultyTests {
    @Test func everyDifficultyCyclesWithTheKey() {
        #expect(Difficulty.easy.next == .normal)
        #expect(Difficulty.normal.next == .hard)
        #expect(Difficulty.hard.next == .easy)
    }

    @Test(arguments: 1...30)
    func aHarderDifficultyNeverHelpsThePilot(_ stage: Int) {
        let tunings = Difficulty.allCases.map { Tuning.make(difficulty: $0, stage: stage) }
        for (easier, harder) in zip(tunings, tunings.dropFirst()) {
            #expect(DifficultyTests.isAtLeastAsHard(harder, as: easier))
        }
    }

    @Test(arguments: Difficulty.allCases)
    func aLaterStageNeverHelpsThePilot(_ difficulty: Difficulty) {
        let tunings = (1...30).map { Tuning.make(difficulty: difficulty, stage: $0) }
        for (earlier, later) in zip(tunings, tunings.dropFirst()) {
            #expect(DifficultyTests.isAtLeastAsHard(later, as: earlier))
        }
        #expect(tunings[29] != tunings[0])
    }

    static func isAtLeastAsHard(_ harder: Tuning, as easier: Tuning) -> Bool {
        harder.marchInterval <= easier.marchInterval && harder.diveChance >= easier.diveChance
            && harder.maxDivers >= easier.maxDivers && harder.diveSpeed >= easier.diveSpeed
            && harder.shotSpeed >= easier.shotSpeed && harder.maxShots >= easier.maxShots
            && harder.swarmFireChance >= easier.swarmFireChance && harder.diverFireChance >= easier.diverFireChance
    }

    /// 同じパイロット・同じシードの集合で、平均の寿命は EASY ≥ NORMAL ≥ HARD（REQUIREMENTS 第 3 節）。
    @Test(arguments: TestPilot.allCases)
    func harderDifficultiesEndGamesSoonerOnAverage(_ pilot: TestPilot) {
        let lifetimes = Difficulty.allCases.map { difficulty in
            (0..<UInt64(InvariantTests.seedsPerCell)).reduce(0) { sum, seed in
                sum + Playthrough.run(seed: seed, pilot: pilot, difficulty: difficulty).ticks
            }
        }
        #expect(lifetimes[0] >= lifetimes[1])
        #expect(lifetimes[1] >= lifetimes[2])
    }

    @Test func theDifficultyPassedOnEachTickIsTheOneThatApplies() {
        var generator = SplitMix64(seed: 5)
        var game = Game()
        game.phase = .combat
        let easy = game.step(.idle, difficulty: .easy, using: &generator)
        generator = SplitMix64(seed: 5)
        let hard = game.step(.idle, difficulty: .hard, using: &generator)
        #expect(easy.game.swarm.countdown != hard.game.swarm.countdown)
    }
}
