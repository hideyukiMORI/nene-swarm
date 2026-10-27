# いまのタスク — NeNe Swarm

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-27（82 ケース・Poker の 80 ケース・Igo の 77 ケースと全件一致・ADR 0001） |
| Phase 1 文書とゲートの足場 | ✅ 2026-10-27（Issue #1・PR #2・ruleset 25925485） |
| Phase 2 negative proof | ✅ 2026-10-27（60 件すべて pass・GitHub 側 2 件・docs/quality/gate-proofs.md） |
| Phase 3 縦切り（ゲームの進行と当たり判定から） | 🔲 別 Issue |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・コミットの形）。target は 0 本で、製品コードは無い

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）
- 製品そのもの（ゲームの進行・当たり判定・パイロット・描画・端末は Phase 3）
- `swift test`（テスト target が無いので結線していない・ADR 0002）

## 次の 1 手

Issue #1 を閉じたあと、Phase 3-1「ゲームの進行と当たり判定（Core だけ・画面なし）」の Issue を立てる。
最初に座標（固定小数点の単位・セルへの変換の丸め・`Int` の幅）と 1 刻み関数の形を ADR で決め（ADR 0001 の X-i〜X-m）、
REQUIREMENTS 第 3 節の不変条件をテストにする。全部緑になるまで画面に入らない。
