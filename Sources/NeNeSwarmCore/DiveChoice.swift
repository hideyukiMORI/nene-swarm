/// 急降下の目的の選び方。
enum DiveChoice {
    /// 突っ込むだけ。
    case attackOnly
    /// 親玉が捕獲にも来られる（半々）。
    case either

    func chosen(coin: Int) -> DivePurpose {
        switch self {
        case .attackOnly: .attack
        case .either: coin == 0 ? .capture : .attack
        }
    }
}
