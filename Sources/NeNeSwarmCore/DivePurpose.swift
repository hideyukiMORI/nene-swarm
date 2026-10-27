/// 急降下の目的。
public enum DivePurpose: Sendable, Hashable {
    /// 自機へ突っ込み、撃ちながら画面の下を抜ける。
    case attack
    /// 親玉が自機の上で止まり、捕獲ビームを出す（FR-02b）。
    case capture
}
