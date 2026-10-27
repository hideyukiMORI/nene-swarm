@testable import NeNeSwarmCore

/// 1 ゲームを最後まで回した記録。
struct Playthrough {
    let final: Game
    let ticks: Int
    let events: [GameEvent]

    /// シードとパイロットと難易度で 1 ゲームを終わりまで回す。刻みごとに `inspect` を呼ぶ（前の状態・入力・結果）。
    static func run(
        seed: UInt64, pilot: TestPilot, difficulty: Difficulty,
        inspect: (Game, PilotInput, GameStep) -> Void = { _, _, _ in }
    ) -> Playthrough {
        var generator = SplitMix64(seed: seed)
        var pilotGenerator = SplitMix64(seed: seed ^ 0xA5A5_A5A5)
        var game = Game()
        var events: [GameEvent] = []
        while case .running = game.status {
            let input = pilot.input(for: game, using: &pilotGenerator)
            let step = game.step(input, difficulty: difficulty, using: &generator)
            inspect(game, input, step)
            events += step.events
            game = step.game
        }
        return Playthrough(final: game, ticks: game.tick, events: events)
    }
}
