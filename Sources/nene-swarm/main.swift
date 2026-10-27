// 合成ルート（ARC-006）。時計・乱数・環境・起動オプションを読み（ARC-007）、Core・Engine・Render・Terminal を組み立てて
// 場面の列を回す。端末の外へ出すのは起動できなかった理由 1 行と終了コードだけ。
// 移植元: NeNe Igo `Sources/nene-igo/main.swift`（コミット 3bdae35）。`--version` は Phase 4 の公開の経路で足す。

import Glibc
import NeNeSwarmRender
import NeNeSwarmTerminal

let options: LaunchOptions
switch LaunchOptions.parse(Array(CommandLine.arguments.dropFirst())) {
case .parsed(let parsed):
    options = parsed
case .rejected(let reason):
    Console.reportFailure("nene-swarm: \(reason)")
    exit(2)
}

switch Console.open() {
case .opened:
    break
case .notATerminal:
    Console.reportFailure("nene-swarm: 端末の中で起動してください（標準入力と標準出力が端末でない）")
    exit(1)
case .failed:
    Console.reportFailure("nene-swarm: 端末の設定を読み書きできない")
    exit(1)
}

/// 24 ビットの色を使うか。`COLORTERM` が truecolor / 24bit を名乗るか、Windows Terminal（`WT_SESSION` がある）なら使い、
/// それ以外は 256 色へ落とす。WSL の中では `COLORTERM` が無いことが多い（NeNe Gambit の ADR 0008）。
let colors: ColorMode = {
    if getenv("WT_SESSION") != nil {
        return .trueColor
    }
    guard let raw = getenv("COLORTERM") else {
        return .palette256
    }
    return ["truecolor", "24bit"].contains(String(cString: raw)) ? .trueColor : .palette256
}()

/// 罫線の文字が 1 桁で描かれる端末だけ罫線の枠を使い、それ以外（2 桁・答えが無い）は ASCII の枠へ落とす（Igo の ADR 0011）。
let traits = TerminalTraits(frame: Console.columnsAdvanced(by: "─") == 1 ? .boxDrawing : .ascii, colors: colors)
let display = DisplayOptions(theme: options.theme, traits: traits)

var systemRandom = SystemRandomNumberGenerator()
var screensaver = Screensaver(options: options, display: display, seed: options.seed ?? systemRandom.next())
screensaver.run()
Console.close()
exit(0)
