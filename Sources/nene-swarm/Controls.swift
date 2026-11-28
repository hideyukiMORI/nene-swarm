import NeNeSwarmCore
import NeNeSwarmTerminal

/// 人のキー（FR-19・ADR 0013）。キーと入力の対応は遊びの決まりなので合成ルートが持つ（ADR 0004）。
///
/// 遊びのキーは ← →（動く）と Space・`z`（撃つ）。`q` `t` `d` はスクリーンセーバーのキーで、遊びのキーに数えない。
/// 誰が操作しているかは Engine の `Helm` が刻みの数で決め、ここは「この刻みに押しているか」だけを渡す。
/// 移植元: NeNe Bolt `Sources/nene-bolt/Controls.swift`（コミット 072d08a）。人の番の判定を `Helm` へ移し、ボタンを `PilotInput` に替えた。
struct Controls {
    /// スクリーンセーバーのキー。
    enum Command {
        case quit
        case cycleTheme
        case cycleDifficulty
    }

    private var held = HeldKeys()

    /// 届いたバイト列を反映し、スクリーンセーバーのキーを返す（届いた順）。
    mutating func receive(_ bytes: [UInt8], at now: Int) -> [Command] {
        var commands: [Command] = []
        for event in KeyDecoder.decode(bytes).events {
            if let command = Controls.command(event) {
                commands.append(command)
            } else if Controls.isPlayKey(event.key) {
                held.apply(event, at: now)
            }
        }
        return commands
    }

    /// この刻みに人が押している遊びのキーを入力にする。どれも押していなければ nil（人は触れていない）。
    /// 押しっぱなしと、前の刻みの後に押して離した打鍵も押していることに数える（`HeldKeys`）。
    mutating func take(at now: Int) -> PilotInput? {
        let keys = held.take(at: now).filter(Controls.isPlayKey)
        guard !keys.isEmpty else {
            return nil
        }
        let left = keys.contains(.left)
        let right = keys.contains(.right)
        let steer: Steer = left == right ? .hold : (left ? .left : .right)
        let fire = keys.contains(.space) || keys.contains(.z)
        return PilotInput(steer: steer, trigger: fire ? .fire : .hold)
    }

    /// 遊びのキーか（README と ADR 0013 のキーの表と同じ）。
    private static func isPlayKey(_ key: Key) -> Bool {
        switch key {
        case .left, .right, .z, .space: true
        case .q, .t, .d, .interrupt: false
        }
    }

    /// スクリーンセーバーのキー。押したとき（簡易な方式では届いたとき）だけ効く。
    private static func command(_ event: KeyEvent) -> Command? {
        switch event {
        case .pressed(let key), .typed(let key):
            switch key {
            case .q, .interrupt: return .quit
            case .t: return .cycleTheme
            case .d: return .cycleDifficulty
            case .left, .right, .z, .space: return nil
            }
        case .released:
            return nil
        }
    }
}
