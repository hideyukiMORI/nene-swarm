/// 製品の版。版の入力はここ 1 か所だけ（Phase 4・ADR 0012）。公開スクリプトはこの値と `--version` の出力とタグを突き合わせる。
/// 移植元: NeNe Igo `Sources/nene-igo/Version.swift`（コミット 3bdae35。元は NeNe Gambit）。
enum Version {
    static let current = "0.1.0"
}
