/// 80 × 24 に入る配置（FR-17・兄弟の B 案の縮小版）。
///
/// 上端に題の帯、左に罫線の枠の中の盤面（1 セル＝端末の 2 桁）、右に HUD のパネル、下端にキーの帯。
struct ScreenLayout: Sendable, Hashable {
    /// 盤面の左上のセルの端末の桁。
    let fieldColumn: Int
    /// 盤面の左上のセルの端末の行。
    let fieldRow: Int
    /// HUD のパネルの左端の桁。
    let hudColumn: Int
    /// HUD のパネルの幅。
    let hudWidth: Int
    /// 盤面の下に出す COMMS の行数（0 なら COMMS は HUD の中）。
    let commsRows: Int

    /// 80 × 24。COMMS は HUD の中に最新の 1 行。
    static let compact = ScreenLayout(fieldColumn: 1, fieldRow: 2, hudColumn: 55, hudWidth: 25, commsRows: 0)
    /// 100 × 26 以上（FR-17 の 2 段目）。広い HUD にハイスコアの表、盤面の下に COMMS の直近 2 行。
    static let large = ScreenLayout(fieldColumn: 1, fieldRow: 2, hudColumn: 55, hudWidth: 45, commsRows: 2)

    /// 盤面の下に COMMS の行があるか。
    var hasCommsBelow: Bool { commsRows > 0 }

    /// 盤面の幅（端末の桁）。
    static let fieldWidth = FieldMapping.columns
    /// 盤面の高さ（端末の行）。
    static let fieldHeight = FieldMapping.rows

    /// 枠の上端の行。
    var frameTop: Int { fieldRow - 1 }
    /// 枠の下端の行。
    var frameBottom: Int { fieldRow + Self.fieldHeight }
    /// 盤面の下の COMMS の最初の行。
    var commsRow: Int { frameBottom + 1 }
    /// キーの帯の行。
    var footerRow: Int { frameBottom + 1 + commsRows }

    /// この配置がちょうど入る大きさ。
    var size: ScreenSize {
        ScreenSize(columns: hudColumn + hudWidth, rows: footerRow + 1)
    }
}
