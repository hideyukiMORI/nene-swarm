# ADR 0004 — target は Core・Engine・Render・Terminal・合成ルートの 5 つに分け、兄弟と同じ向きで依存させる

- 状態: 受理
- 日付: 2026-10-27
- Issue: #1
- 影響する規則: ARC-002 / ARC-003 / ARC-006 / ARC-007 / ARC-011 / CNF-010 / CNF-011

## 文脈

依存方向を物理的にする（ARC-002）には、責務ごとに SwiftPM の target を分け、禁じた向きを「import できない」状態にする必要がある。
兄弟の NeNe Gambit・NeNe Reversi・NeNe Igo・NeNe Poker は同じ形の製品（端末のスクリーンセーバー・手作りの AI・サイバー HUD）を 5 つの target で作っている（各リポジトリの ADR 0004）。
Igo は v0.1.0 の公開まで、この 5 つの target と target 間の依存の向きを変えずに来ている（Igo の main `2a46f6e` の `docs/architecture/module-graph.txt` は、
`dad2c2c` から Terminal の標準モジュールに `Synchronization` を足しただけ。Igo の ADR 0008）。

Phase 0 の実測で、SwiftPM は兄弟の target の import を拒むが、**推移的な依存の import は拒まない**ことを確かめた（M6-a・M6-e・M6-f）。

シューティングで兄弟と一番違うのは**リアルタイム**であること（REQUIREMENTS 冒頭）。兄弟は 1 手ずつ・1 手 1 秒で進めたが、Swarm は毎秒何十回も状態を進めて描き直す。
それでも層の分け方を変える理由は見つからなかった。時計を見るのが合成ルートだけなら、残りの層は刻みの数しか知らなくてよい。

- Core: 隊列・急降下・弾・当たり判定・トーチカ・捕虜は「状態＋入力＋乱数源 → 次の状態と出来事」の 1 刻み関数で書ける。秒も乱数源も持たない（乱数は引数で受け取る）
- Engine: パイロットは Core の状態を読んで入力を返すだけ。先読みも Core の 1 刻み関数を通る（兄弟の探索が Core の合法手を通ったのと同じ扱い）
- Render・Terminal: 「ゲームの状態＋HUD の値 → セル格子 → ANSI の差分」の形は兄弟と同じ。違うのは 1 秒あたりのフレーム数で、出力の量は Phase 3 で計り直す

## 決定

依存グラフの正本は `docs/architecture/module-graph.txt` とし、次の 5 つの target とそれぞれのテスト target を承認する。

```text
NeNeSwarmCore      盤面・自機と編成・隊列と急降下・弾・当たり判定・トーチカ・捕獲ビームと捕虜・UFO・残機・スコア・ステージ・場面・難易度・1 刻み関数（依存なし）
NeNeSwarmEngine    パイロットの AI・キャストの性格とセリフ（-> Core）
NeNeSwarmRender    ゲームの状態＋HUD の値 → 文字セルの格子（星空・爆発などの演出を含む）（-> Core, Engine）
NeNeSwarmTerminal  セル格子 → ANSI の差分出力・termios・シグナル・キー入力（-> Render ＋ Glibc・unsafe を許す唯一の区画）
nene-swarm         合成ルート。時計・乱数・環境・起動オプション・ハイスコアのファイルを読み書きする唯一の場所。刻みを回す（-> 上の 4 つ ＋ Glibc）
```

- Render が Engine に依存するのは、パイロットの名前・顔・セリフ（Engine の性格の値）を画面に出すため（兄弟と同じ）
- パイロットの入力の型（左・右・撃つ・待つ）は Core に置く。Engine はそれを返すだけで、Core の状態を書き換える経路を持たない（Core の状態は値型で、Engine に渡るのは複製）
- 難易度とテーマの選択は合成ルートが持つ。難易度は Core の 1 刻み関数の引数として毎刻み渡す（押した瞬間から効く・Q7）。テーマは Render の入力にだけ現れる
- target は最初の具体的な責務が生じた PR で `Package.swift` に足す。Phase 1 の `Package.swift` の target は 0 本
- 兄弟が後から広げた所（Igo の Terminal の `Synchronization`）は、このリポジトリで同じ必要が生じた PR で、この ADR を置き換える ADR とともに足す。使うまで承認しない

## 強制

- **active** → SwiftPM の target グラフ（兄弟の import と循環を拒む）＋CNF-010（`Package.swift` と正本の一致・正本の循環・合成ルートは 1 つ）＋
  CNF-011（各ファイルの import が、正本で宣言した直接の依存と `std=` の標準モジュールだけであること。推移的な依存も標準モジュールもここで塞ぐ）＋
  CNF-012（合成ルート以外で時計・乱数源・`CommandLine`・環境を読まない）

## 結果

- 「Core は時計も端末も知らない」「パイロットは Core の状態を書き換えない」「Terminal はゲームを知らない」が、レビューではなく import の失敗と型で守られる
- 刻みの速さを変えてもゲームの中身（Core と Engine）は変わらない。同じシードなら刻みの速さによらず同じゲームになる
- 失うもの: Terminal のテストでゲームの状態から格子を作るような便利な書き方はできない

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| 1 つの target にまとめ、ディレクトリで分ける | ディレクトリの命名だけでは依存の境界にならない（PROJECT_LAYOUT 冒頭） |
| Core に経過時間（秒）を渡して進める（可変の刻み） | 同じシードでも刻みの長さで結果が変わり、決定性（REQUIREMENTS 第 3 節）が崩れる。当たり判定の飛び越えも刻みの長さに依存する。固定の刻みにし、秒は合成ルートだけが知る |
| パイロットを Core の中に置く | パイロットの好みが「当たったか」の経路と同じ型に入り、ずるをできない形を型で作れなくなる。性格とセリフは兄弟と同じく Engine に置く |
| 演出（星空・爆発の破片・浮かぶ得点）を Core の状態に持たせる | 当たり判定に関係しない値がゲームの状態のハッシュに入り、決定性のテストが見た目の変更で壊れる。演出は Core の出来事から Render が値として作る（Phase 3 の ADR で具体化） |
| Render を Engine に依存させず、セリフを合成ルートから文字列で渡す | パイロットの名前とセリフの正本が Engine と合成ルートの 2 か所に割れる（ARC-001） |
| Igo の最終形（`Synchronization` を含む）を最初から承認する | 使っていない許可は「空の将来用 target を作らない」と同じ理由で置かない。必要になった PR で根拠ごと足す |
| `--explicit-target-dependency-import-check error` に推移的な import を任せる | 実測で拒まなかった（M6-f） |
