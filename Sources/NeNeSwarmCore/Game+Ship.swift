/// 自機の動き・射撃・失い方・次の 1 機（FR-04・FR-02b）。
extension Game {
    /// 画面の自機が撃てるか（引き金を引いて弾が出るか）。パイロットはこれを見て撃つ（入力の合法性）。
    public var canFire: Bool {
        guard case .active(let current) = ship, case .combat = phase else {
            return false
        }
        return current.cooldown == 0 && playerShots.count + current.wing.count <= Ship.shotsPerHull * current.wing.count
    }

    /// 画面の自機がその向きへ動けるか（端より外へは動けない）。
    public func canSteer(_ direction: Steer) -> Bool {
        guard case .active(let current) = ship else {
            switch direction {
            case .left, .right: return false
            case .hold: return true
            }
        }
        switch direction {
        case .left: return current.x > 0
        case .right: return current.x < current.maxX
        case .hold: return true
        }
    }

    /// 自機を動かし、次に撃てるまでの残りを 1 刻み減らす。
    mutating func steer(_ direction: Steer) {
        guard case .active(var current) = ship else {
            return
        }
        switch direction {
        case .left: current.x = max(0, current.x - Ship.speed)
        case .right: current.x = min(current.maxX, current.x + Ship.speed)
        case .hold: break
        }
        if current.cooldown > 0 {
            current.cooldown -= 1
        }
        ship = .active(current)
    }

    mutating func pull(_ trigger: Trigger) {
        guard case .fire = trigger, canFire, case .active(var current) = ship else {
            return
        }
        for hull in current.hulls {
            let muzzle = Point(x: hull.centerX - Shot.width / 2, y: Ship.top - Shot.height)
            playerShots.append(Shot(position: muzzle, velocity: Velocity(dx: 0, dy: -Field.cellUnits)))
        }
        current.cooldown = Ship.reload
        ship = .active(current)
    }

    mutating func countDownRespawn(events: inout [GameEvent]) {
        guard case .respawning(let ticksLeft) = ship else {
            return
        }
        if ticksLeft > 1 {
            ship = .respawning(ticksLeft: ticksLeft - 1)
        } else {
            ship = .active(Ship.centered())
            events.append(.shipRespawned)
        }
    }

    /// 機体を 1 つ失う。2 機並びなら残った方だけの 1 機になり、1 機なら残機から次を出すか、尽きたら終わる。
    mutating func loseHull(at index: Int, cause: HitCause, events: inout [GameEvent]) {
        guard case .active(var current) = ship else {
            return
        }
        switch current.wing {
        case .dual:
            current.x += index == 0 ? Ship.width : 0
            current.wing = .single
            ship = .active(current)
            events.append(.wingLost(cause))
        case .single:
            events.append(.shipDestroyed(cause))
            retireShip(events: &events)
        }
    }

    /// 1 機だけの自機が画面から消えたあと（撃墜か捕獲）。残機があれば次を待ち、無ければ終わる。
    mutating func retireShip(events: inout [GameEvent]) {
        enemyShots.removeAll()
        if reserve > 0 {
            reserve -= 1
            ship = .respawning(ticksLeft: Game.respawnTicks)
        } else {
            ship = .lost
            end(.outOfShips, events: &events)
        }
    }

    /// 捕虜を救出する。並べるなら 2 機並びに、並べないなら残機に戻す。
    mutating func rescue(events: inout [GameEvent]) {
        captive = .none
        if case .active(var current) = ship, case .single = current.wing {
            current.wing = .dual
            current.x = min(current.x, current.maxX)
            ship = .active(current)
            events.append(.captiveRescued(.joined))
        } else {
            reserve += 1
            events.append(.captiveRescued(.reserved))
        }
    }
}
