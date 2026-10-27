# いまのタスク — NeNe Swarm

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-27（82 ケース・Poker の 80 ケース・Igo の 77 ケースと全件一致・ADR 0001） |
| Phase 1 文書とゲートの足場 | ✅ 2026-10-27（Issue #1・PR #2・ruleset 25925485） |
| Phase 2 negative proof | ✅ 2026-10-27（Issue #1 で 60 件・Issue #3 で 61 件すべて pass・GitHub 側 2 件・docs/quality/gate-proofs.md） |
| Phase 3-1 ゲームの進行と当たり判定（Core・画面なし） | ✅ 2026-10-27（Issue #3・ADR 0005 / 0006・不変条件 600 ゲーム） |
| Phase 3-2 単純なパイロットで画面に出す | ✅ 2026-10-27（Issue #5・ADR 0007・smoke） |
| Phase 3-3 実機の画面写真 | ⏸ 撮影（PowerShell の PrintWindow）の権限待ち・施主の手番 |
| Phase 3-4 パイロットの AI とキャスト 4 名 | ✅ 2026-10-27（Issue #7・ADR 0008・NORMAL 平均 約 3 分 20 秒） |
| Phase 3-5a セリフと COMMS 欄 | ✅ 2026-10-27（Issue #9・ADR 0009） |
| Phase 3-5b 専用の色・派手な演出 | ✅ 2026-10-27（Issue #11・ADR 0010） |
| Phase 3-5c ハイスコアのファイル・大きな端末の配置 | ✅ 2026-10-27（Issue #13・ADR 0011） |
| Phase 4 公開の準備 | ✅ 2026-10-27（Issue #15・ADR 0012・`make release` は再現可能） |
| Phase 4 公開（v0.1.0・ベータ） | ✅ 2026-10-27（Q14・再ダウンロードの照合と install.sh の導入と smoke を確かめた） |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・`swift test -c release`・smoke・コミットの形）
- `nene-swarm`: キャスト 4 名（BLASTER.BIN・NERVOUS.TMP・LUCKY.INI・SNIPER.ISO）が毎ゲーム 1 名乗り、TITLE → PLAY → GAME OVER を 80 × 24 に描き続ける。`q` / `t` / `d`
- Core: 隊列・急降下・弾（飛び越えない）・トーチカ・捕獲と救出と 2 機並び・UFO・ボーナスステージ・場面・難易度・ハイスコアの並べ方

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）
- `install.ps1` の 1 行からの導入（PowerShell 側）は未確認
- Windows Terminal での見え方の確認（Phase 3-3。撮影の権限待ち）

## 次の 1 手

施主の手番: 実機の画面写真（Phase 3-3）。撮影の許可のルールを足すか、施主が Windows Terminal で `nene-swarm` を見る。
見え方で直すところが出たら Issue にし、写真を README の先頭に置く。
