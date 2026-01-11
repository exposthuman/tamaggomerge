//
//  GameScene.swift
//  tamaggomerge
//
//  Created by admin on 11.01.2026.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()

    private var lastUpdateTime: TimeInterval = 0
    private var economy = EconomyState()

    private var buttons: [String: SKLabelNode] = [:]
    private var currencyLabel: SKLabelNode?
    private var statusLabel: SKLabelNode?

    private var onboardingOverlay: SKNode?
    private var onboardingStepLabel: SKLabelNode?
    private var onboardingIndex = 0
    private let onboardingKey = "hasCompletedOnboarding"
    private let onboardingSteps = [
        "Добро пожаловать! Это краткий туториал после регистрации.",
        "Нажмите Login, чтобы получить бонус и создать сессию.",
        "Запускайте мини-игру и тратьте валюту на покупки.",
        "Конвертируйте печеньки в монеты для новых предметов."
    ]

    override func sceneDidLoad() {
        lastUpdateTime = 0
        shouldCullNonVisibleNodes = true
        backgroundColor = SKColor.black

        setupUI()
        updateHUD()
        showOnboardingIfNeeded()
    }

    private func setupUI() {
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "tamaggomerge"
        title.fontSize = 36
        title.fontColor = .white
        title.position = CGPoint(x: size.width * 0.5, y: size.height * 0.85)
        addChild(title)

        currencyLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        currencyLabel?.fontSize = 18
        currencyLabel?.fontColor = .white
        currencyLabel?.horizontalAlignmentMode = .center
        currencyLabel?.position = CGPoint(x: size.width * 0.5, y: size.height * 0.76)
        if let currencyLabel {
            addChild(currencyLabel)
        }

        statusLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
        statusLabel?.fontSize = 14
        statusLabel?.fontColor = .lightGray
        statusLabel?.horizontalAlignmentMode = .center
        statusLabel?.position = CGPoint(x: size.width * 0.5, y: size.height * 0.12)
        if let statusLabel {
            addChild(statusLabel)
        }

        let buttonTitles: [(String, String)] = [
            ("loginButton", "Login"),
            ("minigameButton", "Start Minigame"),
            ("purchaseButton", "Purchase (5 coins)"),
            ("spendButton", "Spend Currency (2 coins)"),
            ("buyItemButton", "Buy Item (3 coins)"),
            ("convertButton", "Convert Cookies")
        ]

        let startY = size.height * 0.6
        let spacing: CGFloat = 42
        for (index, pair) in buttonTitles.enumerated() {
            let button = makeButton(title: pair.1)
            button.name = pair.0
            button.position = CGPoint(x: size.width * 0.5, y: startY - CGFloat(index) * spacing)
            addChild(button)
            buttons[pair.0] = button
        }
    }

    private func makeButton(title: String) -> SKLabelNode {
        let button = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        button.text = title
        button.fontSize = 20
        button.fontColor = .systemTeal
        button.horizontalAlignmentMode = .center
        button.verticalAlignmentMode = .center
        return button
    }

    private func updateHUD(message: String? = nil) {
        currencyLabel?.text = "Coins: \(economy.coins) | Cookies: \(economy.cookies) | Items: \(economy.inventory.values.reduce(0, +))"
        if let message {
            statusLabel?.text = message
        } else {
            statusLabel?.text = "Tap a button to simulate gameplay events."
        }
    }

    private func showOnboardingIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: onboardingKey) else { return }
        presentOnboarding()
    }

    private func presentOnboarding() {
        onboardingIndex = 0

        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = SKColor.black.withAlphaComponent(0.75)
        overlay.strokeColor = .clear
        overlay.zPosition = 100
        overlay.name = "onboardingOverlay"
        overlay.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)

        let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
        label.fontSize = 18
        label.fontColor = .white
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = size.width * 0.8
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = .zero
        label.text = onboardingSteps.first
        overlay.addChild(label)

        let hint = SKLabelNode(fontNamed: "AvenirNext-Regular")
        hint.fontSize = 14
        hint.fontColor = .lightGray
        hint.position = CGPoint(x: 0, y: -80)
        hint.text = "Tap to continue"
        overlay.addChild(hint)

        addChild(overlay)
        onboardingOverlay = overlay
        onboardingStepLabel = label
    }

    private func advanceOnboarding() {
        onboardingIndex += 1
        if onboardingIndex >= onboardingSteps.count {
            UserDefaults.standard.set(true, forKey: onboardingKey)
            onboardingOverlay?.removeFromParent()
            onboardingOverlay = nil
            onboardingStepLabel = nil
            updateHUD(message: "Tutorial completed. Welcome back!")
            return
        }
        onboardingStepLabel?.text = onboardingSteps[onboardingIndex]
    }

    private func handleButtonTap(named name: String) {
        switch name {
        case "loginButton":
            economy.grantCookies(5)
            AnalyticsManager.shared.log(.login)
            updateHUD(message: "Login bonus: +5 cookies")
        case "minigameButton":
            economy.grantCookies(12)
            AnalyticsManager.shared.log(.startMinigame)
            updateHUD(message: "Mini-game reward: +12 cookies")
        case "purchaseButton":
            if economy.purchase(cost: 5) {
                AnalyticsManager.shared.log(.purchase, metadata: ["cost": "5"])
                updateHUD(message: "Purchase completed for 5 coins")
            } else {
                updateHUD(message: "Not enough coins for purchase")
            }
        case "spendButton":
            if economy.spendCoins(2) {
                AnalyticsManager.shared.log(.spendCurrency, metadata: ["amount": "2"])
                updateHUD(message: "Spent 2 coins")
            } else {
                updateHUD(message: "Not enough coins to spend")
            }
        case "buyItemButton":
            if economy.buyItem(id: "Hat", cost: 3) {
                AnalyticsManager.shared.log(.buyItem, metadata: ["item": "Hat", "cost": "3"])
                updateHUD(message: "Item purchased: Hat")
            } else {
                updateHUD(message: "Not enough coins to buy item")
            }
        case "convertButton":
            let gained = economy.convertCookiesToCoins()
            if gained > 0 {
                updateHUD(message: "Converted cookies into \(gained) coins")
            } else {
                updateHUD(message: "Need more cookies to convert")
            }
        default:
            break
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if onboardingOverlay != nil {
            advanceOnboarding()
            return
        }

        let nodesAtPoint = nodes(at: location)
        if let tappedNode = nodesAtPoint.first(where: { node in
            guard let name = node.name else { return false }
            return buttons[name] != nil
        }), let name = tappedNode.name {
            handleButtonTap(named: name)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let dt = currentTime - lastUpdateTime
        for entity in entities {
            entity.update(deltaTime: dt)
        }
        lastUpdateTime = currentTime
    }
}
