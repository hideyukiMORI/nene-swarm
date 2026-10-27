/// 起動から `q` までの場面の列（FR-03）。場面の遷移はこの型の `step` の 1 経路だけ（ARC-001）。
public struct Session: Sendable, Hashable {
    /// いまの場面。
    public let scene: Scene
    /// 始めたゲームの数。
    public let gamesStarted: Int
    /// 場面を見せる長さ。
    public let durations: SceneDurations

    /// TITLE から始める。
    public init(durations: SceneDurations) {
        self.init(scene: .title(ticksLeft: durations.titleTicks), gamesStarted: 0, durations: durations)
    }

    private init(scene: Scene, gamesStarted: Int, durations: SceneDurations) {
        self.scene = scene
        self.gamesStarted = gamesStarted
        self.durations = durations
    }

    /// 1 刻み進める。PLAY の間だけ入力と難易度がゲームに効く。
    public func step(
        _ input: PilotInput, difficulty: Difficulty, using generator: inout some RandomNumberGenerator
    ) -> SessionStep {
        switch scene {
        case .title(let ticksLeft):
            guard ticksLeft <= 1 else {
                return moved(to: .title(ticksLeft: ticksLeft - 1), events: [])
            }
            let game = Game()
            return SessionStep(
                session: Session(scene: .play(game), gamesStarted: gamesStarted + 1, durations: durations),
                events: [.gameStarted(number: gamesStarted + 1), .game(.stageStarted(game.stage))]
            )
        case .play(let game):
            return played(game.step(input, difficulty: difficulty, using: &generator), difficulty: difficulty)
        case .gameOver(let summary, let ticksLeft):
            guard ticksLeft <= 1 else {
                return moved(to: .gameOver(summary, ticksLeft: ticksLeft - 1), events: [])
            }
            return moved(to: .title(ticksLeft: durations.titleTicks), events: [.titleShown])
        }
    }

    private func played(_ step: GameStep, difficulty: Difficulty) -> SessionStep {
        let events = step.events.map(SessionEvent.game)
        guard case .over(let ending) = step.game.status else {
            return moved(to: .play(step.game), events: events)
        }
        let summary = GameSummary(
            score: step.game.score, stage: step.game.stage, ending: ending, difficulty: difficulty,
            ticks: step.game.tick)
        return moved(to: .gameOver(summary, ticksLeft: durations.gameOverTicks), events: events + [.gameEnded(summary)])
    }

    private func moved(to next: Scene, events: [SessionEvent]) -> SessionStep {
        SessionStep(session: Session(scene: next, gamesStarted: gamesStarted, durations: durations), events: events)
    }
}
