/// 体当たりと捕獲ビーム（FR-02・FR-02b）。
extension Game {
    /// 隊列の外を飛ぶ敵と自機がぶつかったら、敵は倒れ（親玉も 1 回で）、自機は 1 機失う。
    mutating func resolveRamming(events: inout [GameEvent]) {
        for index in enemies.indices {
            let enemy = enemies[index]
            guard enemy.motion.isSolid, !enemy.motion.isInSwarm, let hull = struckHull(enemy.box) else {
                continue
            }
            enemies[index].hitsLeft = 1
            strike(at: index, events: &events)
            loseHull(at: hull, cause: .rammed, events: &events)
            guard shipIsActive else {
                return
            }
        }
    }

    /// 捕獲ビームの箱（親玉の下端から、出し始めてからの刻みに応じて下へ伸びる。3 セル幅）。ビームを出していなければ nil。
    ///
    /// 一度に盤面の下まで出すと、真下にいる自機は逃げようが無い。伸びる間に逃げられる（ADR 0008）。
    public func beam(of enemy: Enemy) -> Box? {
        guard case .beaming(let ticksLeft) = enemy.motion, enemy.box.bottom < Field.height else {
            return nil
        }
        let reach = min(Field.height - enemy.box.bottom, (Game.beamTicks - ticksLeft + 1) * Game.beamGrowth)
        return Box(
            origin: Point(x: enemy.box.centerX - Game.beamHalfWidth, y: enemy.box.bottom),
            width: 2 * Game.beamHalfWidth, height: reach)
    }

    /// ビームが 1 刻みに伸びる量。
    static let beamGrowth = 4

    /// 捕獲ビームの幅の半分。
    static let beamHalfWidth = 3 * Field.cellUnits / 2

    /// ビームに入った機体を捕まえる。2 機並びなら入った方だけが捕まり、残った方は 1 機で続く。
    mutating func resolveBeams(events: inout [GameEvent]) {
        for index in enemies.indices {
            guard case .none = captive, let ray = beam(of: enemies[index]), let hull = struckHull(ray),
                case .active(var current) = ship
            else {
                continue
            }
            captive = .held(byEnemy: enemies[index].id)
            enemies[index].motion = .returning
            events.append(.shipCaptured)
            switch current.wing {
            case .dual:
                current.x += hull == 0 ? Ship.width : 0
                current.wing = .single
                ship = .active(current)
            case .single:
                retireShip(events: &events)
            }
            return
        }
    }
}
