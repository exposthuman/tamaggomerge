import SpriteKit
import GameplayKit

// MARK: - Match-3 + Cookie Physics
final class GameScene: SKScene, SKPhysicsContactDelegate {

    private struct Tile {
        let node: SKSpriteNode
        var type: Int
    }

    private let gridSize = 8
    private let tileTypes = 5
    private let cookieTypes = 4
    private let cookieRadius: CGFloat = 18

    private var grid: [[Tile?]] = []
    private var gridOrigin = CGPoint.zero
    private var tileSize: CGFloat = 0
    private var gridFrame = CGRect.zero

    private var selectedCell: (row: Int, col: Int)?
    private var isResolving = false

    private var scoreLabel: SKLabelNode?
    private var currencyLabel: SKLabelNode?
    private var dropIndicator: SKShapeNode?

    private var score = 0
    private var softCurrency = 0

    private var pendingCookieMerge = false

    override func sceneDidLoad() {
        backgroundColor = SKColor.black
        setupHud()
        setupGrid()
        setupPhysics()
        setupDropIndicator()
    }

    private func setupHud() {
        let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 18
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: size.height - 32)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
        self.scoreLabel = scoreLabel

        let currencyLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        currencyLabel.fontSize = 18
        currencyLabel.horizontalAlignmentMode = .right
        currencyLabel.position = CGPoint(x: size.width - 16, y: size.height - 32)
        currencyLabel.zPosition = 10
        addChild(currencyLabel)
        self.currencyLabel = currencyLabel

