# NeNe Swarm

> *AI のパイロットが、端末の中で固定画面のシューティングを遊び続けます。止めるときは `q` です。*

手作りの AI のパイロットが、左右に行進しては急降下してくる隊列と戦い続けるスクリーンセーバーです。壊れるトーチカ・捕獲ビーム・UFO・
ボーナスステージ・上位 5 件のハイスコアがあります。タイトル → プレイ → ゲームオーバー → タイトルを繰り返します。
4 名のパイロットが交代で乗り、それぞれの口調でずっとボヤき、ジョークを言い、得意がります。見ているだけで、何もしなくてかまいません。

[![release](https://img.shields.io/github/v/release/hideyukiMORI/nene-swarm)](https://github.com/hideyukiMORI/nene-swarm/releases/latest)
![platform](https://img.shields.io/badge/platform-Linux%20x86__64%20%2F%20WSL2-555)
![license](https://img.shields.io/badge/license-MIT-555)

[English](README.md) · **日本語**

[NeNe Gambit](https://github.com/hideyukiMORI/nene-gambit)（チェス）・[NeNe Reversi](https://github.com/hideyukiMORI/nene-reversi)・
[NeNe Igo](https://github.com/hideyukiMORI/nene-igo)（囲碁）・[NeNe Poker](https://github.com/hideyukiMORI/nene-poker) の兄弟です。

🧪 **ベータ版です。** [v0.1.0](https://github.com/hideyukiMORI/nene-swarm/releases/tag/v0.1.0) をベータとして公開しました。Windows Terminal の実機での見え方はまだ確かめていません。画面写真は後で足します。

---

## 入れ方

次の 1 行で入ります。

```bash
curl -fsSL https://raw.githubusercontent.com/hideyukiMORI/nene-swarm/main/install.sh | bash
```

最新のリリースを落として `SHA256SUMS` で照合し、一致したときだけ `~/.local/bin/nene-swarm` に入れます。一致しなければ何も入れません。
スクリプトは [install.sh](install.sh) の 45 行ほどです。

- 動作環境: x86_64 の Linux で glibc 2.35 以降（Ubuntu 22.04 以降）。WSL2 の Ubuntu と Windows Terminal 向けに作っています
- Swift は要りません。Swift の標準ライブラリを静的にリンクした 1 ファイルで、動的に依存するのは libc・libm・libstdc++・libgcc_s だけです
- 消すときは `rm ~/.local/bin/nene-swarm` です（ハイスコアも消すなら `~/.local/state/nene-swarm` も）

**PowerShell から**（Windows・WSL あり）:

```powershell
irm https://raw.githubusercontent.com/hideyukiMORI/nene-swarm/main/install.ps1 | iex
```

既定の WSL のディストリビューションの中で同じ入れ方を実行し、`%LOCALAPPDATA%\nene-swarm\bin` に小さな `nene-swarm.cmd` を置いて、そのフォルダをユーザーの PATH に足します。
PowerShell や cmd からも `nene-swarm` で起動できます。別のディストリビューションに入れるときは `NENE_SWARM_DISTRO` を設定してください。
消すときは `%LOCALAPPDATA%\nene-swarm` を消して PATH から外し、`wsl rm ~/.local/bin/nene-swarm` を実行します。

## 見かた

```bash
nene-swarm
```

| キー | |
| --- | --- |
| `q` | 終了します（Ctrl+C でも終わります。どんな終わり方でも端末は元に戻ります） |
| `t` | 次のカラーテーマにします（全部で 12） |
| `d` | 次の難易度にします（`EASY` → `NORMAL` → `HARD`）。押した瞬間から効きます。変わるのは敵の側だけで、パイロットの腕は変わりません |

| 起動オプション | |
| --- | --- |
| `--theme 名前` | `NEON` `PHOSPHOR` `AMBER` `SYNTHWAVE` `GLACIER` `BLOODMOON` `VAPOR` `MONO` `TOXIC` `GILDED` `ABYSS` `PAPER` |
| `--difficulty 名前` | `easy`・`normal`（既定）・`hard` |
| `--seed N` | 同じシードなら同じゲームと**同じセリフ**になります（キーを押さない限り） |
| `--tick-rate N` | 1 秒に進める刻みの数（10〜60・既定 30）。ゲームは刻みの数で進むので、速さを変えても同じシードなら同じゲームです |
| `--title-pause 秒` / `--game-over-pause 秒` | タイトルとゲームオーバーを見せる時間（既定 5 秒と 4 秒） |
| `--version` | 版を出して終わります |

端末は **80 × 24 以上**が要ります。**100 × 26 以上**では HUD が広がってハイスコアの表が出て、盤面の下にセリフの直近 2 行が出ます
（Windows Terminal の既定の 120 × 30 で足ります）。小さすぎるときは、必要な大きさを 1 行で知らせます。

NORMAL の 1 ゲームは平均で **3 分ちょっと**です。慎重なパイロットは 4 分ほど、無鉄砲なパイロットは 2 分半ほどです。

### 画面で起きること

- **隊列**は左右に行進し、端に着くたびに 1 段下がります。減るほど速くなります。何機かは隊列から抜け出して弧を描き、撃ちながら急降下して、画面の上から戻ってきます
- **親玉**は 2 発で倒れます。急降下して**捕獲ビーム**を出すことがあり、ビームは親玉の下へ少しずつ伸びます。捕まった自機は、捕まえた親玉のそばで隊列に並びます。
  その親玉を**飛んでいる間に**撃ち落とすと、自機が戻ってきて **2 機並び**になります（弾が 2 発ずつ出ます）
- **トーチカ** 4 つは、自機の弾でも敵の弾でも隊列でも 1 セルずつ欠けます。ステージが変わると元に戻ります
- **UFO** がときどき上端を横切ります（300〜1500 点・倒すまで分かりません）。3 ステージごとに**ボーナスステージ**があり、撃ってこない 20 機を全部倒すと 10,000 点です
- **演出**: 流れる星空・飛び散る爆発・倒した場所に浮かぶ得点・大きく倒したときの画面の光り・大きな文字の帯（`STAGE 3`・`STAGE CLEAR`・`PERFECT!`・`TWIN WING!`）
- **ハイスコア**: 上位 5 件（得点・パイロット・ステージ・難易度）をタイトルと HUD に出し、`$XDG_STATE_HOME/nene-swarm/`（無ければ `~/.local/state/nene-swarm/`）に残します。
  ファイルを読めない・書けないときは起動中だけの記録で続け、タイトルにそう出します

## パイロット

タイトルの画面で、次のゲームに乗る 1 名を 4 名から乱数で選びます。避け方も狙い方も、口の悪さもそれぞれです。

| | 飛び方 | 本人の言葉 |
| --- | --- | --- |
| **BLASTER.BIN** `(>_<)` | 何でも撃ち、先はあまり見ません。2 機並びが欲しくて、捕獲ビームに自分から入ります | *"Statistically, if you shoot everything, you hit something."* |
| **NERVOUS.TMP** `(;_;)` | 消されるのを怖がる一時ファイル。遠くまで見て逃げ、トーチカの下に隠れ、撃つのは控えめです | *"I'm going to hide under that shield until the sun dies."* |
| **LUCKY.INI** `(^o^)` | 博打打ち。いちばん迷い、UFO を追いかけ、ビームにもときどき入ります | *"Twenty-two to one. I like those odds. I like all odds."* |
| **SNIPER.ISO** `(-_-)` | 先を読んで撃ち、狙いが合うまで撃ちません。ビームは避けます。口数は少なめです | *"Precision is a form of mercy. Quicker."* |

1 人 50 本のセリフを、12 の場面（タイトル・ステージの始まりと終わり・続けて倒した・大きな得点・紙一重・被弾・残り 1 機・捕獲・救出・ゲームオーバー・新記録）に書きました。いくつかを:

> **NERVOUS.TMP**（被弾）*"Tell my cache I loved it."*<br>
> **LUCKY.INI**（ゲームオーバー）*"Lucky=false. Who edited my config?"*<br>
> **SNIPER.ISO**（ゲームオーバー）*"Unmounted."*<br>
> **BLASTER.BIN**（被弾）*"Note to self: things also come from the front."*

残りの 196 本は、見ながら集めてください。

## 12 のテーマ

`t` で巡ります: `NEON`（既定）・`PHOSPHOR`・`AMBER`・`SYNTHWAVE`・`GLACIER`・`BLOODMOON`・`VAPOR`・`MONO`・`TOXIC`・`GILDED`・`ABYSS`・`PAPER`（唯一の明るいテーマ）。
どのテーマでも、自機・敵の種類ごと・両方の弾・トーチカ・UFO・爆発は背景に対して 3:1 以上で、自機は敵と同じ色になりません。画面の英数字はすべて 4.5:1 以上です。
人の目ではなく、実際に描いたセルの色からテストが計算しています。

---

## 中身の話

NeNe Swarm はアーケードのスクリーンセーバーの顔をしていますが、**規約を機械に守らせる実験**でもあります。
下の数字は、どれもリポジトリの記録（ADR・テスト・ゲートの証明）にあります。

### 1. ゲームは時計を読みません

ゲームは 1 つの純粋な関数です。状態とパイロットの入力とシード付きの乱数源から、次の状態を 1 刻みずつ作ります。
ゲームとパイロットのコードは、時刻・乱数・環境変数を**読めません**。読もうとすると、自前の規約検査でビルドが落ちます。
時計を読んで秒を刻みに直すのは、プログラムの入り口だけです。位置は整数で持ちます（1 セル＝16 単位）。`Double.squareRoot()` は libm を import しないとリンクすらできないことを、
製品のコードを書く前に測っていたからです（[ADR 0005](docs/adr/0005-fixed-point-field-and-tick-step.md)）。

### 2. 公表値が無いので、744 ゲーム回します

チェスには perft が、囲碁には Tromp の数がありますが、シューティングには照らし合わせる数がありません。そこで `make check` のたびに、テスト用のパイロット 2 名で
**600 ゲームを最後まで**回し、毎刻み確かめます: 同じシードなら同じゲームになる・盤面から何もはみ出さない・スコアは倒したものの得点の分だけ増える・
自機は撃たれたときだけ減る・捕獲と救出で自機の数が変わらない・どのゲームも終わる・難易度が上がると平均で早く終わる。
さらに**本物のパイロットで 144 ゲーム**回します。弾は、当たりうるどの物より小さい刻みで進むので、1 刻みに 3 セル進む弾でも敵を飛び越えません
（[ADR 0006](docs/adr/0006-invariant-tests-and-measured-game-length.md)）。

### 3. 誰にも撃てない捕虜

最初の版では、捕まった自機を親玉の真上に置いていました。「捕虜を撃ってしまう」のテストがどうしても通りませんでした。下から撃つと、必ず先に親玉に当たるからです。
要件にはあるのに、形の上で起こりえませんでした。いまは捕虜を半機ぶん横にずらしています。

### 4. ゲームそのもので先を読むパイロット

パイロットは、左・右・止まるのそれぞれについて、**ゲーム自身の 1 刻み関数**で数十刻み先まで進めてみて、安全で狙う位置に近づくものを選びます。
先読みの中の乱数源はいつも「何も起きない」を出すので、新しい弾も急降下も現れません。見えている危険だけを避けます。
最初の版を測ると、NORMAL の 1 ゲームは 1 分しか続かず、理由も分かりました。捕獲ビームが出た瞬間に下まで届き、急降下の敵が自機と同じ速さで下まで追ってきていました。
難しいのではなく、不公平でした。ビームを伸ばし、急降下の敵が途中で向きを決めるようにしたら、NORMAL は約 3 分 20 秒になりました
（[ADR 0008](docs/adr/0008-pilots-cast-and-game-length.md)）。

### 5. 規約は書くのではなく、守らせます

リポジトリには 72 の規則があり、どれにも ID と「機械が守っているか」の状態があります。
いま **51 が active** です（破ると `make check` が落ちます）。残りは「まだ機械が見ていない」「機械では塞げない」と正直に書いています（[品質ゲート](docs/QUALITY_GATES.md)）。
製品のコードを書く前に Swift 6.4.1 を 82 のケースで測り（[phase0-results.json](docs/quality/phase0-results.json)）、どの検査も落ちるのを見るまでは信用しません。
**わざと仕込んだ 64 の違反**が、それぞれ狙った規則で落ちたことを[ゲートの証明](docs/quality/gate-proofs.md)に記録しています。
オマージュ元のゲームの名前もその 1 つです。リポジトリのどこかに書くと、ビルドが落ちます。

### 6. 端末は必ず元に戻ります

`q` でも Ctrl+C でも SIGTERM でも、**SIGSEGV で落ちても**、死ぬ前に端末を元に戻します。
`make check` のたびに、本物の実行ファイルを疑似端末の中で動かして確かめています。

---

## 開発

```bash
make bootstrap           # clone の後に 1 回（コミットフックと静的リンクの SwiftLint）
make check               # 完了の唯一の定義。ローカルと CI で同じです
make release TAG=v<版>   # 配布物を作ります（検査に通ったときだけ）
```

- Swift 6.4.1（`.swift-version`）・SwiftPM だけ・製品の外部依存はゼロです。ソースは約 4,600 行、テストは約 1,600 行です
- 入口は [CLAUDE.md](CLAUDE.md)（日本語）と [AGENTS.md](AGENTS.md)（英語）です。設計の判断は 12 の [ADR](docs/adr/README.md)、要件と施主の決定は [REQUIREMENTS.md](docs/REQUIREMENTS.md) にあります
- 人も AI も同じ規約・同じゲートで書きます。このリポジトリのコードは Claude Code が書き、要件と決定は施主が決めました

## ライセンス

MIT（[LICENSE](LICENSE)）
