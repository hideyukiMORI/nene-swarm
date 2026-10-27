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
| Phase 3-2 単純なパイロットで画面に出す | 🔲 次の Issue |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・`swift test -c release`・コミットの形）
- Core: 隊列・急降下・弾（飛び越えない）・トーチカ・捕獲と救出と 2 機並び・UFO・ボーナスステージ・場面・難易度・ハイスコアの並べ方

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）
- 画面（Render・Terminal・合成ルート）とパイロット（Engine）

## 次の 1 手

Phase 3-2「単純なパイロットで画面に出す」: Igo から端末と描画の土台を移植し、テストのパイロット相当（乱数で動いて撃つ）を Engine に置いて、
TITLE → PLAY → GAME OVER → TITLE を回す。`q`・端末の復元・疑似端末での smoke。刻みの速さと 1 フレームのバイト数を計測して ADR に書く。