        refreshHud()
    }

    private func refreshHud() {
        scoreLabel?.text = "Score: \(score)"
        currencyLabel?.text = "Coins: \(softCurrency)"
    }

    private func setupGrid() {
        let availableWidth = size.width - 32
        let availableHeight = size.height * 0.7
        tileSize = min(availableWidth / CGFloat(gridSize), availableHeight / CGFloat(gridSize))

        let gridWidth = CGFloat(gridSize) * tileSize
        let gridHeight = CGFloat(gridSize) * tileSize
        gridOrigin = CGPoint(x: (size.width - gridWidth) / 2, y: 24)
        gridFrame = CGRect(x: gridOrigin.x, y: gridOrigin.y, width: gridWidth, height: gridHeight)

        grid = Array(repeating: Array(repeating: nil, count: gridSize), count: gridSize)

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let type = Int.random(in: 0..<tileTypes)
                let tile = makeTile(type: type, row: row, col: col)
                grid[row][col] = tile
            }
        }
    }

    private func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.contactDelegate = self
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsBody?.categoryBitMask = 1
    }

    private func setupDropIndicator() {
        let indicator = SKShapeNode(rectOf: CGSize(width: 4, height: 40), cornerRadius: 2)
        indicator.fillColor = .white
        indicator.strokeColor = .clear
        indicator.alpha = 0.6
        indicator.position = CGPoint(x: size.width / 2, y: size.height - 80)
        indicator.zPosition = 5
        addChild(indicator)
        dropIndicator = indicator
    }

    private func makeTile(type: Int, row: Int, col: Int) -> Tile {
        let node = SKSpriteNode(color: tileColor(for: type), size: CGSize(width: tileSize - 2, height: tileSize - 2))
        node.position = positionFor(row: row, col: col)
        node.zPosition = 2
        addChild(node)
        return Tile(node: node, type: type)
    }

    private func positionFor(row: Int, col: Int) -> CGPoint {
        CGPoint(
            x: gridOrigin.x + (CGFloat(col) + 0.5) * tileSize,
            y: gridOrigin.y + (CGFloat(row) + 0.5) * tileSize
        )
    }

    private func tileColor(for type: Int) -> SKColor {
        let palette: [SKColor] = [.systemPink, .systemTeal, .systemYellow, .systemPurple, .systemGreen, .systemOrange]
        return palette[type % palette.count]
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if gridFrame.contains(location) {
            handleGridTouch(at: location)
        } else {
            moveDropIndicator(to: location.x)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if !gridFrame.contains(location) {
            moveDropIndicator(to: location.x)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if gridFrame.contains(location) {
            return
        }
        moveDropIndicator(to: location.x)
        spawnCookie(atX: location.x)
    }

    private func handleGridTouch(at location: CGPoint) {
        guard !isResolving else { return }
        guard let cell = cellFor(point: location) else { return }
        if let selected = selectedCell {
            if isAdjacent(selected, cell) {
                swapTiles(from: selected, to: cell)
                selectedCell = nil
            } else {
                highlight(cell: cell)
                selectedCell = cell
            }
        } else {
            highlight(cell: cell)
            selectedCell = cell
        }
    }

    private func highlight(cell: (row: Int, col: Int)) {
        grid[cell.row][cell.col]?.node.run(SKAction.sequence([
            SKAction.scale(to: 1.15, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.08)
        ]))
    }

    private func cellFor(point: CGPoint) -> (row: Int, col: Int)? {
        let col = Int((point.x - gridOrigin.x) / tileSize)
        let row = Int((point.y - gridOrigin.y) / tileSize)
        guard row >= 0, row < gridSize, col >= 0, col < gridSize else { return nil }
        return (row, col)
    }

    private func isAdjacent(_ a: (row: Int, col: Int), _ b: (row: Int, col: Int)) -> Bool {
        let dRow = abs(a.row - b.row)
        let dCol = abs(a.col - b.col)
        return (dRow == 1 && dCol == 0) || (dRow == 0 && dCol == 1)
    }

    private func swapTiles(from: (row: Int, col: Int), to: (row: Int, col: Int)) {
        guard let tileA = grid[from.row][from.col], let tileB = grid[to.row][to.col] else { return }
        isResolving = true

        grid[from.row][from.col] = tileB
        grid[to.row][to.col] = tileA

        let actionA = SKAction.move(to: positionFor(row: to.row, col: to.col), duration: 0.15)
        let actionB = SKAction.move(to: positionFor(row: from.row, col: from.col), duration: 0.15)

        tileA.node.run(actionA)
        tileB.node.run(actionB) { [weak self] in
            self?.resolveGrid(afterSwap: (from, to))
        }
    }

    private func resolveGrid(afterSwap swapped: ((row: Int, col: Int), (row: Int, col: Int))? = nil) {
        let matches = findMatches()
        if matches.isEmpty {
            if let swapped = swapped {
                swapTilesBack(swapped.0, swapped.1)
            } else {
                isResolving = false
            }
            return
        }
        removeMatches(matches)
    }

    private func swapTilesBack(_ a: (row: Int, col: Int), _ b: (row: Int, col: Int)) {
        guard let tileA = grid[a.row][a.col], let tileB = grid[b.row][b.col] else { return }
        grid[a.row][a.col] = tileB
        grid[b.row][b.col] = tileA

        let actionA = SKAction.move(to: positionFor(row: b.row, col: b.col), duration: 0.15)
        let actionB = SKAction.move(to: positionFor(row: a.row, col: a.col), duration: 0.15)
        tileA.node.run(actionA)
        tileB.node.run(actionB) { [weak self] in
            self?.isResolving = false
        }
    }

    private func findMatches() -> Set<[Int]> {
        var matched = Set<[Int]>()
        for row in 0..<gridSize {
            var streak: [Int] = []
            var lastType: Int?
            for col in 0..<gridSize {
                if let tile = grid[row][col] {
                    if tile.type == lastType {
                        streak.append(col)
                    } else {
                        if lastType != nil, streak.count >= 3 {
                            for streakCol in streak { matched.insert([row, streakCol]) }
                        }
                        lastType = tile.type
                        streak = [col]
                    }
                } else {
                    if lastType != nil, streak.count >= 3 {
                        for streakCol in streak { matched.insert([row, streakCol]) }
                    }
                    lastType = nil
                    streak = []
                }
            }
            if lastType != nil, streak.count >= 3 {
                for streakCol in streak { matched.insert([row, streakCol]) }
            }
        }

        for col in 0..<gridSize {
            var streak: [Int] = []
            var lastType: Int?
            for row in 0..<gridSize {
                if let tile = grid[row][col] {
                    if tile.type == lastType {
                        streak.append(row)
                    } else {
                        if lastType != nil, streak.count >= 3 {
                            for streakRow in streak { matched.insert([streakRow, col]) }
                        }
                        lastType = tile.type
                        streak = [row]
                    }
                } else {
                    if lastType != nil, streak.count >= 3 {
                        for streakRow in streak { matched.insert([streakRow, col]) }
                    }
                    lastType = nil
                    streak = []
                }
            }
            if lastType != nil, streak.count >= 3 {
                for streakRow in streak { matched.insert([streakRow, col]) }
            }
        }
        return matched
    }

    private func removeMatches(_ matches: Set<[Int]>) {
        var removedCount = 0
        for coords in matches {
            let row = coords[0]
            let col = coords[1]
            if let tile = grid[row][col] {
                grid[row][col] = nil
                removedCount += 1
                tile.node.run(SKAction.sequence([
                    SKAction.scale(to: 0.1, duration: 0.12),
                    SKAction.removeFromParent()
                ]))
            }
        }
        addScore(points: removedCount * 10)
        run(SKAction.wait(forDuration: 0.15)) { [weak self] in
            self?.collapseGrid()
        }
    }

    private func collapseGrid() {
        for col in 0..<gridSize {
            var emptyRows: [Int] = []
            for row in 0..<gridSize {
                if grid[row][col] == nil {
                    emptyRows.append(row)
                } else if !emptyRows.isEmpty {
                    let targetRow = emptyRows.removeFirst()
                    grid[targetRow][col] = grid[row][col]
                    grid[row][col] = nil
                    if let tile = grid[targetRow][col] {
                        tile.node.run(SKAction.move(to: positionFor(row: targetRow, col: col), duration: 0.12))
                    }
                    emptyRows.append(row)
                }
            }
            for row in emptyRows {
                let type = Int.random(in: 0..<tileTypes)
                var tile = makeTile(type: type, row: row, col: col)
                tile.node.position.y = gridOrigin.y + CGFloat(gridSize + 1) * tileSize
                tile.node.run(SKAction.move(to: positionFor(row: row, col: col), duration: 0.15))
                grid[row][col] = tile
            }
        }

        run(SKAction.wait(forDuration: 0.2)) { [weak self] in
            self?.applyClusterization()
        }
    }

    private func applyClusterization() {
        var visited = Array(repeating: Array(repeating: false, count: gridSize), count: gridSize)
        var didChange = false

        for row in 0..<gridSize {
            for col in 0..<gridSize {
                guard let tile = grid[row][col], !visited[row][col] else { continue }
                var cluster: [(Int, Int)] = []
                floodFill(row: row, col: col, type: tile.type, visited: &visited, output: &cluster)
                if cluster.count >= 3 {
                    didChange = true
                    let upgradeType = (tile.type + 1) % tileTypes
                    if let first = cluster.first {
                        grid[first.0][first.1]?.type = upgradeType
                        grid[first.0][first.1]?.node.color = tileColor(for: upgradeType)
                    }
                    for (index, point) in cluster.enumerated() where index != 0 {
                        if let removing = grid[point.0][point.1] {
                            grid[point.0][point.1] = nil
                            removing.node.run(SKAction.sequence([
                                SKAction.scale(to: 0.1, duration: 0.12),
                                SKAction.removeFromParent()
                            ]))
                        }
                    }
                    addScore(points: cluster.count * 8)
                }
            }
        }

        if didChange {
            run(SKAction.wait(forDuration: 0.2)) { [weak self] in
                self?.collapseGrid()
            }
        } else {
            isResolving = false
        }
    }

    private func floodFill(row: Int, col: Int, type: Int, visited: inout [[Bool]], output: inout [(Int, Int)]) {
        guard row >= 0, row < gridSize, col >= 0, col < gridSize else { return }
        guard !visited[row][col], let tile = grid[row][col], tile.type == type else { return }
        visited[row][col] = true
        output.append((row, col))
        floodFill(row: row + 1, col: col, type: type, visited: &visited, output: &output)
        floodFill(row: row - 1, col: col, type: type, visited: &visited, output: &output)
        floodFill(row: row, col: col + 1, type: type, visited: &visited, output: &output)
        floodFill(row: row, col: col - 1, type: type, visited: &visited, output: &output)
    }

    private func addScore(points: Int) {
        score += points
        softCurrency += max(1, points / 10)
        refreshHud()
    }

    private func moveDropIndicator(to x: CGFloat) {
        let clampedX = min(max(x, 20), size.width - 20)
        dropIndicator?.position.x = clampedX
    }

    private func spawnCookie(atX x: CGFloat) {
        let type = Int.random(in: 0..<cookieTypes)
        let cookie = SKSpriteNode(color: cookieColor(for: type), size: CGSize(width: cookieRadius * 2, height: cookieRadius * 2))
        cookie.position = CGPoint(x: min(max(x, cookieRadius), size.width - cookieRadius), y: size.height - 40)
        cookie.zPosition = 3
        let body = SKPhysicsBody(circleOfRadius: cookieRadius)
        body.restitution = 0.2
        body.friction = 0.6
        body.linearDamping = 0.4
        body.categoryBitMask = 2
        body.contactTestBitMask = 2
        cookie.physicsBody = body
        cookie.userData = ["type": type]
        addChild(cookie)
    }

    private func cookieColor(for type: Int) -> SKColor {
        let palette: [SKColor] = [.systemRed, .systemBlue, .systemOrange, .systemGreen, .systemPurple]
        return palette[type % palette.count]
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node as? SKSpriteNode,
              let nodeB = contact.bodyB.node as? SKSpriteNode else { return }
        guard nodeA.userData?["type"] != nil, nodeB.userData?["type"] != nil else { return }
        pendingCookieMerge = true
    }

    override func update(_ currentTime: TimeInterval) {
        if pendingCookieMerge {
            pendingCookieMerge = false
            resolveCookieClusters()
        }
    }

    private func resolveCookieClusters() {
        let cookies = children
            .compactMap { $0 as? SKSpriteNode }
            .filter { $0.physicsBody != nil && $0.userData?["type"] != nil }

        var visited = Set<SKSpriteNode>()

        for cookie in cookies where !visited.contains(cookie) {
            var cluster: [SKSpriteNode] = []
            collectCookieCluster(from: cookie, cookies: cookies, visited: &visited, output: &cluster)
            if cluster.count >= 3 {
                let position = cluster.map { $0.position }.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
                let average = CGPoint(x: position.x / CGFloat(cluster.count), y: position.y / CGFloat(cluster.count))
                cluster.forEach { $0.removeFromParent() }
                spawnUpgradedCookie(at: average)
                addScore(points: cluster.count * 12)
            }
        }
    }

    private func collectCookieCluster(from seed: SKSpriteNode, cookies: [SKSpriteNode], visited: inout Set<SKSpriteNode>, output: inout [SKSpriteNode]) {
        guard !visited.contains(seed) else { return }
        guard let seedType = seed.userData?["type"] as? Int else { return }
        visited.insert(seed)
        output.append(seed)

        for other in cookies where !visited.contains(other) {
            guard let otherType = other.userData?["type"] as? Int, otherType == seedType else { continue }
            let distance = hypot(seed.position.x - other.position.x, seed.position.y - other.position.y)
            if distance <= cookieRadius * 2.2 {
                collectCookieCluster(from: other, cookies: cookies, visited: &visited, output: &output)
            }
        }
    }

    private func spawnUpgradedCookie(at position: CGPoint) {
        let type = Int.random(in: 0..<cookieTypes)
        let upgradedType = (type + 1) % cookieTypes
        let cookie = SKSpriteNode(color: cookieColor(for: upgradedType), size: CGSize(width: cookieRadius * 2.2, height: cookieRadius * 2.2))
        cookie.position = position
        cookie.zPosition = 3
        let body = SKPhysicsBody(circleOfRadius: cookieRadius * 1.1)
        body.restitution = 0.2
        body.friction = 0.6
        body.linearDamping = 0.4
        body.categoryBitMask = 2
        body.contactTestBitMask = 2
        cookie.physicsBody = body
        cookie.userData = ["type": upgradedType]
        addChild(cookie)
    } // <- закрыли spawnUpgradedCookie
} // <- закрыли GameScene

// MARK: - Rooms / Decoration
final class RoomScene: SKScene {
    private let roomId: String
    private let catalog = CatalogService.shared
    private let state = GameState.shared

    private var room: Room?
    private var selectedItem: Item?

    private let balanceLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let statsLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let messageLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let roomLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let petNode = SKShapeNode(circleOfRadius: 45)

    private var slotNodes: [String: SKShapeNode] = [:]
    private var itemLabels: [String: SKLabelNode] = [:]

    init(roomId: String, size: CGSize) {
        self.roomId = roomId
        super.init(size: size)
        scaleMode = .aspectFill
        backgroundColor = SKColor(red: 0.94, green: 0.95, blue: 0.98, alpha: 1.0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        room = catalog.room(for: roomId)
        setupUI()
        populateSlots()
        updateBalances()
        updateStats()
        updateMessage("Pick an item to buy, then tap a slot to place it.")
    }

    // ... весь твой код RoomScene без изменений ...

    private func animatePetReaction() {
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let wiggleLeft = SKAction.rotate(byAngle: 0.1, duration: 0.1)
        let wiggleRight = SKAction.rotate(byAngle: -0.2, duration: 0.2)
        let reset = SKAction.rotate(toAngle: 0, duration: 0.1)
        let sequence = SKAction.sequence([scaleUp, wiggleLeft, wiggleRight, reset, scaleDown])
        petNode.run(sequence)
    } // <- закрыли animatePetReaction
} // <- закрыли RoomScene
