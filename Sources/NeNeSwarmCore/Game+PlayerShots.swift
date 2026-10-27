/// 自機の弾の進み方と当たり方（ADR 0005）。
///
/// 弾は 1 刻みの移動を `Game.substep` 単位以下に刻んで、刻むたびに当たりを見る。
/// だから当たり判定の箱より速い弾でも、1 刻みで敵を飛び越えない（REQUIREMENTS 第 3 節）。
extension Game {
    /// 弾の移動を刻む最大の量（単位）。どの箱の高さよりも小さい。
    static let substep = 4

    /// 捕虜の当たり判定の箱（捕まえた親玉の 1 段上で、半機ぶん右へずれる）。捕虜がいなければ nil。
    ///
    /// 真上に重ねると親玉の陰になり、下からは決して撃てない。半機ずらして右半分を見せる（ADR 0005）。
    public var captiveHull: Box? {
        guard case .held(let holder) = captive, let flagship = enemies.first(where: { $0.id == holder }) else {
            return nil
        }
        return Box(
            origin: Point(x: flagship.position.x + Ship.width / 2, y: flagship.position.y - Ship.height),
            width: Ship.width, height: Ship.height)
    }

    mutating func advancePlayerShots(events: inout [GameEvent]) {
        var survivors: [Shot] = []
        for shot in playerShots {
            if let flown = fly(shot, events: &events) {
                survivors.append(flown)
            }
        }
        playerShots = survivors
    }

    /// 弾を 1 刻み進める。何かに当たるか画面の上へ抜けたら nil。
    private mutating func fly(_ shot: Shot, events: inout [GameEvent]) -> Shot? {
        var current = shot
        for point in Game.path(from: shot.position, by: shot.velocity) {
            current.position = point
            if strikeShield(current.box) || strikeCaptive(current.box, events: &events)
                || strikeEnemy(current.box, events: &events) || strikeSaucer(current.box, events: &events)
            {
                return nil
            }
        }
        return current.box.bottom > 0 ? current : nil
    }

    /// 1 刻みの移動を `substep` 以下に刻んだ途中の位置（最後が行き先）。
    static func path(from start: Point, by velocity: Velocity) -> [Point] {
        let pieces = max(1, (max(abs(velocity.dx), abs(velocity.dy)) + substep - 1) / substep)
        return (1...pieces).map { piece in
            Point(x: start.x + velocity.dx * piece / pieces, y: start.y + velocity.dy * piece / pieces)
        }
    }

    /// 箱と重なるトーチカのセルを 1 つ欠く（自機の弾でも敵の弾でも）。欠いたら true。
    mutating func strikeShield(_ box: Box) -> Bool {
        for index in shields.indices {
            if let cell = shields[index].firstStanding(overlapping: box) {
                shields[index].chip(cell)
                return true
            }
        }
        return false
    }

    private mutating func strikeCaptive(_ box: Box, events: inout [GameEvent]) -> Bool {
        guard let hull = captiveHull, hull.overlaps(box) else {
            return false
        }
        captive = .none
        events.append(.captiveShot)
        return true
    }

    private mutating func strikeEnemy(_ box: Box, events: inout [GameEvent]) -> Bool {
        guard let index = enemies.firstIndex(where: { $0.motion.isSolid && $0.box.overlaps(box) }) else {
            return false
        }
        strike(at: index, events: &events)
        return true
    }

    /// 敵に 1 発当てる。親玉は 1 発目では倒れない。倒したら得点を足し、捕虜の行き先を決める。
    mutating func strike(at index: Int, events: inout [GameEvent]) {
        var enemy = enemies[index]
        guard enemy.hitsLeft <= 1 else {
            enemy.hitsLeft -= 1
            enemies[index] = enemy
            events.append(.flagshipDamaged(at: enemy.position))
            return
        }
        let points = award(for: enemy)
        score += points
        events.append(.enemyDestroyed(enemy.kind, points: points, at: enemy.position))
        if case .held(let holder) = captive, holder == enemy.id {
            freeCaptive(heldBy: enemy, events: &events)
        }
        enemy.hitsLeft = 0
        enemy.motion = .exploding(ticksLeft: Game.explosionTicks)
        enemies[index] = enemy
    }

    private mutating func award(for enemy: Enemy) -> Int {
        switch enemy.motion {
        case .flyby:
            bonus.hits += 1
            return BonusProgress.pointsPerHit
        case .inSwarm, .diving, .beaming, .returning, .exploding:
            return enemy.kind.points(for: enemy.motion.posture)
        }
    }

    /// 捕虜を持った親玉を倒した。隊列の外なら救出、隊列の中なら捕虜は戻らない（FR-02b）。
    private mutating func freeCaptive(heldBy flagship: Enemy, events: inout [GameEvent]) {
        switch flagship.motion.posture {
        case .flying:
            rescue(events: &events)
        case .inSwarm:
            captive = .none
            events.append(.captiveLost)
        }
    }

    private mutating func strikeSaucer(_ box: Box, events: inout [GameEvent]) -> Bool {
        guard case .flying(let current) = saucer, current.box.overlaps(box) else {
            return false
        }
        score += current.points
        events.append(.saucerDestroyed(points: current.points, at: Point(x: current.x, y: 0)))
        saucer = .absent(ticksLeft: Game.saucerInterval)
        return true
    }
}
