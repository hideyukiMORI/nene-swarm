import NeNeSwarmCore

/// パイロットのセリフ（COMMS）の状態。どの出来事で話すかの規則はここだけにある（FR-15・ADR 0009）。
///
/// - 1 刻みに 1 行まで。その刻みでいちばん優先度の高いきっかけだけを見て、確率に外れたら黙る
/// - 必ず言うきっかけ（被弾・捕獲・救出・残り 1 機・GAME OVER・新記録・TITLE）以外は、前の発言から `quietTicks` 刻みは黙る
/// - 同じパイロットは直近 8 回と同じセリフを言わない
/// - 乱数は引数から受け取るので、同じシードからは同じ会話になる
/// 形は NeNe Igo の `Banter`（コミット 3bdae35。元は NeNe Gambit）にならった。話し手は 1 人で、出来事をシューティングのものに替えた。
public struct Banter: Sendable, Hashable {
    /// 間を置く刻みの数（30 刻み／秒で 3 秒）。
    static let quietTicks = 90
    /// 続けて倒したと数える間（刻み）と数。
    static let streakWindow = 45
    static let streakCount = 3

    /// いちばん新しい発言（まだ無ければ nil）。
    public private(set) var latest: Remark?
    private var recent: [String: [String]] = [:]
    private var clock = 0
    private var lastSpoke = -quietTicks
    private var kills: [Int] = []
    private var lastShips: Int?

    /// 何も言っていない状態。
    public init() {}

    /// 1 刻みに聞いたことに反応する（0〜1 行）。
    public mutating func listen(
        _ hearing: Hearing, persona: Persona, using generator: inout some RandomNumberGenerator
    ) {
        clock += 1
        let cues = notice(hearing)
        guard let cue = cues.max(by: { $0.priority < $1.priority }) else {
            return
        }
        let roll = Int.random(in: 0..<100, using: &generator)
        guard roll < cue.chance, cue.interrupts || clock - lastSpoke >= Banter.quietTicks else {
            return
        }
        say(cue, persona: persona, using: &generator)
    }

    /// 出来事からきっかけを拾う。続けて倒した数と、残りの自機の数はここで数える。
    private mutating func notice(_ hearing: Hearing) -> [Cue] {
        var cues: [Cue] = []
        for event in hearing.events {
            cues += cuesHeard(in: event, newRecord: hearing.newRecord)
        }
        kills = kills.filter { clock - $0 < Banter.streakWindow }
        if kills.count >= Banter.streakCount {
            cues.append(.streak)
            kills.removeAll()
        }
        if let ships = hearing.shipsInPlay, ships == 1, (lastShips ?? 0) > 1 {
            cues.append(.lastShip)
        }
        lastShips = hearing.shipsInPlay
        return cues
    }

    private mutating func cuesHeard(in event: SessionEvent, newRecord: Bool) -> [Cue] {
        switch event {
        case .titleShown: return [.title]
        case .gameStarted: return []
        case .gameEnded: return [newRecord ? .newRecord : .gameOver]
        case .game(let inner): return cuesHeard(in: inner)
        }
    }

    private mutating func cuesHeard(in event: GameEvent) -> [Cue] {
        switch event {
        case .stageStarted: return [.stageStart]
        case .stageCleared: return [.stageClear]
        case .enemyDestroyed(_, let points, _):
            kills.append(clock)
            return points >= 400 ? [.bigScore] : []
        case .saucerDestroyed, .perfect: return [.bigScore]
        case .nearMiss: return [.nearMiss]
        case .shipDestroyed, .wingLost: return [.hit]
        case .shipCaptured: return [.captured]
        case .captiveRescued: return [.rescued]
        case .flagshipDamaged, .shipRespawned, .captiveLost, .captiveShot, .gameOver: return []
        }
    }

    /// 1 行を言う。直近 8 回のセリフを避けて乱数で選ぶ（全部が直近なら避けない）。
    private mutating func say(_ cue: Cue, persona: Persona, using generator: inout some RandomNumberGenerator) {
        let all = persona.lines(for: cue)
        let said = recent[persona.name] ?? []
        let fresh = all.filter { !said.contains($0) }
        guard let text = (fresh.isEmpty ? all : fresh).randomElement(using: &generator) else {
            return
        }
        recent[persona.name] = Array((said + [text]).suffix(8))
        lastSpoke = clock
        latest = Remark(persona: persona, cue: cue, text: text)
    }
}
