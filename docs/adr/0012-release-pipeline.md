# ADR 0012 — 版の入力は Version.swift の 1 か所、配布物は静的リンクの 1 経路で作り、検査してから梱包する

- 状態: 受理
- 日付: 2026-10-27
- Issue: #15
- 影響する規則: ARC-006 / QLT-011 / QLT-014

## 文脈

指示書の Phase 4: 版の入力 1 か所・`make release TAG=v<版>`・成果物の検査・`SHA256SUMS`・`install.sh`・`install.ps1`・README（英語が正・`README.ja.md`・先頭に実機の画面写真）。
**Release の公開は施主の確認を取ってから**（Q9）。
兄弟の NeNe Igo は、同じ経路（Igo の ADR 0012・0013。元は NeNe Gambit）で v0.1.0 を公開し、`install.sh` と `install.ps1` の 1 行からの導入まで確かめている。

## 決定

Igo の ADR 0012・0013 の決定を、名前を合わせて引き継ぐ。移植元は Igo のコミット `3bdae35` の `Sources/nene-igo/Version.swift`・`eng/package-release.sh`・
`eng/release/README.txt`（中身はシューティングで書き直した）・`install.sh`・`install.ps1`・README の構成と、証明 P51〜P54。

1. 版の入力は `Sources/nene-swarm/Version.swift` の `Version.current`（`0.1.0`）の 1 か所。`nene-swarm --version` は `nene-swarm <版>` の 1 行を出す
2. 配布物は `eng/package-release.sh [v<版>]`（`make release TAG=v<版>`）だけが作る。別のビルドディレクトリ（`.release/build`）で規約検査・release 構成のテスト・
   `--static-swift-stdlib` のビルドを通し、`strip` してから検査する: x86-64 の ELF・動的依存が `ld-linux-x86-64.so.2` `libc.so.6` `libgcc_s.so.1` `libm.so.6` `libstdc++.so.6` の中だけ・
   `--version` が版と一致・タグが版と一致・同梱物が `nene-swarm` `README.txt` `LICENSE` の 3 つと完全一致
3. 梱包は再現できる形（tar の並び・時刻・持ち主を固定・gzip の時刻を入れない）。`SHA256SUMS` をスクリプトが書く
4. `install.sh` は最新の Release（か `NENE_SWARM_VERSION`）を落とし、`SHA256SUMS` で照合してから `~/.local/bin/nene-swarm` に入れる。照合に失敗したら何も入れない
5. `install.ps1` は WSL の中で `install.sh` を実行し、`%LOCALAPPDATA%\nene-swarm\bin\nene-swarm.cmd` を置いてユーザーの PATH に足す（Igo の ADR 0013）
6. 公開は squash 統合後の clean な `main` から同じスクリプトで作り直し、`v<版>` のタグと同名の Release に配布物と `SHA256SUMS` を添付し、再ダウンロードして照合する。
   **公開（タグの push と Release の作成）は外に出る操作なので、施主の確認を取ってから行う**
7. README の画面写真は実機（Windows Terminal）で撮ったものだけを置く（`docs/images/`。合成しない）。疑似端末の出力を再生した画像は置かない。
   撮影は Phase 3-3 と一緒にする（このセッションでは撮影のコマンドが自動の許可の判定で止められた・ADR 0007 の後の記録）

## 強制

- **active**（QLT-014）: 証明 P51（タグの不一致）・P52（静的リンクを外すと Swift のランタイムへの動的依存で落ちる）・P53（余計な同梱物）・P54（`--version` の不一致）
- `install.sh` と `install.ps1` の 1 行からの導入は、Release を公開してから確かめる（未）

## 結果

- README は英語が正で、`README.ja.md` は です・ます調。どちらも画面写真なしで書き、公開前であることを先頭に書いた

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| 版を `VERSION` ファイルに置き、ビルド時に読む | SwiftPM でビルド時にファイルを読むにはビルドプラグインが要る（SWF-009 で禁止） |
| 版を git のタグから取る | タグの無い木で `--version` が決まらない |
| Swift のランタイムを同梱して動的リンクのまま配る | 同梱物と `LD_LIBRARY_PATH` の扱いが増える。静的リンクなら 1 ファイルで動く |
| CI で Release を自動で作る | 公開は施主の確認を取る外の操作（Q9）。CI に品質判断以外の仕事を足さない（CNF-018） |
| 疑似端末の出力を画像に再生して README に置く | 実機の写真ではない（Windows Terminal の字形・幅・色の出方は違いうる・QLT-013）。兄弟も合成しない |

## 記録

- 2026-10-27・WSL2 Ubuntu 22.04・Swift 6.4.1・この PR の木: `make release TAG=v0.1.0` は `nene-swarm-0.1.0-linux-x86_64.tar.gz`（2,679,211 バイト）と
  `SHA256SUMS`（`83df1cb9201443cbc4f0917d5179f03c9cb561fc0fa202eee70bf56c73b6b806`）を作り、2 回作って同じ SHA-256 になった。動的依存は許可した 5 つだけ
- 配布物をスクラッチの置き場に写して `sha256sum --check`（OK）・展開（同梱物 3 つ）・`ldd`（Swift のライブラリ無し）・`--version`（`nene-swarm 0.1.0`）・
  展開した実行ファイルでの `eng/smoke-terminal.py`（失敗 0 件）を確かめた
- **Swift の入っていない使い捨てのコンテナでの確認はしていない**（この WSL に docker が無い。Igo は `ubuntu:22.04` で確かめた）。公開の前か後に確かめる
- 証明 P51〜P54 を含む 65 件（違反 64・対照 1）がすべて pass
