import Testing

@testable import NeNeSwarmCore
@testable import NeNeSwarmEngine

/// 人と AI の入れ替わり（FR-19・ADR 0013）。刻みのループは合成ルートの `Screensaver.tick` と同じ順で回す。
struct HelmTests {
    /// 合成ルートの刻みのループを写したもの（時計と端末を除く）。`touches` の刻みに人が `human` を押す。
    struct Loop {
        var generator: SplitMix64
        var pilotGenerator: SplitMix64
        var pilot = Pilot(persona: .sniper)
        var session = Session(durations: SceneDurations(titleTicks: 30, gameOverTicks: 30))
        var helm: Helm
        var humanTicks = 0

        init(seed: UInt64, handBack: Int) {
            generator = SplitMix64(seed: seed)
            pilotGenerator = SplitMix64(seed: seed ^ 0x5357_4152_4D21)
            helm = Helm(handBack: handBack)
        }

        mutating func tick(human: PilotInput?) -> SessionStep {
            helm.advance(touched: human != nil)
            var input = PilotInput.idle
            if case .play(let game) = session.scene {
                if helm.isHuman {
                    input = human ?? .idle
                    humanTicks += 1
                } else {
                    input = pilot.input(for: game, difficulty: .normal, using: &pilotGenerator)
                }
            }
            let step = session.step(input, difficulty: .normal, using: &generator)
            session = step.session
            for event in step.events {
                if case .gameStarted = event {
                    pilot = Pilot(persona: .sniper)
                }
            }
            return step
        }
    }

    /// 2 つの乱数源が同じ位置にあるか（写しから次の値を引いて比べる）。
    static func same(_ first: SplitMix64, _ second: SplitMix64) -> Bool {
        var (first, second) = (first, second)
        return first.next() == second.next()
    }

    static func inCombat(_ session: Session) -> Bool {
        guard case .play(let game) = session.scene, case .combat = game.phase else {
            return false
        }
        return true
    }

    @Test func itStartsWithTheAutopilot() {
        let helm = Helm(handBack: 900)
        #expect(!helm.isHuman)
        #expect(helm.ticksLeft == 0)
    }

    /// 触れた刻みを含めて `handBack` 刻みは人、その次の刻みから AI。
    @Test func aTouchHandsTheShipToThePlayerForExactlyTheHandBack() {
        var helm = Helm(handBack: 5)
        helm.advance(touched: true)
        #expect(helm.isHuman)
        #expect(helm.ticksLeft == 5)
        for left in [4, 3, 2, 1] {
            helm.advance(touched: false)
            #expect(helm.isHuman)
            #expect(helm.ticksLeft == left)
        }
        helm.advance(touched: false)
        #expect(!helm.isHuman)
        helm.advance(touched: false)
        #expect(helm.ticksLeft == 0)
    }

    /// 押しっぱなしの間は数え直し続け、離してから `handBack` 刻みで AI に戻る。
    @Test func holdingAKeyKeepsThePlayerFlying() {
        var helm = Helm(handBack: 3)
        for _ in 0..<100 {
            helm.advance(touched: true)
            #expect(helm.ticksLeft == 3)
        }
        helm.advance(touched: false)
        helm.advance(touched: false)
        #expect(helm.isHuman)
        helm.advance(touched: false)
        #expect(!helm.isHuman)
    }

    /// 誰も触れなければ、`Helm` を通したループは `Helm` の無いループと同じ状態・同じ乱数の列になる（AI だけのプレイは変わらない）。
    @Test(arguments: [UInt64(1), 0xDEAD_BEEF])
    func anUntouchedHelmChangesNothing(_ seed: UInt64) {
        var loop = Loop(seed: seed, handBack: 900)
        var generator = SplitMix64(seed: seed)
        var pilotGenerator = SplitMix64(seed: seed ^ 0x5357_4152_4D21)
        var pilot = Pilot(persona: .sniper)
        var session = Session(durations: SceneDurations(titleTicks: 30, gameOverTicks: 30))
        for tick in 0..<6_000 {
            _ = loop.tick(human: nil)
            var input = PilotInput.idle
            if case .play(let game) = session.scene {
                input = pilot.input(for: game, difficulty: .normal, using: &pilotGenerator)
            }
            let step = session.step(input, difficulty: .normal, using: &generator)
            session = step.session
            for event in step.events {
                if case .gameStarted = event {
                    pilot = Pilot(persona: .sniper)
                }
            }
            guard loop.session == session, Self.same(loop.generator, generator),
                Self.same(loop.pilotGenerator, pilotGenerator)
            else {
                Issue.record("seed \(seed): tick \(tick) でずれた")
                return
            }
        }
        #expect(loop.humanTicks == 0)
    }

    /// 人の入力がそのまま自機に効き、手を離して `handBack` 刻み後に AI が引き継いで、ゲームはいつか終わる。
    @Test func thePlayerSteersAndTheAutopilotTakesBack() {
        var loop = Loop(seed: 7, handBack: 90)
        while !Self.inCombat(loop.session) {
            _ = loop.tick(human: nil)
        }
        let pilotBefore = loop.pilotGenerator
        for _ in 0..<60 {
            _ = loop.tick(human: PilotInput(steer: .left, trigger: .fire))
        }
        guard case .play(let game) = loop.session.scene, case .active(let ship) = game.ship else {
            Issue.record("60 刻みの間に自機を失った")
            return
        }
        #expect(ship.x == 0)
        #expect(game.score > 0 || !game.playerShots.isEmpty)
        #expect(Self.same(loop.pilotGenerator, pilotBefore))
        for _ in 0..<89 {
            _ = loop.tick(human: nil)
        }
        #expect(loop.helm.isHuman)
        #expect(Self.same(loop.pilotGenerator, pilotBefore))
        _ = loop.tick(human: nil)
        #expect(!loop.helm.isHuman)
        var ended = false
        for _ in 0..<200_000 where !ended {
            ended = loop.tick(human: nil).events.contains { event in
                if case .gameEnded = event {
                    return true
                }
                return false
            }
        }
        #expect(ended)
        #expect(loop.humanTicks == 149)
    }
}
