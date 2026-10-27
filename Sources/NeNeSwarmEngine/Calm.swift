/// 先読みのための乱数源。いつも最大の値を返すので、先読みの中では新しい弾も急降下も始まらない
/// （千分率の確率はどれも「起きない」側に倒れる）。いま見えている危険だけを先へ進めるために使う（ADR 0008）。
struct Calm: RandomNumberGenerator {
    mutating func next() -> UInt64 {
        .max
    }
}
