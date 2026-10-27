/// 救出した捕虜の行き先。
public enum RescueOutcome: Sendable, Hashable {
    /// 画面の自機と並んで 2 機並びになった。
    case joined
    /// 画面の自機が並べない（いない・既に 2 機並び）ので、残機に戻った。
    case reserved
}
