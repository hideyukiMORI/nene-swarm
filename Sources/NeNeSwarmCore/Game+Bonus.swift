/// ボーナスステージの編隊（FR-02d）。左右から交互に 4 つの波が入り、弧を描いて上へ抜ける。撃ってこない。
extension Game {
    /// 最初の波が入るまでの刻みの数。
    static let firstWaveTick = 30
    /// 波の間隔（刻み）。
    static let waveInterval = 100
    /// 同じ波の中の 1 機ごとの間隔（刻み）。
    static let wingmanInterval = 8
    /// 編隊の横の速さ。
    static let flybySpeed = 5
    /// 弧の向きを 1 変える間隔（刻み）。
    static let flybyBend = 6

    mutating func spawnFlyby() {
        bonus.elapsed += 1
        while bonus.spawned < BonusProgress.total, bonus.elapsed >= Game.spawnTick(of: bonus.spawned) {
            let wave = bonus.spawned / BonusProgress.perWave
            let fromLeft = wave % 2 == 0
            var enemy = Enemy(
                id: 1000 + bonus.spawned,
                kind: fromLeft ? .escort : .drone,
                slot: Slot(column: bonus.spawned % BonusProgress.perWave, row: wave),
                position: Point(x: fromLeft ? -Enemy.width : Field.width, y: Field.units(3))
            )
            enemy.hitsLeft = 1
            enemy.motion = .flyby(
                Flight(
                    velocity: Velocity(dx: fromLeft ? Game.flybySpeed : -Game.flybySpeed, dy: 4),
                    elapsed: 0))
            enemies.append(enemy)
            bonus.spawned += 1
        }
    }

    private static func spawnTick(of index: Int) -> Int {
        firstWaveTick + index / BonusProgress.perWave * waveInterval + index % BonusProgress.perWave * wingmanInterval
    }

    /// 通り抜けを 1 刻み進める。下向きの速さが少しずつ減り、上向きに変わって画面の外へ抜ける。
    static func flown(_ enemy: Enemy, flight: Flight) -> Enemy {
        var next = enemy
        let elapsed = flight.elapsed + 1
        let bend = elapsed % flybyBend == 0 ? 1 : 0
        let velocity = Velocity(dx: flight.velocity.dx, dy: max(-5, flight.velocity.dy - bend))
        next.position = enemy.position.moved(by: velocity)
        next.motion = .flyby(Flight(velocity: velocity, elapsed: elapsed))
        return next
    }

    /// 通り抜けて画面の外へ出たか（入ってくる途中は数えない）。
    static func hasFlownAway(_ enemy: Enemy) -> Bool {
        guard case .flyby(let flight) = enemy.motion else {
            return false
        }
        return flight.elapsed > 2 * flybyBend && !enemy.box.isOnField
    }
}
