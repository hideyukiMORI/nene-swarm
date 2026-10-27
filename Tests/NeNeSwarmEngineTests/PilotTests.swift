import Testing

@testable import NeNeSwarmCore
@testable import NeNeSwarmEngine

/// パイロットとキャスト（FR-04・FR-14・Q4・Q6・REQUIREMENTS 第 3 節・ADR 0008）。重いので release 構成で回す。
struct PilotTests {
    /// 難易度ごと・パイロットごとに回すシードの数。黙って下げない（ADR 0008）。
    static let seeds = 12

    /// 1 ゲームを終わりまで回す。入力が合法でなければ記録する。
    static func play(_ persona: Persona, _ difficulty: Difficulty, seed: UInt64) -> Game {
        var generator = SplitMix64(seed: seed)
        var pilotGenerator = SplitMix64(seed: seed ^ 0xABC_DEF)
        var pilot = Pilot(persona: persona)
        var game = Game()
        while case .running = game.status {
            let input = pilot.input(for: game, difficulty: difficulty, using: &pilotGenerator)
            if !game.canSteer(input.steer) {
                Issue.record("\(persona.name) seed \(seed): 動けない向き \(input.steer)")
            }
            if case .fire = input.trigger, !game.canFire {
                Issue.record("\(persona.name) seed \(seed): 撃てないときに撃った")
            }
            game = game.step(input, difficulty: difficulty, using: &generator).game
        }
        return game
    }

    /// 入力はいつも合法で、どのゲームも刻みの上限に届かずに終わり、平均の寿命は EASY ≥ NORMAL ≥ HARD。
    @Test(arguments: Persona.roster)
    func everyPilotPlaysLegallyAndHarderDifficultiesEndSooner(_ persona: Persona) {
        let lifetimes = Difficulty.allCases.map { difficulty in
            (0..<UInt64(Self.seeds)).reduce(0) { sum, seed in
                let game = Self.play(persona, difficulty, seed: seed)
                if case .over(.timeLimit) = game.status {
                    Issue.record("\(persona.name) seed \(seed): 刻みの上限に達した")
                }
                return sum + game.tick
            }
        }
        #expect(lifetimes[0] >= lifetimes[1])
        #expect(lifetimes[1] >= lifetimes[2])
    }

    /// 4 名で、名前は `ファイル名.拡張子` 風・顔は ASCII・兄弟のキャストと重ならない（Q6）。
    @Test func theCastHasFourNewMembers() {
        let siblings = [
            "VEX.EXE", "MORT.SH", "NULL_PTR", "GRANNY.DLL", "FLIP.BAT", "CORNER.SYS", "SPAM.EML", "LAZY.CRON",
            "SENTE.SYS", "TENUKI.LOG", "MOYO.PNG", "SEKI.LCK", "BLUFF.EXE", "NIT.BAK", "ODDS.CSV", "TILT.SH",
        ]
        let names = Persona.roster.map(\.name)
        #expect(names.count == 4)
        #expect(Set(names).count == 4)
        #expect(names.allSatisfy { $0.contains(".") && !siblings.contains($0) })
        #expect(Persona.roster.allSatisfy { $0.face.unicodeScalars.allSatisfy(\.isASCII) })
        #expect(Persona.roster.contains { $0.seeksCapture })
        #expect(Persona.roster.contains { !$0.seeksCapture })
    }

    /// 先読みの乱数源は、千分率の確率をどれも「起きない」側に倒す（先読みの中で新しい弾も急降下も始まらない）。
    @Test func theCalmSourceNeverRollsUnderAnyChance() {
        var calm = Calm()
        let roll = Int.random(in: 0..<1000, using: &calm)
        #expect(roll == 999)
    }

    /// 2 機並びが欲しくない性格は、伸びてくるビームの下から逃げる。
    @Test func aCarefulPilotLeavesTheGrowingBeam() {
        var game = Game()
        game.phase = .combat
        let flagship = Enemy(
            id: 0, kind: .flagship, slot: Slot(column: 0, row: 0), position: Point(x: 192, y: Game.captureAltitude))
        game.enemies = [flagship]
        game.enemies[0].motion = .beaming(ticksLeft: Game.beamTicks)
        game.ship = .active(Ship(x: 192, wing: .single))
        var pilot = Pilot(persona: .sniper)
        var generator = SplitMix64(seed: 1)
        var pilotGenerator = SplitMix64(seed: 2)
        var events: [GameEvent] = []
        for _ in 0..<Game.beamTicks {
            let input = pilot.input(for: game, difficulty: .normal, using: &pilotGenerator)
            let step = game.step(input, difficulty: .normal, using: &generator)
            events += step.events
            game = step.game
        }
        #expect(!events.contains(.shipCaptured))
    }
}
