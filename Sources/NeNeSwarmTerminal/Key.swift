/// 端末から読み取れるキー（閉じた集合）。どのキーが何の操作かは合成ルートが決める（FR-19・ADR 0013）。
///
/// 移植元: NeNe Bolt `Sources/NeNeBoltTerminal/Key.swift`（コミット 072d08a）。上下と `x` を落とした。
public enum Key: Sendable, Hashable, CaseIterable {
    case left
    case right
    case z
    case space
    case q
    case t
    case d
    /// Ctrl+C。押す・離すを受け取る方式では SIGINT ではなくキーとして届く。
    case interrupt
}
