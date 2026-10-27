import NeNeSwarmCore

/// どこを狙うか（狙う横の位置と、撃ってよいか）。
struct Aim {
    let game: Game
    let ship: Ship
    let persona: Persona

    /// 自機の真ん中の横の位置。
    var center: Int { ship.x + ship.span / 2 }

    /// 向かう横の位置。ビームに入りたい・UFO を追う・トーチカに隠れる・敵を狙う、の順に決める。
    var goalX: Int {
        if let beam = wantedBeam {
            return beam.centerX
        }
        if persona.chasesSaucer, case .flying(let saucer) = game.saucer {
            return lead(saucer.box.centerX, dx: Saucer.speed * saucer.heading, top: 0)
        }
        if persona.hugsShields, let cover = cover {
            return cover
        }
        return target ?? center
    }

    /// 撃ってよいか: 弾が届くときに、どれかの敵（か UFO）が自機の真上の `aimTolerance` 以内にいる。
    var isLinedUp: Bool {
        let reach = persona.aimTolerance + Enemy.width / 2
        let enemies = game.enemies.filter(\.motion.isSolid).contains { enemy in
            abs(lead(enemy.box.centerX, dx: Aim.drift(of: enemy), top: enemy.position.y) - center) <= reach
        }
        guard case .flying(let saucer) = game.saucer else {
            return enemies
        }
        return enemies || abs(lead(saucer.box.centerX, dx: Saucer.speed * saucer.heading, top: 0) - center) <= reach
    }

    /// 撃つと捕虜に当たりそうか（捕虜は撃たない）。
    var captiveInLine: Bool {
        guard let hull = game.captiveHull else {
            return false
        }
        return ship.hulls.contains { $0.centerX >= hull.origin.x - Shot.width && $0.centerX <= hull.right + Shot.width }
    }

    /// 入りに行くビーム（2 機並びが欲しい性格で、1 機だけで、捕虜がいないとき）。
    var wantedBeam: Box? {
        guard persona.seeksCapture, case .single = ship.wing, game.captiveHull == nil else {
            return nil
        }
        return game.enemies.lazy.compactMap { game.beam(of: $0) }.first
    }

    /// 弾が上から来ているときに隠れる、いちばん近いトーチカの真ん中。
    private var cover: Int? {
        let incoming = game.enemyShots.contains { abs($0.box.centerX - center) < 3 * Field.cellUnits }
        guard incoming else {
            return nil
        }
        let standing = game.shields.filter { $0.standingCount > 0 }
        let centers = standing.map { Field.units($0.leftColumn) + Shield.columns * Field.cellUnits / 2 }
        return centers.min { abs($0 - center) < abs($1 - center) }
    }

    /// 狙う敵の、弾が届くときの横の位置（いちばん近いもの）。
    var target: Int? {
        let solid = game.enemies.filter(\.motion.isSolid)
        let scored = solid.map { enemy in
            let x = lead(enemy.box.centerX, dx: Aim.drift(of: enemy), top: enemy.position.y)
            return (x: x, cost: abs(x - center) + (Ship.top - enemy.position.y) / 4)
        }
        return scored.min { $0.cost < $1.cost }?.x
    }

    /// 弾が届くまでに動く分を足した位置。
    private func lead(_ x: Int, dx: Int, top: Int) -> Int {
        let ticks = max(0, Ship.top - top) / Field.cellUnits
        return x + dx * ticks
    }

    private static func drift(of enemy: Enemy) -> Int {
        switch enemy.motion {
        case .diving(let dive): dive.velocity.dx
        case .flyby(let flight): flight.velocity.dx
        case .inSwarm, .beaming, .returning, .exploding: 0
        }
    }
}
