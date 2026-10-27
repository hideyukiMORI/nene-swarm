@testable import NeNeSwarmCore

/// テストの中だけのパイロット（本物のパイロットは Engine に Phase 3-4 で入る）。どれも Core の公開の状態だけを読む。
enum TestPilot: CaseIterable {
    /// 乱数で左右に動いて撃つ。
    case random
    /// 一番近い敵の下へ動いて撃ち、真上から来る弾を避ける。
    case chaser

    func input(for game: Game, using generator: inout some RandomNumberGenerator) -> PilotInput {
        let trigger: Trigger = game.canFire ? .fire : .hold
        guard case .active(let ship) = game.ship else {
            return .idle
        }
        let wanted: Steer
        switch self {
        case .random:
            wanted = Steer.allCases.randomElement(using: &generator) ?? .hold
        case .chaser:
            wanted = TestPilot.chase(ship, in: game)
        }
        return PilotInput(steer: game.canSteer(wanted) ? wanted : .hold, trigger: trigger)
    }

    private static func chase(_ ship: Ship, in game: Game) -> Steer {
        let center = ship.x + ship.span / 2
        let danger = game.enemyShots.contains { shot in
            abs(shot.box.centerX - center) < ship.span && shot.position.y > Field.units(10)
        }
        if danger {
            return center < Field.width / 2 ? .right : .left
        }
        let targets = game.enemies.filter(\.motion.isSolid).map(\.box.centerX)
        guard let target = targets.min(by: { abs($0 - center) < abs($1 - center) }) else {
            return .hold
        }
        if target < center - Ship.speed {
            return .left
        }
        return target > center + Ship.speed ? .right : .hold
    }
}
