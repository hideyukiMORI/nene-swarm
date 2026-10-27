/// 1 刻みで起きたこと。セリフと演出の入力になる（Render と Engine が読む）。
public enum GameEvent: Sendable, Hashable {
    /// ステージが始まった。
    case stageStarted(Stage)
    /// ステージを終えた。
    case stageCleared(Stage)
    /// 敵を倒した（種類・得点・倒した場所）。
    case enemyDestroyed(EnemyKind, points: Int, at: Point)
    /// 親玉に 1 発当たった（まだ倒れない）。
    case flagshipDamaged(at: Point)
    /// UFO を倒した（得点・場所）。
    case saucerDestroyed(points: Int, at: Point)
    /// 1 機だけの自機を失った。
    case shipDestroyed(HitCause)
    /// 2 機並びの片方を失った。
    case wingLost(HitCause)
    /// 捕獲ビームに捕まった。
    case shipCaptured
    /// 次の 1 機が出た。
    case shipRespawned
    /// 捕虜を救出した。
    case captiveRescued(RescueOutcome)
    /// 隊列にいる親玉を倒したので、捕虜は戻らなかった。
    case captiveLost
    /// 捕虜を自分で撃ってしまった。
    case captiveShot
    /// 敵の弾が自機のすぐ横をかすめた。
    case nearMiss
    /// ボーナスステージで全部倒した（ボーナスの得点）。
    case perfect(bonus: Int)
    /// ゲームが終わった。
    case gameOver(GameEnding)
}
