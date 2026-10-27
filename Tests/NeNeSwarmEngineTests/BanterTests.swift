import Testing

@testable import NeNeSwarmCore
@testable import NeNeSwarmEngine

/// パイロットのセリフ（FR-15・ADR 0009）。
struct BanterTests {
    static func hear(_ events: [GameEvent], ships: Int? = 3, record: Bool = false) -> Hearing {
        Hearing(events: events.map(SessionEvent.game), shipsInPlay: ships, newRecord: record)
    }

    /// 4 名とも 50 本で、どのきっかけにもセリフがあり、1 名の中で同じセリフは無い。
    @Test(arguments: Persona.roster)
    func everyPilotHasFiftyLinesCoveringEveryCue(_ persona: Persona) {
        #expect(persona.script.count == 50)
        #expect(Set(persona.script.map(\.text)).count == 50)
        for cue in Cue.allCases {
            #expect(persona.lines(for: cue).count >= 3, "\(persona.name) \(cue)")
        }
        #expect(persona.script.allSatisfy { $0.text.unicodeScalars.allSatisfy(\.isASCII) })
    }

    @Test func mustSayCuesAlwaysSpeakEvenRightAfterAnotherLine() {
        var banter = Banter()
        var generator = SplitMix64(seed: 1)
        banter.listen(Self.hear([.shipDestroyed(.shot)]), persona: .blaster, using: &generator)
        #expect(banter.latest?.cue == .hit)
        banter.listen(Self.hear([.shipCaptured]), persona: .blaster, using: &generator)
        #expect(banter.latest?.cue == .captured)
        let gameOver = Hearing(events: [.gameEnded(Self.summary)], shipsInPlay: nil, newRecord: false)
        banter.listen(gameOver, persona: .blaster, using: &generator)
        #expect(banter.latest?.cue == .gameOver)
    }

    @Test func aNewRecordReplacesTheGameOverLine() {
        var banter = Banter()
        var generator = SplitMix64(seed: 2)
        banter.listen(
            Hearing(events: [.gameEnded(Self.summary)], shipsInPlay: nil, newRecord: true), persona: .lucky,
            using: &generator)
        #expect(banter.latest?.cue == .newRecord)
    }

    @Test func optionalCuesWaitForTheQuietPeriod() {
        var banter = Banter()
        var generator = SplitMix64(seed: 3)
        banter.listen(Self.hear([.shipDestroyed(.shot)]), persona: .sniper, using: &generator)
        let first = banter.latest
        for _ in 0..<20 {
            banter.listen(Self.hear([.nearMiss]), persona: .sniper, using: &generator)
        }
        #expect(banter.latest == first)
    }

    @Test func threeKillsInAShortTimeAreAStreak() {
        var banter = Banter()
        var generator = SplitMix64(seed: 4)
        var said: [Cue] = []
        for seed in 0..<40 {
            banter = Banter()
            generator = SplitMix64(seed: UInt64(seed))
            let kill = GameEvent.enemyDestroyed(.drone, points: 50, at: Point(x: 0, y: 0))
            for _ in 0..<3 {
                banter.listen(Self.hear([kill]), persona: .blaster, using: &generator)
            }
            if let cue = banter.latest?.cue {
                said.append(cue)
            }
        }
        #expect(said.contains(.streak))
        #expect(said.allSatisfy { $0 == .streak })
    }

    @Test func droppingToTheLastShipIsSaid() {
        var banter = Banter()
        var generator = SplitMix64(seed: 5)
        banter.listen(Self.hear([], ships: 2), persona: .nervous, using: &generator)
        banter.listen(Self.hear([], ships: 1), persona: .nervous, using: &generator)
        #expect(banter.latest?.cue == .lastShip)
    }

    @Test func theSameSeedSaysTheSameThings() {
        func run() -> [Remark?] {
            var banter = Banter()
            var generator = SplitMix64(seed: 9)
            return (0..<30).map { _ in
                banter.listen(Self.hear([.shipDestroyed(.rammed)]), persona: .lucky, using: &generator)
                return banter.latest
            }
        }
        #expect(run() == run())
    }

    @Test func aPilotDoesNotRepeatItsLastEightLines() {
        var banter = Banter()
        var generator = SplitMix64(seed: 6)
        var said: [String] = []
        for _ in 0..<5 {
            banter.listen(Self.hear([.shipDestroyed(.shot)]), persona: .sniper, using: &generator)
            said.append(banter.latest?.text ?? "")
        }
        #expect(Set(said).count == 5)
    }

    static let summary = GameSummary(
        score: 100, stage: Stage(number: 2), ending: .outOfShips, difficulty: .normal, ticks: 10)
}
