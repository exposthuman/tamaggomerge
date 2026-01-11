import SpriteKit

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

    private func setupUI() {
        guard let room else { return }

        roomLabel.text = room.name
        roomLabel.fontSize = 26
        roomLabel.fontColor = .darkGray
        roomLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        addChild(roomLabel)

        balanceLabel.fontSize = 16
        balanceLabel.fontColor = .darkGray
        balanceLabel.horizontalAlignmentMode = .left
        balanceLabel.position = CGPoint(x: 20, y: size.height - 30)
        addChild(balanceLabel)

        statsLabel.fontSize = 16
        statsLabel.fontColor = .darkGray
        statsLabel.horizontalAlignmentMode = .left
        statsLabel.position = CGPoint(x: 20, y: size.height - 55)
        addChild(statsLabel)

        messageLabel.fontSize = 14
        messageLabel.fontColor = .gray
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height - 80)
        addChild(messageLabel)

        petNode.fillColor = SKColor(red: 0.5, green: 0.8, blue: 0.7, alpha: 1.0)
        petNode.strokeColor = .clear
        petNode.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        petNode.name = "pet"
        addChild(petNode)

        let petLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        petLabel.text = "Pet"
        petLabel.fontSize = 14
        petLabel.fontColor = .white
        petLabel.verticalAlignmentMode = .center
        petNode.addChild(petLabel)

        setupNavigation()
        setupItemList(room: room)
    }

    private func setupNavigation() {
        let roomIds = catalog.roomOrder
        guard let index = roomIds.firstIndex(of: roomId) else { return }

        if index > 0 {
            let previous = SKLabelNode(fontNamed: "AvenirNext-Bold")
            previous.text = "◀︎"
            previous.fontSize = 30
            previous.fontColor = .darkGray
            previous.position = CGPoint(x: 30, y: size.height / 2)
            previous.name = "nav:previous"
            addChild(previous)
        }

        if index < roomIds.count - 1 {
            let next = SKLabelNode(fontNamed: "AvenirNext-Bold")
            next.text = "▶︎"
            next.fontSize = 30
            next.fontColor = .darkGray
            next.position = CGPoint(x: size.width - 30, y: size.height / 2)
            next.name = "nav:next"
            addChild(next)
        }
    }

    private func setupItemList(room: Room) {
        let startX: CGFloat = 20
        var currentY = CGFloat(120)

        let header = SKLabelNode(fontNamed: "AvenirNext-Bold")
        header.text = "Shop"
        header.fontSize = 18
        header.fontColor = .darkGray
        header.horizontalAlignmentMode = .left
        header.position = CGPoint(x: startX, y: currentY + 25)
        addChild(header)

        for item in room.items {
            let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
            label.text = "\(item.name) - \(item.price) \(item.currency == .soft ? "soft" : "hard")"
            label.fontSize = 14
            label.fontColor = .black
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(x: startX, y: currentY)
            label.name = "item:\(item.id)"
            addChild(label)
            itemLabels[item.id] = label
            currentY -= 20
        }
    }

    private func populateSlots() {
        guard let room else { return }
        for slot in room.slots {
            let slotNode = SKShapeNode(rectOf: CGSize(width: 70, height: 50), cornerRadius: 8)
            slotNode.strokeColor = SKColor.darkGray
            slotNode.lineWidth = 1.5
            slotNode.fillColor = SKColor(white: 1.0, alpha: 0.8)
            slotNode.position = CGPoint(x: size.width * CGFloat(slot.x), y: size.height * CGFloat(slot.y))
            slotNode.name = "slot:\(slot.id)"
            addChild(slotNode)
            slotNodes[slot.id] = slotNode

            let label = SKLabelNode(fontNamed: "AvenirNext-Regular")
            label.text = "Slot"
            label.fontSize = 12
            label.fontColor = .gray
            label.verticalAlignmentMode = .center
            slotNode.addChild(label)

            if let itemId = state.placedItemId(in: roomId, slotId: slot.id),
               let placedItem = room.items.first(where: { $0.id == itemId }) {
                placeItemNode(item: placedItem, on: slotNode)
            }
        }
    }

    private func placeItemNode(item: Item, on slotNode: SKShapeNode) {
        let itemNode = SKLabelNode(fontNamed: "AvenirNext-Bold")
        itemNode.text = item.name
        itemNode.fontSize = 12
        itemNode.fontColor = .systemBlue
        itemNode.verticalAlignmentMode = .center
        itemNode.name = "placed:\(item.id)"
        slotNode.addChild(itemNode)
    }

    private func updateBalances() {
        let soft = state.balances[.soft] ?? 0
        let hard = state.balances[.hard] ?? 0
        balanceLabel.text = "Soft: \(soft) | Hard: \(hard)"
    }

    private func updateStats() {
        statsLabel.text = "Happiness: \(state.petStats.happiness) | Energy: \(state.petStats.energy)"
    }

    private func updateMessage(_ text: String) {
        messageLabel.text = text
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)

        for node in nodes {
            if let name = node.name, name.hasPrefix("nav:") {
                handleNavigation(name: name)
                return
            }

            if let name = node.name, name.hasPrefix("item:") {
                handleItemTap(itemId: String(name.dropFirst(5)))
                return
            }

            if let name = node.name, name.hasPrefix("slot:") {
                handleSlotTap(slotId: String(name.dropFirst(5)))
                return
            }
        }
    }

    private func handleNavigation(name: String) {
        let roomIds = catalog.roomOrder
        guard let index = roomIds.firstIndex(of: roomId) else { return }
        let nextIndex: Int

        if name == "nav:previous" {
            nextIndex = index - 1
        } else {
            nextIndex = index + 1
        }

        guard roomIds.indices.contains(nextIndex) else { return }
        let nextRoomId = roomIds[nextIndex]
        let nextScene = RoomScene(roomId: nextRoomId, size: size)
        let transition = SKTransition.push(with: name == "nav:previous" ? .right : .left, duration: 0.35)
        view?.presentScene(nextScene, transition: transition)
    }

    private func handleItemTap(itemId: String) {
        guard let room, let item = room.items.first(where: { $0.id == itemId }) else { return }

        if state.ownedItems.contains(itemId) {
            selectedItem = item
            updateMessage("\(item.name) ready. Tap a slot to place it.")
        } else if ShopService.shared.purchase(item: item) {
            selectedItem = item
            updateMessage("Purchased \(item.name)! Tap a slot to place it.")
        } else {
            updateMessage("Not enough \(item.currency == .soft ? "soft" : "hard") currency.")
        }

        updateBalances()
    }

    private func handleSlotTap(slotId: String) {
        guard let room, let slotNode = slotNodes[slotId] else { return }
        guard let item = selectedItem else {
            updateMessage("Select an item to place first.")
            return
        }

        if state.placedItemId(in: roomId, slotId: slotId) != nil {
            updateMessage("That slot is already occupied.")
            return
        }

        state.place(item: item, in: roomId, slotId: slotId)
        placeItemNode(item: item, on: slotNode)
        selectedItem = nil
        updateStats()
        updateMessage("\(item.name) placed! Pet loved it.")
        animatePetReaction()
    }

    private func animatePetReaction() {
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let wiggleLeft = SKAction.rotate(byAngle: 0.1, duration: 0.1)
        let wiggleRight = SKAction.rotate(byAngle: -0.2, duration: 0.2)
        let reset = SKAction.rotate(toAngle: 0, duration: 0.1)
        let sequence = SKAction.sequence([scaleUp, wiggleLeft, wiggleRight, reset, scaleDown])
        petNode.run(sequence)
    }
}
