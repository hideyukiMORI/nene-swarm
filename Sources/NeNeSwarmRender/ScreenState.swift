import NeNeSwarmCore
import NeNeSwarmEngine

/// 1 画面を描くのに要るすべての値（ARC-011: Render はこれを描くだけ）。持ち主は合成ルート。
public struct ScreenState: Sendable {
    /// 場面の列。
    public let session: Session
    /// テーマと端末の性質。
    public let display: DisplayOptions
    /// いまの難易度（`d` で巡る）。
    public let difficulty: Difficulty
    /// ゲームの列のシード（画面に出す）。
    public let seed: UInt64
    /// ハイスコアの表。
    public let highScores: HighScoreTable
    /// 乗っている（TITLE では次に乗る）パイロット。
    public let persona: Persona

    /// 組を作る。
    public init(
        session: Session, display: DisplayOptions, difficulty: Difficulty, seed: UInt64, highScores: HighScoreTable,
        persona: Persona
    ) {
        self.session = session
        self.display = display
        self.difficulty = difficulty
        self.seed = seed
        self.highScores = highScores
        self.persona = persona
    }

    /// 画面に出すゲームの番号（TITLE では次に始まるゲーム）。
    var gameNumber: Int {
        switch session.scene {
        case .title: session.gamesStarted + 1
        case .play, .gameOver: session.gamesStarted
        }
    }
}
