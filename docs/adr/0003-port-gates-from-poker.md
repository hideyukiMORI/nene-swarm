# ADR 0003 — ゲートと規約検査は NeNe Poker から移植し、商標の検査は Reversi の形で足し、証明はこのリポジトリで取り直す

- 状態: 受理
- 日付: 2026-10-27
- Issue: #1
- 影響する規則: QLT-001 / QLT-007 / CNF-001〜CNF-023 / GIT-003

## 文脈

NeNe Poker（https://github.com/hideyukiMORI/nene-poker）・NeNe Igo・NeNe Reversi・NeNe Gambit は、同じ施主・同じ MIT ライセンス・同じ厳格規約で作った兄弟のリポジトリである。
施主の方針として、兄弟のゲートと規約検査・文書の形・端末と描画の土台・配布の形は、自分たちのコードとして移植してよい。

移植元は、指示の上では Igo が原則だった（兄弟で `install.ps1`・smoke の直し・release 構成の libm の罠まで入っているため）。
ただし Phase 1 の足場に限ると、Poker の Issue #1 のコミット `13d7e53` は Igo の `dad2c2c`（足場）と `2a46f6e`（`.release/` の 1 行）を受け継いだうえで、
Phase 0 の実測に `Double.squareRoot()` のリンク（X-i・X-j）と負の数の割り算（X-k）を足している。
ゲートの中身（`eng/conformance.py`・`eng/prove-gates.py`・`Makefile`・CI）は Igo と名前と足場の型の範囲しか違わないことを、木どうしの差分で確かめた。
だから足場は Poker から、Phase 3 以降の端末・描画・smoke・配布は Igo から移植する。

中身を理解せずに丸ごと写すのではなく、シューティングに要らないもの（ポーカー固有の部分）を落とし、名前を合わせ、検査の証明（negative proof）は
このリポジトリで取り直す。

## 決定

Issue #1 で次のファイルを Poker の `13d7e53` から移植した。

| このリポジトリのファイル | 変えたこと |
| --- | --- |
| `eng/conformance.py`・`eng/tests/test_conformance.py` | 名前を合わせた。CNF-001〜CNF-022 の番号と意味は Poker と同じ。**CNF-023（商標の検査）を足した**（下） |
| `eng/measure-language.py` | 名前を合わせた。座標の判断材料の 2 ケース（X-l・X-m）を足した（ADR 0001） |
| `eng/prove-gates.py` | 名前を合わせた。足場の型をシューティングの語にした。CNF-023 の証明（P62）を足した。GitHub 側の証明（P43・P46）はこのリポジトリの ruleset と run で書き直した |
| `eng/swift-strict.sh`・`eng/install-tools.sh`・`eng/install-swift.sh`・`eng/lint.sh`・`eng/swift-sources.sh`・`eng/validate-commit-message.py`・`eng/tests/test_commit_message.py`・`eng/swift.lock`・`eng/swiftlint.lock`・`eng/dependency-allowlist.txt`・`eng/ci-require-ready.sh` | 変えていない |
| `Makefile`・`Package.swift` | 名前を合わせた（target は 0 本。`test`・`smoke` の段はまだ足さない） |
| `.swift-format`・`.swiftlint.yml`・`.swift-version`・`.gitignore`・`.githooks/commit-msg`・`.github/pull_request_template.md`・`.github/workflows/ci.yml` | 変えていない |
| `docs/` の各文書・`CLAUDE.md`・`AGENTS.md`・`README.md` | 形は Poker のまま、中身はシューティングと施主の決定とこのリポジトリの実測で書き直した |

### CNF-023 — 商標の名前を書かない

施主の決定（REQUIREMENTS の Q1・FR-18）で、元になった固定画面のシューティングの登録商標のゲーム名・会社名を、製品名・README・コード・セリフのどこにも書かない。
NeNe Reversi は同じ種類の決定を CNF-023（Reversi の `eng/conformance.py`・コミット `0ee4526`）で機械に見せている。その形（git が追跡し得る全ファイルの中身と名前を、
大文字小文字を区別せずに正規表現で見る）をそのまま使い、語だけをこのリポジトリのものに書き直した。

