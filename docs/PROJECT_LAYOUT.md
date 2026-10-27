# モジュール構成と依存規則 — NeNe Swarm

> Status: normative（規範）/ 2026-10-27 初版
> パッケージ: SwiftPM `NeNeSwarm`（`Package.swift`）

モジュールグラフはアーキテクチャの一部である。**ディレクトリの命名規約だけでは依存の境界にならない。**
承認された一覧の機械可読な正本は `docs/architecture/module-graph.txt` で、規約検査が `Package.swift` の宣言と突き合わせる（ARC-002・CNF-010）。

---

## 1. 承認されたモジュール

空の「将来用 target」を作らない。**2026-10-27 時点で `Package.swift` にあるのは `NeNeSwarmCore` とそのテスト（Issue #3）だけ**で、下の一覧は「承認された形」である（ADR 0004）。
残りの target は最初の具体的な責務が生じた PR で足す（Phase 3-2 で Engine・Render・Terminal・合成ルートが入る）。

```text
nene-swarm (executable)
    合成ルート。時計・乱数（シード）・環境・起動オプションを読み、Core・Engine・Render・Terminal を組み立てて
    刻みを回す（時計を見て 1 刻み関数を呼び、刻みごとに描く）。テーマ・難易度のキー・ハイスコアのファイルの読み書きを持つ。
    標準入出力への直書きと終了コードを持つ唯一の場所（ARC-006 / ARC-007）

NeNeSwarmTerminal
    セル格子 → ANSI の差分出力・termios・SIGWINCH・キー入力の解析。unsafe 系 API を許す唯一の区画（SWF-009）

NeNeSwarmRender
    ゲームの状態＋HUD の値 → 文字セルの格子（配色・自機と敵と弾のブロック・星空と爆発の演出・HUD・セリフ）。端末を知らない。出力は値

NeNeSwarmEngine
    パイロットの AI（避ける・狙う・迷う）・キャストの性格とセリフ。Core の状態を読んで入力だけを返す。乱数は引数で受け取る。時計を知らない

NeNeSwarmCore
    盤面・自機（2 機並びを含む）・隊列と急降下・弾・当たり判定・トーチカ・捕獲ビームと捕虜・UFO・残機・スコア・ステージ・
    場面・難易度の効き方・1 刻み関数。時刻・乱数源・端末・Foundation・ファイルを知らない（乱数は引数で受け取る）。値型＋純粋関数
```

テスト target は `<target>Tests`（`NeNeSwarmCoreTests` 等）で、Swift Testing だけを import できる（SWF-016）。

---

## 2. 許可された依存グラフ

```text
NeNeSwarmCore      -> （無し）
NeNeSwarmEngine    -> NeNeSwarmCore
NeNeSwarmRender    -> NeNeSwarmCore, NeNeSwarmEngine
NeNeSwarmTerminal  -> NeNeSwarmRender                         ＋ 標準モジュール Glibc
nene-swarm         -> 上の 4 つすべて（明示的な合成のためだけに） ＋ 標準モジュール Glibc
```

ここに無い依存はすべて禁止である。とくに:

- Core / Engine / Render -> Foundation・FoundationEssentials・Glibc・Dispatch: **禁止**（標準モジュールはビルドグラフでは塞げないので CNF-011 が塞ぐ）
- 宣言していない推移的な依存の import（例: Terminal -> Core）: **禁止**（SwiftPM は拒まない・M6-e。CNF-011 が塞ぐ）
- Core -> Engine、Engine -> Render 等の逆向き: 禁止（SwiftPM が `no such module` で拒み、CNF-010 が宣言を拒む）
- Terminal -> Core / Engine: 禁止（Terminal はセル格子しか知らない）
- 何か -> 合成ルート: 禁止
- Foundation: どの target からも禁止（SWF-014）

---

## 3. 各モジュールの責務

### `NeNeSwarmCore`

意味の正本を持つ。場面・難易度・敵の種類・敵の状態・自機の編成・捕虜の状態・パイロットの入力・被弾の理由（閉じた enum）。
「当たったか」「ステージを終えたか」「ゲームが終わったか」の経路は Core に 1 つずつ。ゲームを進めるのは 1 刻み関数だけで、
秒を知らない。座標は整数（固定小数点）で、セルへの変換は 1 経路（Phase 3-1 の ADR で決める）。乱数源は引数で受け取り、同じシードで同じゲームになる。

### `NeNeSwarmEngine`

パイロットの AI（弾と急降下の敵を避ける・狙って撃つ・迷う）・キャストの性格とセリフ。Core が公開する状態を読み、**入力だけを返す**（Core の状態を書き換えない）。
先読みに Core の 1 刻み関数を使うのは自由で、第 2 の物理を作らない。乱数は `inout` で受け取った乱数源からだけ引く（CNF-012 は `using:` の無い `random(...)` を拒む）。

### `NeNeSwarmRender`

ゲームの状態と HUD の値から文字セルの 2 次元配列を作る。色は Render の配色表だけが持つ。自機・敵・弾・爆発は地とは別の色で塗った偶数桁のブロックで描き、
それらのセルに文字を書かない（FR-07）。星空・爆発の破片・浮かぶ得点・画面の光り・STAGE の帯もここで値として作る。

### `NeNeSwarmTerminal`

alternate screen・カーソル非表示・24bit カラー（無ければ 256 色）・前フレームとの差分・1 フレーム 1 回の `write`・SIGWINCH・
**異常終了でも端末を必ず復元**。キー入力を閉じた enum の意図に変える。可変性の隔離区画（ARC-005）。

### `nene-swarm`

依存を結ぶ。「何秒で 1 刻みか」はここが決める。ハイスコアのファイル（FR-02e）を読み書きしてよい唯一の場所。端末出力（起動できなかった理由 1 行）と終了コードを扱ってよい唯一の場所（ARC-006）。

---

## 4. ソースの置き場

| 種類 | 置き場 |
| --- | --- |
| production | `Sources/<target>/`（`path:` で変えない・CNF-009） |
| テスト | `Tests/<target>Tests/`（規約検査の対象。決定性・網羅性の禁止も適用する） |
| 検査設定 | `.swiftlint.yml`・`.swift-format`（直下の 2 つだけ・CNF-007） |
| 規約検査とその単体テスト | `eng/conformance.py`・`eng/tests/` |
| 依存グラフの正本 | `docs/architecture/module-graph.txt` |
| 生成コード | 無い（SwiftPM のビルドプラグインを使わない・SWF-009） |
| 道具の置き場 | `.tools/`（git 管理外。`eng/install-tools.sh` が lock の SHA-256 で入れる） |
