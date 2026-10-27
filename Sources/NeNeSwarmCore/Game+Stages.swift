/// ステージの始まりと終わり（FR-05・FR-02d）。
extension Game {
    /// ステージを始める。敵・隊列・トーチカ・弾・UFO を元に戻す。
    mutating func begin(_ next: Stage, events: inout [GameEvent]) {
        stage = next
        phase = .intro(ticksLeft: Game.introTicks)
        swarm = Swarm()
        switch next.kind {
        case .combat: enemies = swarm.roster()
        case .bonus: enemies = []
        }
        shields = Shield.row()
        playerShots = []
        enemyShots = []
        saucer = .absent(ticksLeft: Game.saucerInterval)
        bonus = BonusProgress()
        events.append(.stageStarted(next))
    }

    /// 敵がいなくなったらステージを終える。ボーナスステージは全機が出たあとで、全部倒していればボーナス。
    mutating func checkStageCleared(events: inout [GameEvent]) {
        guard case .running = status, case .combat = phase, enemies.isEmpty else {
            return
        }
        switch stage.kind {
        case .combat:
            break
        case .bonus:
            guard bonus.spawned == BonusProgress.total else {
                return
            }
            if bonus.hits == BonusProgress.total {
                score += BonusProgress.perfectBonus
                events.append(.perfect(bonus: BonusProgress.perfectBonus))
            }
        }
        enemyShots = []
        saucer = .absent(ticksLeft: Game.saucerInterval)
        phase = .cleared(ticksLeft: Game.clearedTicks)
        events.append(.stageCleared(stage))
    }
}
