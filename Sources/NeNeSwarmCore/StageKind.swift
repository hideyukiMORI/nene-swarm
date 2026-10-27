/// ステージの種類（FR-02d）。
public enum StageKind: Sendable, Hashable {
    /// 隊列と戦うステージ。
    case combat
    /// 敵が撃たずに編隊で通り抜けるだけのボーナスステージ。
    case bonus
}
