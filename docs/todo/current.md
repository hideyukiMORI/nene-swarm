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
| Phase 3-3 実機の画面写真 | 🔲 次 |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・`swift test -c release`・smoke・コミットの形）
- `nene-swarm`: 仮のパイロットで TITLE → PLAY → GAME OVER を 80 × 24 に描き続ける。`q` / `t` / `d`
- Core: 隊列・急降下・弾（飛び越えない）・トーチカ・捕獲と救出と 2 機並び・UFO・ボーナスステージ・場面・難易度・ハイスコアの並べ方

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）
- 本物のパイロットとキャスト・セリフ（Phase 3-4）・専用の色・派手な演出・ハイスコアのファイル・大きな端末の配置（Phase 3-5）

## 次の 1 手

Phase 3-3: Windows Terminal で画面写真を撮り（PLAY は間隔を空けて数枚）、敵と自機の形・弾の見え方・文字幅・ちらつき・速さを確かめる。
そのあと Phase 3-4（本物のパイロットとキャスト 4 名・寿命の計測）。
