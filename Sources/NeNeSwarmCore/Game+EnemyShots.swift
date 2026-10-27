/// 敵の撃ち方と、敵の弾の進み方・当たり方（FR-02）。
extension Game {
    /// 自機の横をこれ以内（単位）で抜けた弾を「かすめた」と数える。
    static let nearMissGap = Field.cellUnits / 2

    /// 隊列の一番下の敵と、急降下中の敵が撃つ。ボーナスステージでは撃たない。
    mutating func openFire(tuning: Tuning, using generator: inout some RandomNumberGenerator) {
        guard case .combat = stage.kind, case .active(let current) = ship else {
            return
        }
        if enemyShots.count < tuning.maxShots, Int.random(in: 0..<1000, using: &generator) < tuning.swarmFireChance,
            let gunner = swarmGunner(using: &generator)
        {
            enemyShots.append(Game.shot(from: enemies[gunner], toward: nil, speed: tuning.shotSpeed))
        }
        for index in enemies.indices where enemyShots.count < tuning.maxShots {
            guard case .diving(let dive) = enemies[index].motion, case .attack = dive.purpose,
                enemies[index].position.y < Field.units(Shield.topRow),
                Int.random(in: 0..<1000, using: &generator) < tuning.diverFireChance
            else {
                continue
            }
            enemyShots.append(Game.shot(from: enemies[index], toward: current, speed: tuning.shotSpeed))
        }
    }

    /// 隊列の中の、ある列の一番下の敵（列は乱数で選ぶ）。
    private func swarmGunner(using generator: inout some RandomNumberGenerator) -> Int? {
        let ranked = enemies.indices.filter { enemies[$0].motion.isInSwarm }
        guard let pick = ranked.randomElement(using: &generator) else {
            return nil
        }
        let column = enemies[pick].slot.column
        return ranked.filter { enemies[$0].slot.column == column }.max { enemies[$0].slot.row < enemies[$1].slot.row }
    }

    /// 敵の下端の真ん中から出る弾。急降下中は自機の方へ少し寄せる。
    private static func shot(from enemy: Enemy, toward target: Ship?, speed: Int) -> Shot {
        let muzzle = Point(x: enemy.box.centerX - Shot.width / 2, y: enemy.box.bottom)
        guard let target else {
            return Shot(position: muzzle, velocity: Velocity(dx: 0, dy: speed))
        }
        let lean = (target.x + target.span / 2 - enemy.box.centerX) / (3 * Field.cellUnits)
        return Shot(position: muzzle, velocity: Velocity(dx: min(2, max(-2, lean)), dy: speed))
    }

    mutating func advanceEnemyShots(events: inout [GameEvent]) {
        var survivors: [Shot] = []
        for shot in enemyShots {
            switch descend(shot, events: &events) {
            case .flying(let flown): survivors.append(flown)
            case .spent: break
            case .shipLost:
                enemyShots.removeAll()
                return
            }
        }
        enemyShots = survivors
    }

    /// 敵の弾を 1 刻み進める。
    private mutating func descend(_ shot: Shot, events: inout [GameEvent]) -> ShotFate {
        var current = shot
        for point in Game.path(from: shot.position, by: shot.velocity) {
            let before = current.box
            current.position = point
            if strikeShield(current.box) {
                return .spent
            }
            if let hull = struckHull(current.box) {
                loseHull(at: hull, cause: .shot, events: &events)
                return shipIsActive ? .spent : .shipLost
            }
            noteNearMiss(from: before, to: current.box, events: &events)
        }
        return current.position.y < Field.height ? .flying(current) : .spent
    }

    /// 箱と重なる自機の機体の番号（左から）。自機がいなければ nil。
    func struckHull(_ box: Box) -> Int? {
        guard case .active(let current) = ship else {
            return nil
        }
        return current.hulls.firstIndex { $0.overlaps(box) }
    }

    var shipIsActive: Bool {
        switch ship {
        case .active: true
        case .respawning, .lost: false
        }
    }

    /// 弾が自機の下端を越えた刻みに、横の隙間が `nearMissGap` 以内なら「かすめた」。
    private func noteNearMiss(from before: Box, to after: Box, events: inout [GameEvent]) {
        let line = Ship.top + Ship.height
        guard case .active(let current) = ship, before.origin.y < line, after.origin.y >= line else {
            return
        }
        let gap = max(current.x - after.right, after.origin.x - (current.x + current.span))
        if gap >= 0, gap <= Game.nearMissGap {
            events.append(.nearMiss)
        }
    }
}
