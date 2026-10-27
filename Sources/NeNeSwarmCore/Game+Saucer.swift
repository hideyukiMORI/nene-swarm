/// UFO（FR-02c）。戦うステージでときどき画面の上端を横切る。
extension Game {
    /// UFO が消えてから次に出るまでの刻みの数。
    static let saucerInterval = 600

    mutating func advanceSaucer(using generator: inout some RandomNumberGenerator) {
        guard case .combat = stage.kind else {
            return
        }
        switch saucer {
        case .absent(let ticksLeft):
            if ticksLeft > 1 {
                saucer = .absent(ticksLeft: ticksLeft - 1)
            } else {
                let heading = Int.random(in: 0..<2, using: &generator) == 0 ? -1 : 1
                let points = Saucer.pointsTable.randomElement(using: &generator) ?? Saucer.pointsTable[0]
                saucer = .flying(Saucer(heading: heading, points: points))
            }
        case .flying(var current):
            current.x += Saucer.speed * current.heading
            let gone = current.heading > 0 ? current.x >= Field.width : current.box.right <= 0
            saucer = gone ? .absent(ticksLeft: Game.saucerInterval) : .flying(current)
        }
    }
}
