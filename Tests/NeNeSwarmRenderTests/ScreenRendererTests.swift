import NeNeSwarmCore
import Testing

@testable import NeNeSwarmEngine
@testable import NeNeSwarmRender

/// 1 画面分の格子（FR-07・FR-10・FR-13・FR-16・FR-17・ADR 0007）。
struct ScreenRendererTests {
    static let boxed = DisplayOptions(theme: .standard, traits: TerminalTraits(frame: .boxDrawing, colors: .trueColor))
    static let size = ScreenSize(columns: 80, rows: 24)

    /// シード 9 の場面を `ticks` 刻み進めたもの（仮のパイロットが遊ぶ）。
    static func session(ticks: Int) -> Session {
        var generator = SplitMix64(seed: 9)
        var pilotGenerator = SplitMix64(seed: 10)
        var pilot = Pilot(persona: .sniper)
        var session = Session(durations: SceneDurations(titleTicks: 30, gameOverTicks: 30))
        for _ in 0..<ticks {
            var input = PilotInput.idle
            if case .play(let game) = session.scene {
                input = pilot.input(for: game, difficulty: .normal, using: &pilotGenerator)
            }
            session = session.step(input, difficulty: .normal, using: &generator).session
        }
        return session
    }

    static func render(
        _ session: Session, display: DisplayOptions = boxed, size: ScreenSize = size, remark: Remark? = nil
    ) -> Grid {
        let state = ScreenState(
            session: session, display: display, difficulty: .normal, seed: 9, highScores: .empty, persona: .sniper,
            remarks: remark.map { [$0] } ?? [], effects: Effects(), storage: .file)
        return ScreenRenderer.render(state, size: size)
    }

    static func text(_ grid: Grid) -> String {
        (0..<grid.size.rows).map { row in String((0..<grid.size.columns).map { grid[$0, row].character }) }
            .joined(separator: "\n")
    }

    @Test func theScreenFitsEightyByTwentyFour() {
        #expect(ScreenRenderer.minimumSize == ScreenSize(columns: 80, rows: 24))
    }

    @Test(arguments: [0, 40, 400, 2_000])
    func keyHelpAndHeaderAreAlwaysShown(_ ticks: Int) {
        let text = Self.text(Self.render(Self.session(ticks: ticks)))
        #expect(text.contains("[q] QUIT"))
        #expect(text.contains("[t] THEME NEON"))
        #expect(text.contains("[d] DIFFICULTY NORMAL"))
        #expect(text.contains("NENE//SWARM"))
        #expect(text.contains("STATUS"))
    }

    @Test func theTitleShowsTheHighScoreTable() {
        let text = Self.text(Self.render(Self.session(ticks: 0)))
        #expect(text.contains("HIGH SCORES"))
        #expect(text.contains("GAME 001"))
    }

    /// ステージの始まりは、大きな文字の帯を塗って出す（点は空白のセル・FR-02f）。
    @Test func aStageOpensWithABigBanner() {
        let grid = Self.render(Self.session(ticks: 40))
        let layout = ScreenLayout.compact
        let pixels = BigFont.pixels("STAGE 1")
        let left = layout.fieldColumn + (ScreenLayout.fieldWidth - BigFont.span("STAGE 1")) / 2
        for (row, cells) in pixels.enumerated() {
            for (offset, lit) in cells.enumerated() {
                let cell = grid[left + offset, layout.fieldRow + 9 + row]
                #expect((cell.background == Theme.standard.spark) == lit)
                #expect(!lit || cell.character == " ")
            }
        }
    }

    /// 自機・敵・弾・トーチカのセルは空白で、背景だけが色になる（FR-07）。盤面の中で地の色でないセルに文字は無い。
    @Test(arguments: [100, 300, 600, 900])
    func spritesArePaintedCellsWithoutCharacters(_ ticks: Int) {
        let session = Self.session(ticks: ticks)
        guard case .play(let game) = session.scene, case .combat = game.phase else {
            return
        }
        let grid = Self.render(session)
        let layout = ScreenLayout.compact
        var painted = 0
        for row in layout.fieldRow..<(layout.fieldRow + ScreenLayout.fieldHeight) {
            for column in layout.fieldColumn..<(layout.fieldColumn + ScreenLayout.fieldWidth) {
                let cell = grid[column, row]
                if cell.background != Theme.standard.ground {
                    painted += 1
                    #expect(cell.character == " ")
                }
            }
        }
        #expect(painted > 0)
    }

