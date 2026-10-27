import NeNeSwarmCore

/// 盤面の中を描く。自機・敵・弾・トーチカ・爆発・ビームは空白のセルの背景色だけで描き、文字を書かない（FR-07）。
struct FieldPainter {
    let layout: ScreenLayout
    let theme: Theme

    /// 盤面を地の色で塗る。
    func clear(_ grid: inout Grid) {
        for row in 0..<ScreenLayout.fieldHeight {
            grid.paint(
                column: layout.fieldColumn, row: layout.fieldRow + row, width: ScreenLayout.fieldWidth,
                color: theme.ground)
        }
    }

    /// 遊んでいるゲームを描く。
    func draw(_ game: Game, into grid: inout Grid) {
        for shield in game.shields {
            drawShield(shield, into: &grid)
        }
        for enemy in game.enemies {
            if let ray = game.beam(of: enemy) {
                drawBeam(ray, tick: game.tick, into: &grid)
            }
        }
        for enemy in game.enemies {
            drawEnemy(enemy, tick: game.tick, into: &grid)
        }
        if let hull = game.captiveHull {
            fill(hull, theme.ship, into: &grid)
        }
        if case .flying(let saucer) = game.saucer {
            fill(saucer.box, theme.saucer, into: &grid)
        }
        if case .active(let ship) = game.ship {
            for hull in ship.hulls {
                fill(hull, theme.ship, into: &grid)
            }
        }
        for shot in game.playerShots {
            drawShot(shot, theme.playerShot, into: &grid)
        }
        for shot in game.enemyShots {
            drawShot(shot, theme.enemyShot, into: &grid)
        }
    }

    private func drawShield(_ shield: Shield, into grid: inout Grid) {
        for row in 0..<Shield.rows {
            for column in 0..<Shield.columns where shield.isStanding(column: column, row: row) {
                let left = Field.units(shield.leftColumn + column)
                let top = Field.units(Shield.topRow + row)
                fill(
                    Box(origin: Point(x: left, y: top), width: Field.cellUnits, height: Field.cellUnits), theme.shield,
                    into: &grid)
            }
        }
    }

    /// 敵は 4 桁。2 コマで羽ばたく（内側の 2 桁か外側の 2 桁を地の色にする）。爆発中は文字の色と地の色が交互に散る。
    private func drawEnemy(_ enemy: Enemy, tick: Int, into grid: inout Grid) {
        let color = enemy.hitsLeft < enemy.kind.toughness ? theme.accentAlt : theme.color(of: enemy.kind)
        let pattern: [Rgb]
        switch enemy.motion {
        case .exploding(let ticksLeft):
            let spark = ticksLeft % 2 == 0 ? theme.text : theme.accent
            pattern =
                ticksLeft > 6
                ? [spark, theme.ground, theme.ground, spark] : [theme.ground, spark, spark, theme.ground]
        case .inSwarm, .diving, .beaming, .returning, .flyby:
            let open = (tick / 8 + enemy.id) % 2 == 0
            pattern = open ? [color, color, color, color] : [color, theme.ground, theme.ground, color]
        }
        let column = FieldMapping.column(enemy.position.x)
        let row = FieldMapping.row(top: enemy.position.y, height: Enemy.height)
        for (offset, cell) in pattern.enumerated() {
            paint(column: column + offset, row: row, color: cell, into: &grid)
        }
    }

    /// ビームは 1 行おきの縞で、刻みごとに縞が下へ流れる。
    private func drawBeam(_ ray: Box, tick: Int, into grid: inout Grid) {
        let top = Field.cell(ray.origin.y)
        let bottom = Field.cell(ray.bottom - 1)
        guard top <= bottom else {
            return
        }
        for row in top...bottom where (row + tick / 4) % 2 == 0 {
            let first = FieldMapping.column(ray.origin.x)
            for column in first..<FieldMapping.column(ray.right) {
                paint(column: column, row: row, color: theme.beam, into: &grid)
            }
        }
    }

    /// 弾は 2 桁（真ん中を含む桁とその右）。
    private func drawShot(_ shot: Shot, _ color: Rgb, into grid: inout Grid) {
        let column = FieldMapping.column(shot.box.centerX - FieldMapping.unitsPerColumn / 2)
        let row = FieldMapping.row(top: shot.position.y, height: Shot.height)
        paint(column: column, row: row, color: color, into: &grid)
        paint(column: column + 1, row: row, color: color, into: &grid)
    }

    /// 箱を塗る（真ん中の行の 1 行）。
    private func fill(_ box: Box, _ color: Rgb, into grid: inout Grid) {
        let row = FieldMapping.row(top: box.origin.y, height: box.height)
        for column in FieldMapping.column(box.origin.x)..<FieldMapping.column(box.right) {
            paint(column: column, row: row, color: color, into: &grid)
        }
    }

    /// 盤面の中だけを 1 セル塗る（はみ出す分は捨てる）。
    private func paint(column: Int, row: Int, color: Rgb, into grid: inout Grid) {
        guard (0..<ScreenLayout.fieldWidth).contains(column), (0..<ScreenLayout.fieldHeight).contains(row) else {
            return
        }
        grid.paint(column: layout.fieldColumn + column, row: layout.fieldRow + row, width: 1, color: color)
    }
}