- 見る語: 元になったゲームの名前（英語と日本語）・その会社名（英語と日本語）。一覧は `eng/conformance.py` の `TRADEMARKS` が正本で、検査器自身と単体テストが違反にならないよう、どの語も分割して組み立てる
- 番号を Reversi と同じ 23 にした（Poker・Igo の 22 番の続き。意味も Reversi と同じ「商標の名前を書かない」）
- `.handoff/` のように git の exclude に入れた置き場は見ない（公開されない）

持ってこなかったもの: ポーカーのルール・役判定・勝率の見積もり（Core と Engine はシューティングで一から書く）・キャストとセリフ（新しい 4 名で書く）・
`eng/smoke-terminal.py`・端末と描画の土台（どれも Phase 3 の使う PR で Igo から移植してこの表に足す）・配布（Phase 4 で Igo から移植する）。
Poker・Igo・Reversi の作業木には書き込んでいない（読んだのは git のコミットの中身だけ）。

**証明はすべてこのリポジトリで取り直した**（`python3 eng/prove-gates.py`・[gate-proofs.md](../quality/gate-proofs.md)）。兄弟の証明の結果は一つも写していない。
GitHub 側の証明（ruleset・draft の CI）もこのリポジトリの PR と run で取った。

## 強制

- **active**: 移植した検査はすべて、このリポジトリの証明が通ってから強制マトリクスで active にした（CNF-006 が証明行の無い active を拒否する）
- **不能**: 「移植元を理解して写したか」はレビュー事項である。この表は、次に誰かが兄弟の修正を取り込むときの照合元として置く
- **不能**: CNF-023 は語の一覧に無い名前（シリーズの別の題名・綴りの崩し）を見ない。見つけたら一覧に足す

## 結果

- 6 回分の実測と事故（draft の CI のスキップ・SwiftPM の警告・静的バイナリが黙って規則を飛ばす・Gambit の CNF-013 の穴）から生まれた検査を、最初から持てる
- 施主の言葉に含まれていた商標の名前は、文書に写す時点で要旨に置き換えた（REQUIREMENTS 冒頭）。写していたら CNF-023 が落とす
- 失うもの: 兄弟の検査器が直されても、このリポジトリには自動では入らない。検査器は製品ごとに別々に保守する

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| Igo の `dad2c2c` から移植する | 当初はこの形で始めたが、Poker の `13d7e53` が同じゲートに X-i〜X-k の実測を足していると分かった。Phase 0 のケース ID が Poker と衝突する（Igo から写すと X-i を別の意味で使うことになる）ので、新しい方に合わせた |
| Reversi や Gambit から移植する | Poker・Igo は Reversi の形をそのまま受け継いでいる。古い方を写す理由が無い |
| 商標の検査を `TRADEMARKS` の語を 1 つの綴りで足す | `space` と次の語の間の空白の有無・大文字小文字・日本語の表記で漏れる。空白を `\s*` にし、大文字小文字を無視し、日本語も並べた |
| 商標の検査を README と Swift のソースだけに絞る | セリフ・コメント・ADR・ファイル名のどこに書いても公開される。Reversi と同じく全ファイルを見る |
| 検査器を共有のパッケージや submodule にする | 依存を足すことになり（CODING_RULES 第 5 節の 3 点が要る）、片方の都合の変更がもう片方のゲートを黙って変える。規約は製品ごとの「守るべきこと」を含む |
| 検査器を一から書き直す | 先に踏んだ地雷を自分で踏み直すことになる。移植してよいと施主が決めている |
| 兄弟の gate-proofs の結果を写す | 「設定が在ることは検査が効いている証明ではない」（ポリシー P-09）。このリポジトリの木で落ちるのを見ていない |
