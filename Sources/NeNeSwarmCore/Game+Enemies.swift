/// 敵の動き（隊列・急降下・捕獲ビーム・戻り・通り抜け）。
extension Game {
    /// 急降下の向きを変える前に、隊列から抜け出して上へ回る刻みの数。
    static let loopOutTicks = 8
    /// 戻るときの 1 刻みの最大の量（隊列の 1 歩より大きい）。
    static let returnSpeed = 10
    /// 急降下の横の最高速度。
    static let diveSwing = 4
    /// 捕獲の急降下が止まる高さ。
    static let captureAltitude = Field.units(9)
    /// 捕獲ビームを出す刻みの数。
    static let beamTicks = 90

    mutating func moveEnemies(tuning: Tuning, using generator: inout some RandomNumberGenerator) {
        switch stage.kind {
        case .combat:
            march(tuning: tuning)
            launchDive(tuning: tuning, using: &generator)
        case .bonus:
            spawnFlyby()
        }
        for index in enemies.indices {
            move(at: index, tuning: tuning)
        }
        enemies.removeAll(where: Game.hasFlownAway)
    }

    private mutating func move(at index: Int, tuning: Tuning) {
        var enemy = enemies[index]
        switch enemy.motion {
        case .inSwarm:
            enemy.position = swarm.home(of: enemy.slot)
        case .diving(let dive):
            enemy = steered(enemy, dive: dive, tuning: tuning)
        case .beaming(let ticksLeft):
            enemy.motion = ticksLeft > 1 ? .beaming(ticksLeft: ticksLeft - 1) : .returning
        case .returning:
            enemy = homing(enemy)
        case .flyby(let flight):
            enemy = Game.flown(enemy, flight: flight)
        case .exploding:
            break
        }
        enemies[index] = enemy
    }

    /// 急降下を始める（千分率で 1 刻みに 1 機まで）。親玉は捕虜がいなければ捕獲に来ることがある。
    private mutating func launchDive(tuning: Tuning, using generator: inout some RandomNumberGenerator) {
        guard case .active(let current) = ship, airborneCount < tuning.maxDivers,
            Int.random(in: 0..<1000, using: &generator) < tuning.diveChance,
            let index = enemies.indices.filter({ enemies[$0].motion.isInSwarm }).randomElement(using: &generator)
        else {
            return
        }
        let enemy = enemies[index]
        let purpose = Game.purpose(of: enemy, wing: current.wing, captive: captive, beamsAlready: beamingCount)
            .chosen(coin: Int.random(in: 0..<2, using: &generator))
        let swing = enemy.box.centerX < Field.width / 2 ? -3 : 3
        enemies[index].motion = .diving(Dive(purpose: purpose, velocity: Velocity(dx: swing, dy: -3), elapsed: 0))
    }

    /// 隊列の外を飛んでいる敵の数（急降下・ビーム・戻り）。
    public var airborneCount: Int {
        enemies.filter { enemy in
            switch enemy.motion {
            case .diving, .beaming, .returning: true
            case .inSwarm, .flyby, .exploding: false
            }
        }.count
    }

    private var beamingCount: Int {
        enemies.filter { enemy in
            switch enemy.motion {
            case .diving(let dive):
                if case .capture = dive.purpose {
                    return true
                }
                return false
            case .beaming: return true
            case .inSwarm, .returning, .flyby, .exploding: return false
            }
        }.count
    }

    private static func purpose(of enemy: Enemy, wing: Wing, captive: Captive, beamsAlready: Int) -> DiveChoice {
        guard case .flagship = enemy.kind, case .single = wing, case .none = captive, beamsAlready == 0 else {
            return .attackOnly
        }
        return .either
    }

    /// 急降下を 1 刻み進める。抜け出したあとは自機の方へ曲がりながら降りる。
    private func steered(_ enemy: Enemy, dive: Dive, tuning: Tuning) -> Enemy {
        var next = enemy
        let elapsed = dive.elapsed + 1
        var velocity = dive.velocity
        if elapsed > Game.loopOutTicks {
            let target = targetX
            let turn = target > enemy.box.centerX ? 1 : (target < enemy.box.centerX ? -1 : 0)
            let ceiling = Game.ceiling(of: dive.purpose, tuning: tuning)
            velocity = Velocity(
                dx: min(Game.diveSwing, max(-Game.diveSwing, velocity.dx + turn)),
                dy: min(ceiling, velocity.dy + 1))
        }
        let moved = enemy.position.moved(by: velocity)
        next.position = Point(x: min(Field.width - Enemy.width, max(0, moved.x)), y: moved.y)
        next.motion = .diving(Dive(purpose: dive.purpose, velocity: velocity, elapsed: elapsed))
        return Game.settled(next, purpose: dive.purpose)
    }

    /// 降りる速さの上限。捕獲に来る親玉はゆっくり降りる。
    private static func ceiling(of purpose: DivePurpose, tuning: Tuning) -> Int {
        switch purpose {
        case .attack: tuning.diveSpeed
        case .capture: 3
        }
    }

    /// 捕獲の高さに着いたらビームを出し、下へ抜けたら画面の上から戻る。
    private static func settled(_ enemy: Enemy, purpose: DivePurpose) -> Enemy {
        var next = enemy
        switch purpose {
        case .capture where enemy.position.y >= captureAltitude:
            next.motion = .beaming(ticksLeft: beamTicks)
        case .attack where enemy.position.y >= Field.height:
            next.position = Point(x: enemy.position.x, y: -Enemy.height)
            next.motion = .returning
        case .capture, .attack:
            break
        }
        return next
    }

    /// 急降下が狙う横の位置（自機の真ん中。いなければ盤面の真ん中）。
    private var targetX: Int {
        guard case .active(let current) = ship else {
            return Field.width / 2
        }
        return current.x + current.span / 2
    }

    /// 席へ向かって 1 刻み近づく。着いたら隊列に戻る。
    private func homing(_ enemy: Enemy) -> Enemy {
        var next = enemy
        let home = swarm.home(of: enemy.slot)
        let dx = min(Game.returnSpeed, max(-Game.returnSpeed, home.x - enemy.position.x))
        let dy = min(Game.returnSpeed, max(-Game.returnSpeed, home.y - enemy.position.y))
        next.position = enemy.position.moved(by: Velocity(dx: dx, dy: dy))
        if next.position == home {
            next.motion = .inSwarm
        }
        return next
    }
}
