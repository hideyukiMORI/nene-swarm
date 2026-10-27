/// 隊列の行進・隊列とトーチカ・隊列の到達（FR-02 a・FR-02a）。
extension Game {
    /// 隊列の行進を 1 刻み進める。残りが少ないほど 1 歩の間が短い。
    mutating func march(tuning: Tuning) {
        swarm.countdown -= 1
        guard swarm.countdown <= 0 else {
            return
        }
        let solid = enemies.filter { $0.motion.isSolid }
        swarm.countdown = max(1, tuning.marchInterval * solid.count / Game.rosterSize)
        guard let low = solid.map(\.slot.column).min(), let high = solid.map(\.slot.column).max() else {
            return
        }
        let left = swarm.origin.x + low * Swarm.pitchX + swarm.heading.step
        let right = swarm.origin.x + high * Swarm.pitchX + Enemy.width + swarm.heading.step
        if left < 0 || right > Field.width {
            swarm.origin = Point(x: swarm.origin.x, y: swarm.origin.y + Swarm.drop)
            swarm.heading = swarm.heading.reversed
        } else {
            swarm.origin = Point(x: swarm.origin.x + swarm.heading.step, y: swarm.origin.y)
        }
    }

    /// 戦うステージの始まりの敵の数。
    static let rosterSize = Swarm().roster().count

    /// 隊列の敵が触れたトーチカのセルを消す。
    mutating func erodeShields() {
        for enemy in enemies where enemy.motion.isInSwarm {
            while strikeShield(enemy.box) {}
        }
    }

    /// 隊列の敵が自機の段まで降りてきたら終わる。
    mutating func checkInvasion(events: inout [GameEvent]) {
        if enemies.contains(where: { $0.motion.isInSwarm && $0.box.bottom > Ship.top }) {
            end(.invaded, events: &events)
        }
    }

    /// 爆発を 1 刻み進め、終わった敵を消す。
    mutating func finishExplosions() {
        for index in enemies.indices {
            if case .exploding(let ticksLeft) = enemies[index].motion {
                enemies[index].motion = .exploding(ticksLeft: ticksLeft - 1)
            }
        }
        enemies.removeAll { enemy in
            if case .exploding(let ticksLeft) = enemy.motion {
                return ticksLeft <= 0
            }
            return false
        }
    }
}
