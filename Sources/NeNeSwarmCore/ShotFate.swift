/// 敵の弾を 1 刻み進めた結果。
enum ShotFate {
    /// まだ飛んでいる。
    case flying(Shot)
    /// 何かに当たったか、画面の外へ抜けた。
    case spent
    /// 自機の最後の 1 機に当たった（ほかの弾も消す）。
    case shipLost
}
