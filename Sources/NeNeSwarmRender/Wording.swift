import NeNeSwarmCore

/// 画面の文言（英語・ASCII だけ）。文言を持つのはここだけ。
enum Wording {
    static let title = "NENE//SWARM"
    static let tagline = "A FIXED SHOOTER THAT PLAYS ITSELF"
    static let quitKey = "[q]"
    static let quitName = " QUIT  "
    static let themeKey = "[t]"
    static let themeName = " THEME "
    static let difficultyKey = "[d]"
    static let difficultyName = " DIFFICULTY "

    static func game(_ number: Int) -> String {
        "GAME " + digits(number, 3)
    }

    static func seed(_ seed: UInt64) -> String {
        let hex = String(seed, radix: 16, uppercase: true)
        return "SEED 0x" + String(repeating: "0", count: max(16 - hex.count, 0)) + hex
    }

    static func colors(_ mode: ColorMode) -> String {
        switch mode {
        case .trueColor: "24BIT"
        case .palette256: "256"
        }
    }

    static func difficulty(_ difficulty: Difficulty) -> String {
        switch difficulty {
        case .easy: "EASY"
        case .normal: "NORMAL"
        case .hard: "HARD"
        }
    }

    static func ending(_ ending: GameEnding) -> String {
        switch ending {
        case .outOfShips: "OUT OF SHIPS"
        case .invaded: "THE SWARM LANDED"
        case .timeLimit: "TIME UP"
        }
    }

    static func stageBanner(_ stage: Stage) -> String {
        switch stage.kind {
        case .combat: "STAGE " + String(stage.number)
        case .bonus: "BONUS STAGE"
        }
    }

    static let stageClear = "STAGE CLEAR"
    static let gameOver = "GAME OVER"
    static let highScores = "HIGH SCORES"
    static let newRecord = "NEW RECORD"
    static let standby = "STANDBY"

    static func tooSmall(need: ScreenSize) -> String {
        "TERMINAL TOO SMALL: NEED \(need.columns)x\(need.rows)"
    }

    /// 0 で左を埋めた `width` 桁の数（収まらなければそのまま）。
    static func digits(_ value: Int, _ width: Int) -> String {
        let text = String(value)
        return String(repeating: "0", count: max(width - text.count, 0)) + text
    }
}