    @Test func aSmallTerminalGetsOneLine() {
        let grid = Self.render(Self.session(ticks: 0), size: ScreenSize(columns: 40, rows: 10))
        #expect(Self.text(grid).hasPrefix("TERMINAL TOO SMALL: NEED 80x24"))
    }

    @Test func anAsciiFrameIsUsedWhenBoxDrawingIsWide() {
        let ascii = DisplayOptions(theme: .standard, traits: TerminalTraits(frame: .ascii, colors: .trueColor))
        let text = Self.text(Self.render(Self.session(ticks: 0), display: ascii))
        #expect(text.contains("+-[ STATUS ]"))
        #expect(!text.contains("┌"))
    }

    @Test func everyThemeHasAName() {
        #expect(Theme.catalog.count == 12)
        #expect(Set(Theme.catalog.map(\.name)).count == 12)
        #expect(Theme.named("phosphor")?.name == "PHOSPHOR")
        #expect(Theme.catalog.last?.next == Theme.standard)
    }

    /// COMMS 欄に話し手の名前と顔と、折り返したセリフが出る（FR-15）。
    @Test func commsShowsTheSpeakerAndTheWrappedLine() {
        let remark = Remark(persona: .lucky, cue: .hit, text: "Lost a chip. I have more chips. Do I have more chips?")
        let text = Self.text(Self.render(Self.session(ticks: 200), remark: remark))
        #expect(text.contains("COMMS"))
        #expect(text.contains("LUCKY.INI (^o^)"))
        #expect(text.contains("Lost a chip. I have"))
        #expect(text.contains("more chips?"))
    }

    @Test func wrappingKeepsWordsWithinTheWidth() {
        let lines = Wording.wrap("Twenty-two to one. I like those odds. I like all odds.", width: 21)
        #expect(lines == ["Twenty-two to one. I", "like those odds. I", "like all odds."])
        #expect(Wording.wrap("abcdefghijklmnopqrstuvwxyz", width: 10) == ["abcdefghij"])
    }

    /// 100 × 26 以上では 2 段目の配置: 広い HUD にハイスコアの表、盤面の下に COMMS の直近 2 行（FR-17）。
    @Test func aLargeTerminalGetsTheWideHudAndTwoCommsLines() {
        #expect(ScreenRenderer.largeSize == ScreenSize(columns: 100, rows: 26))
        let older = Remark(persona: .nervous, cue: .stageStart, text: "They're moving. Why are they moving?")
        let newer = Remark(persona: .nervous, cue: .hit, text: "I knew it. I KNEW it.")
        let state = ScreenState(
            session: Self.session(ticks: 200), display: Self.boxed, difficulty: .easy, seed: 9,
            highScores: HighScoreTable(entries: [
                HighScore(score: 4_321, pilot: "NERVOUS.TMP", stage: 4, difficulty: .easy)
            ]),
            persona: .nervous, remarks: [older, newer], effects: Effects(), storage: .file)
        let large = Self.text(ScreenRenderer.render(state, size: ScreenRenderer.largeSize))
        #expect(large.contains("HIGH SCORES"))
        #expect(large.contains("0004321  NERVOUS.TMP"))
        #expect(large.contains("They're moving. Why are they moving?"))
        #expect(large.contains("I knew it. I KNEW it."))
        #expect(large.contains("[q] QUIT"))
        let compact = Self.text(ScreenRenderer.render(state, size: ScreenSize(columns: 99, rows: 26)))
        #expect(compact.contains("COMMS"))
        #expect(!compact.contains("They're moving."))
    }
}
