# 用語集 — NeNe Swarm

> Status: normative（規範）/ 2026-10-27 初版
> ここに載っている語は、コード・ドキュメント・Issue で**同じ意味**で使う。同義語を発明しない。

| 語 | 意味 | 型／場所 |
| --- | --- | --- |
| 結果（outcome） | 期待される成功・失敗を表す閉じた型 | `*Outcome` |
| 拒否理由（rejection / failure） | 結果に添える閉じた理由の集合 | `*Rejection` / `*Failure` |
| 合成ルート | 依存を結ぶ唯一の場所。時計・乱数・環境を読み、標準入出力と終了コードを持つ | `nene-swarm`（executable target） |
| 描画（render） | ゲームの状態と HUD の値から文字セルの格子という値を作ること。端末への書き出しは含まない | `NeNeSwarmRender` |
| 隔離区画 | 可変性を許した唯一の場所 | ARC-005 の表 |
| 規約検査（conformance） | NeNe Swarm 固有の自作ゲート | `eng/conformance.py`（CNF-NNN） |
| waiver | 1 つの規則に対する期限付きの狭い例外 | `docs/waivers/WVR-NNNN-*.md` |
| 機械強制の状態 | active / planned / 不能 / 不採用 | `docs/QUALITY_GATES.md` の強制マトリクス |
| negative proof | ゲートが意図した規則で落ちることの実測 | `docs/quality/gate-proofs.md` |
| 固定画面のシューティング（fixed shooter） | このゲームの種類。画面はスクロールせず、自機は下端を左右に動く。元になったゲームの名前は書かない（FR-18・CNF-023） | — |
| 刻み（tick） | ゲームを 1 段進める単位。Core と Engine は刻みの数だけを知り、秒を知らない。何秒で 1 刻みかは合成ルートだけが決める | `NeNeSwarmCore`・合成ルート |
| 1 刻み関数（step） | 「状態＋パイロットの入力＋乱数源 → 次の状態と出来事」の純粋な関数。ゲームを進める唯一の経路 | `NeNeSwarmCore` |
| 盤面（field） | 当たり判定の座標の範囲。セルを細かく割った整数（固定小数点）で持つ。セルへの変換は 1 経路 | `NeNeSwarmCore` |
| 場面（scene） | TITLE・PLAY・GAME OVER の閉じた enum。遷移は TITLE → PLAY → GAME OVER → TITLE だけ（FR-03） | `NeNeSwarmCore` |
| 自機（ship） | パイロットが動かす機体。下端を左右に動き、上へ撃つ | `NeNeSwarmCore` |
| 編成（wing） | 自機が 1 機か 2 機並びか（FR-02b）。2 機並びは弾が 2 発ずつ・当たり判定も 2 機分 | `NeNeSwarmCore`（`Wing`） |
| 残機（lives） | 控えの自機の数。被弾と捕獲でだけ 1 減る | `NeNeSwarmCore` |
| 隊列（swarm） | 画面の上側に並ぶ敵の集まり。左右に行進し、端で 1 段下がる（FR-02 a） | `NeNeSwarmCore` |
| 急降下（dive） | 隊列から抜けた敵が曲線を描いて自機へ向かい、画面の下を抜けて隊列へ戻る動き（FR-02 b） | `NeNeSwarmCore` |
| 敵の種類（enemy kind） | 雑魚・親玉・UFO など。加点の表と色の持ち主。閉じた enum | `NeNeSwarmCore` |
| 敵の状態（enemy state） | 隊列にいる・急降下中・捕獲ビームを出している・戻り中・爆発中。閉じた enum | `NeNeSwarmCore` |
| 親玉（flagship） | 2 発で倒れる特別な敵。急降下して捕獲ビームを出す（FR-02b） | `NeNeSwarmCore` |
| 捕獲ビーム（capture beam）・捕虜（captive） | 親玉が出すビームと、それに捕まって隊列に並んだ自機。急降下中の親玉を倒すと捕虜が戻る | `NeNeSwarmCore` |
| トーチカ（shield） | 自機と隊列の間の 4 つの壊れる盾。当たったセルが 1 つずつ欠け、ステージの始まりで戻る（FR-02a） | `NeNeSwarmCore` |
| UFO（saucer） | 画面の上端をときどき横切るボーナスの敵（FR-02c） | `NeNeSwarmCore` |
| ステージ（stage） | 隊列を全滅させるまでの 1 区切り。進むほど敵が強くなる（FR-05） | `NeNeSwarmCore` |
| ボーナスステージ（bonus stage） | 3 ステージごとに挟む、敵が撃たず飛び抜けるだけのステージ（FR-02d） | `NeNeSwarmCore` |
| 難易度（difficulty） | EASY・NORMAL・HARD。敵の側（速さ・弾の数・急降下の頻度）だけを変える（FR-14） | `NeNeSwarmCore` |
| 出来事（event） | 1 刻みで起きたこと（倒した・被弾した・捕まった・救出した・ステージを終えた…）。セリフと演出の入力 | `NeNeSwarmCore` |
| パイロット（pilot）・性格（persona） | 4 名のキャラクター。避け方・狙い方・迷い・わざと捕まりに行くか・セリフの組（FR-04・FR-15） | `NeNeSwarmEngine` |
| パイロットの入力（pilot input） | 左・右・撃つ・待つの閉じた enum。パイロットが Core に返せる唯一のもの | `NeNeSwarmCore` |
| ハイスコア（high scores） | 上位 5 件。読み書きは合成ルートだけ（FR-02e） | 合成ルート・`NeNeSwarmCore`（並べ方） |
| シード（seed） | 自前の PRNG の初期値。同じシード・キー入力なしなら同じゲームの列と同じセリフ | 合成ルートが読み、Core と Engine に渡す |
| セル格子 | 端末の 1 画面分の文字セルの 2 次元配列。Render が作り、Terminal が差分で書く | `NeNeSwarmRender` |

## 使ってはいけない語

`Manager` / `Helper` / `Util` / `Utils` / `Common` を型名の語尾に使わない（SWF-010）。
役割を語る名前が思いつかないときは、その型が 2 つの責務を持っている可能性が高い。
