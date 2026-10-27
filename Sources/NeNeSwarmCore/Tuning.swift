/// 難易度とステージから決まる敵の強さ（FR-05・FR-14・ADR 0005）。確率は千分率の整数で持つ。
///
/// ステージが進むほど強くなり、どの難易度でもいつかはパイロットが落ちる（ゲームが必ず終わる）。
/// 同じステージでは難易度が高いほど、どの値も敵に有利か同じになる（難易度の単調性）。
public struct Tuning: Sendable, Hashable {
    /// 隊列が 1 歩進む間の刻みの数（全員いるとき）。少ないほど速い。
    public let marchInterval: Int
    /// 1 刻みに急降下が始まる確率（千分率）。
    public let diveChance: Int
    /// 同時に急降下できる敵の数。
    public let maxDivers: Int
    /// 急降下の下向きの最高速度（単位／刻み）。
    public let diveSpeed: Int
    /// 敵の弾の下向きの速さ（単位／刻み）。
    public let shotSpeed: Int
    /// 画面に同時に出せる敵の弾の数。
    public let maxShots: Int
    /// 隊列から 1 刻みに弾が出る確率（千分率）。
    public let swarmFireChance: Int
    /// 急降下中の敵が 1 刻みに撃つ確率（千分率）。
    public let diverFireChance: Int

    /// 難易度とステージ（1 から）から強さを決める。
    public static func make(difficulty: Difficulty, stage: Int) -> Tuning {
        Tuning(tier: difficulty.rawValue, level: max(0, stage - 1))
    }

    private init(tier: Int, level: Int) {
        marchInterval = max(3, 20 - tier * 4 - level)
        diveChance = 6 + tier * 5 + level * 2
        maxDivers = min(7, 2 + tier + level / 2)
        diveSpeed = min(9, 4 + tier + level / 3)
        shotSpeed = min(10, 4 + tier + level / 3)
        maxShots = min(9, 2 + tier * 2 + level / 2)
        swarmFireChance = 6 + tier * 5 + level * 2
        diverFireChance = 20 + tier * 10 + level * 3
    }
}
