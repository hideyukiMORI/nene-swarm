import NeNeSwarmCore

/// 左・右・止まるを、Core の 1 刻み関数でそのまま先まで進めてみて、当たらない向きを選ぶ（第 2 の物理を作らない・ARC-001）。
///
/// 先読みの中では乱数源に `Calm` を使うので、まだ撃たれていない弾やまだ始まっていない急降下は見えない。
struct Foresight {
    let game: Game
    let persona: Persona
    let difficulty: Difficulty

    /// 狙う位置へ近づく向きの順に、当たらないものを選ぶ。見落としているときは危険を見ない。どれも当たるなら最も遅く当たる向き。
    func choose(toward goal: Int, center: Int, careless: Bool) -> Steer {
        let legal = Foresight.order(toward: goal, from: center).filter { game.canSteer($0) }
        if careless {
            return legal.first ?? .hold
        }
        var latest: (steer: Steer, tick: Int)?
        for steer in legal {
            guard let tick = impact(moving: steer) else {
                return steer
            }
            if tick > latest?.tick ?? 0 {
                latest = (steer, tick)
            }
        }
        return latest?.steer ?? .hold
    }

    /// その向きに動き続けたとき、最初に自機を失う刻み（失わなければ nil）。2 機並びが欲しい性格は、捕まることを数えない。
    func impact(moving steer: Steer) -> Int? {
        var future = game
        var calm = Calm()
        for tick in 1...persona.foresight {
            let step = future.step(PilotInput(steer: steer, trigger: .hold), difficulty: difficulty, using: &calm)
            if step.events.contains(where: isLoss) {
                return tick
            }
            future = step.game
        }
        return nil
    }

    private func isLoss(_ event: GameEvent) -> Bool {
        switch event {
        case .shipDestroyed, .wingLost: true
        case .shipCaptured: !persona.seeksCapture
        case .stageStarted, .stageCleared, .enemyDestroyed, .flagshipDamaged, .saucerDestroyed, .shipRespawned,
            .captiveRescued, .captiveLost, .captiveShot, .nearMiss, .perfect, .gameOver:
            false
        }
    }

    private static func order(toward goal: Int, from center: Int) -> [Steer] {
        if goal < center - Ship.speed {
            return [.left, .hold, .right]
        }
        if goal > center + Ship.speed {
            return [.right, .hold, .left]
        }
        return [.hold, .left, .right]
    }
}
