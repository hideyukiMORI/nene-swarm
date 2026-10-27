import NeNeSwarmCore

/// パイロット（FR-04・ADR 0008）。Core の公開の状態を読み、入力だけを返す（ARC-004）。
///
/// 毎刻み、左・右・止まるの 3 つを `persona.foresight` 刻み先まで Core の 1 刻み関数で進めてみて、自機を失わない向きのうち、
/// 狙う位置に近づくものを選ぶ。どれも当たるなら、当たるのがいちばん遅い向きを選ぶ。危険を見落とすことがあり（`blindness`）、
/// 狙いは少しずれる（`jitter`）。だから完璧ではなく、敵が強まるといつか必ず落ちる。
public struct Pilot: Sendable, Hashable {
    /// 乗っている性格。
    public let persona: Persona
    /// いまの狙いのずれ。
    private var offset = 0
    /// ずれを選び直すまでの刻み。
    private var offsetTicks = 0

    /// 性格を乗せる。
    public init(persona: Persona) {
        self.persona = persona
    }

    /// 1 刻みの入力を決める。いつも合法（端より外へ動かない・撃てないときは撃たない）。
    ///
    /// 難易度は先読みで敵の速さを読むためだけに使う。パイロットの腕（性格の数）は難易度で変わらない（FR-14）。
    public mutating func input(
        for game: Game, difficulty: Difficulty, using generator: inout some RandomNumberGenerator
    ) -> PilotInput {
        guard case .active(let ship) = game.ship else {
            return .idle
        }
        refreshOffset(using: &generator)
        let aim = Aim(game: game, ship: ship, persona: persona)
        let goal = aim.goalX + offset
        let careless = Int.random(in: 0..<1000, using: &generator) < persona.blindness
        let steer = Foresight(game: game, persona: persona, difficulty: difficulty).choose(
            toward: goal, center: aim.center, careless: careless)
        let fire = game.canFire && aim.isLinedUp && !aim.captiveInLine
        return PilotInput(steer: steer, trigger: fire ? .fire : .hold)
    }

    private mutating func refreshOffset(using generator: inout some RandomNumberGenerator) {
        offsetTicks -= 1
        guard offsetTicks <= 0 else {
            return
        }
        offset = Int.random(in: -persona.jitter...persona.jitter, using: &generator)
        offsetTicks = Int.random(in: 10...30, using: &generator)
    }
}
