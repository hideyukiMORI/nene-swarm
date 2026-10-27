@testable import NeNeSwarmCore

/// 手で作る場面（当たり判定・トーチカ・捕虜のテスト用）。戦っている段階の、敵も弾も無いゲームから始める。
enum Scenario {
    static func empty() -> Game {
        var game = Game()
        game.phase = .combat
        game.enemies = []
        game.shields = []
        game.playerShots = []
        game.enemyShots = []
        return game
    }

    /// 敵を 1 機置く。
    static func enemy(_ kind: EnemyKind, at position: Point, motion: EnemyMotion = .inSwarm, id: Int = 0) -> Enemy {
        var enemy = Enemy(id: id, kind: kind, slot: Slot(column: 0, row: 0), position: position)
        enemy.motion = motion
        return enemy
    }

    /// 自機を置く。
    static func ship(x: Int, wing: Wing = .single) -> ShipPresence {
        .active(Ship(x: x, wing: wing))
    }

    /// 上へ進む自機の弾。
    static func playerShot(at position: Point, speed: Int = Field.cellUnits) -> Shot {
        Shot(position: position, velocity: Velocity(dx: 0, dy: -speed))
    }

    /// 下へ進む敵の弾。
    static func enemyShot(at position: Point, speed: Int = 5) -> Shot {
        Shot(position: position, velocity: Velocity(dx: 0, dy: speed))
    }

    /// 急降下中（突っ込み）の状態。
    static let attacking = EnemyMotion.diving(Dive(purpose: .attack, velocity: Velocity(dx: 0, dy: 4), elapsed: 20))
}
