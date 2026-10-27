/// 1 刻みの順番（ADR 0005）。順番はこの 1 か所だけで決める。
extension Game {
    mutating func advance(
        _ input: PilotInput, tuning: Tuning, using generator: inout some RandomNumberGenerator,
        events: inout [GameEvent]
    ) {
        tick += 1
        switch phase {
        case .intro(let ticksLeft):
            steer(input.steer)
            phase = ticksLeft > 1 ? .intro(ticksLeft: ticksLeft - 1) : .combat
        case .combat:
            fight(input, tuning: tuning, using: &generator, events: &events)
        case .cleared(let ticksLeft):
            steer(input.steer)
            advancePlayerShots(events: &events)
            if ticksLeft > 1 {
                phase = .cleared(ticksLeft: ticksLeft - 1)
            } else {
                begin(stage.next, events: &events)
            }
        }
        countDownRespawn(events: &events)
        if case .running = status, tick >= Game.tickLimit {
            end(.timeLimit, events: &events)
        }
    }

    /// 戦っている刻み。自機 → 自機の弾 → 敵の動き → UFO → 敵の弾 → 体当たり → 捕獲ビーム → 隊列とトーチカ → ステージの終わり。
    private mutating func fight(
        _ input: PilotInput, tuning: Tuning, using generator: inout some RandomNumberGenerator,
        events: inout [GameEvent]
    ) {
        steer(input.steer)
        pull(input.trigger)
        advancePlayerShots(events: &events)
        moveEnemies(tuning: tuning, using: &generator)
        advanceSaucer(using: &generator)
        openFire(tuning: tuning, using: &generator)
        advanceEnemyShots(events: &events)
        resolveRamming(events: &events)
        resolveBeams(events: &events)
        erodeShields()
        checkInvasion(events: &events)
        finishExplosions()
        checkStageCleared(events: &events)
    }

    /// ゲームを終える。終わり方は最初の 1 つだけ。
    mutating func end(_ ending: GameEnding, events: inout [GameEvent]) {
        guard case .running = status else {
            return
        }
        status = .over(ending)
        events.append(.gameOver(ending))
    }
}
