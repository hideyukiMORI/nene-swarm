import Testing

@testable import NeNeSwarmCore

/// 多数のゲームを最後まで回し、刻みごとに不変条件を見る（REQUIREMENTS 第 3 節）。重いので release 構成で回す（ADR 0006）。
@Suite struct InvariantTests {
    /// 難易度ごと・テストのパイロットごとに回すシードの数。黙って下げない（ADR 0006）。
    static let seedsPerCell = 100

    static let cells: [(Difficulty, TestPilot)] = Difficulty.allCases.flatMap { difficulty in
        TestPilot.allCases.map { (difficulty, $0) }
    }

    @Test(arguments: cells)
    func everyGameEndsAndKeepsEveryInvariant(_ difficulty: Difficulty, _ pilot: TestPilot) {
        var failures: [String] = []
        for seed in 0..<UInt64(InvariantTests.seedsPerCell) {
            let run = Playthrough.run(seed: seed, pilot: pilot, difficulty: difficulty) { before, input, step in
                failures += InvariantTests.violations(before: before, input: input, step: step)
            }
            if case .over(.timeLimit) = run.final.status {
                failures.append("seed \(seed): 刻みの上限に達した")
            }
            if !failures.isEmpty {
                Issue.record("seed \(seed): \(failures.prefix(3))")
                return
            }
        }
    }

    static func violations(before: Game, input: PilotInput, step: GameStep) -> [String] {
        legality(before: before, input: input) + bounds(step.game) + conservation(before: before, step: step)
            + population(before: before, step: step)
    }

    /// パイロットの入力は合法（端より外へ動かない・撃てないときに撃たない）。
    static func legality(before: Game, input: PilotInput) -> [String] {
        var found: [String] = []
        if !before.canSteer(input.steer) {
            found.append("動けない向き \(input.steer)")
        }
        if case .fire = input.trigger, !before.canFire {
            found.append("撃てないときに撃った")
        }
        return found
    }

    /// 自機・敵・弾は盤面の中（か、抜けて消える途中）にいる。
    static func bounds(_ game: Game) -> [String] {
        var found: [String] = []
        if case .active(let ship) = game.ship, ship.x < 0 || ship.x > ship.maxX {
            found.append("自機が盤面の外 \(ship.x)")
        }
        if game.playerShots.contains(where: { $0.box.bottom <= 0 || $0.position.y > Ship.top }) {
            found.append("自機の弾が盤面の外")
        }
        if game.enemyShots.contains(where: { $0.position.y >= Field.height }) {
            found.append("敵の弾が盤面の外")
        }
        for enemy in game.enemies where !isPassingThrough(enemy, in: game.stage) {
            if enemy.position.x < 0 || enemy.box.right > Field.width || enemy.position.y < -Enemy.height
                || enemy.position.y > Field.height
            {
                found.append("敵が盤面の外 \(enemy.position)")
            }
        }
        return found
    }

    /// ボーナスステージの編隊は盤面の外から入って外へ抜ける（入る途中で倒されると、その場で爆発する）。
    private static func isPassingThrough(_ enemy: Enemy, in stage: Stage) -> Bool {
        switch stage.kind {
        case .bonus: true
        case .combat: false
        }
    }

    /// スコアは減らず、増えた分は出来事の得点の合計。自機の数は失った出来事の数だけ減り、捕獲と救出では変わらない。
    static func conservation(before: Game, step: GameStep) -> [String] {
        var found: [String] = []
        let gained = step.events.reduce(0) { sum, event in sum + points(of: event) }
        if step.game.score != before.score + gained {
            found.append("スコアの増え方 \(before.score) → \(step.game.score)（出来事 \(gained)）")
        }
        let lost = step.events.filter(isShipLoss).count
        if step.game.shipsInPlay != before.shipsInPlay - lost {
            found.append("自機の数 \(before.shipsInPlay) → \(step.game.shipsInPlay)（失った \(lost)）")
        }
        let reserveDrops = step.events.filter {
            $0 == .shipDestroyed(.shot) || $0 == .shipDestroyed(.rammed) || $0 == .shipCaptured
        }
        if step.game.reserve < before.reserve - reserveDrops.count {
            found.append("残機が出来事なしに減った")
        }
        return found
    }

    static func points(of event: GameEvent) -> Int {
        switch event {
        case .enemyDestroyed(_, let points, _), .saucerDestroyed(let points, _), .perfect(let points): points
        case .stageStarted, .stageCleared, .flagshipDamaged, .shipDestroyed, .wingLost, .shipCaptured, .shipRespawned,
            .captiveRescued, .captiveLost, .captiveShot, .nearMiss, .gameOver:
            0
        }
    }

    static func isShipLoss(_ event: GameEvent) -> Bool {
        switch event {
        case .shipDestroyed, .wingLost, .captiveLost, .captiveShot: true
        case .stageStarted, .stageCleared, .enemyDestroyed, .flagshipDamaged, .saucerDestroyed, .shipCaptured,
            .shipRespawned, .captiveRescued, .nearMiss, .perfect, .gameOver:
            false
        }
    }

    /// 戦うステージでは、ステージの始まりを除いて敵の数は増えない。ボーナスステージは 20 機より多く出さない。
    static func population(before: Game, step: GameStep) -> [String] {
        guard before.stage == step.game.stage else {
            return []
        }
        switch step.game.stage.kind {
        case .combat:
            return step.game.enemies.count > before.enemies.count ? ["敵が増えた"] : []
        case .bonus:
            return step.game.bonus.spawned > BonusProgress.total ? ["ボーナスの敵が多すぎる"] : []
        }
    }
}
