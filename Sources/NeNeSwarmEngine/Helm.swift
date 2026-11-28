/// 誰が自機を操作しているか（FR-19・ADR 0013）。刻みの数だけで決める（Engine は時計を知らない）。
///
/// 人が遊びのキーに触れた刻みから `handBack` 刻みの間は人、そのあとは AI。押しっぱなしの間は毎刻み触れたことに数える。
/// 一度も触れなければずっと AI で、そのとき刻みのループはこの型が無かったときと同じ値だけを使う
/// （パイロットの乱数の引き方も同じ。AI だけのプレイは 1 コマも変わらない）。
public struct Helm: Sendable, Hashable {
    /// 人が触れなくなってから AI に戻るまでの刻み（1 以上）。
    public let handBack: Int
    /// 人の番の残りの刻み（0 なら AI）。
    private var remaining = 0

    /// AI の番から始める。
    public init(handBack: Int) {
        precondition(handBack >= 1, "AI に戻るまでの刻みは 1 以上")
        self.handBack = handBack
    }

    /// 人の番か。
    public var isHuman: Bool {
        remaining > 0
    }

    /// AI に戻るまでの残りの刻み（AI の番なら 0）。
    public var ticksLeft: Int {
        remaining
    }

    /// 1 刻み分を進める。刻みの入力を決める前に、毎刻み 1 回だけ呼ぶ。
    /// `touched` はこの刻みに人が遊びのキーを押していたか（押しっぱなしと、前の刻みの後に押して離した打鍵を含む）。
    public mutating func advance(touched: Bool) {
        if touched {
            remaining = handBack
        } else if remaining > 0 {
            remaining -= 1
        }
    }
}
