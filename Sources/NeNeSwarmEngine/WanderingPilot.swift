import NeNeSwarmCore

/// 乱数で動いて撃つだけの仮のパイロット（Phase 3-2）。本物のパイロットとキャストは Phase 3-4 で入る。
///
/// しばらく同じ向きへ動き続け、ときどき向きを変える（毎刻み乱数で変えると、その場で震えて見える）。撃てるときは撃つ。
/// 入力はいつも合法（端より外へ動かない・撃てないときは撃たない）。状態は持つが、Core の状態は書き換えない（ARC-004）。
public struct WanderingPilot: Sendable, Hashable {
    /// いま向かっている向き。
    private var heading: Steer
    /// 向きを変えるまでの残りの刻み。
    private var ticksLeft: Int

    /// 止まった状態で始める。
    public init() {
        heading = .hold
        ticksLeft = 0
    }

    /// 1 刻みの入力を決める。
    public mutating func input(for game: Game, using generator: inout some RandomNumberGenerator) -> PilotInput {
        ticksLeft -= 1
        if ticksLeft <= 0 || !game.canSteer(heading) {
            heading = Steer.allCases.randomElement(using: &generator) ?? .hold
            ticksLeft = Int.random(in: 6...30, using: &generator)
        }
        let steer = game.canSteer(heading) ? heading : .hold
        return PilotInput(steer: steer, trigger: game.canFire ? .fire : .hold)
    }
}
