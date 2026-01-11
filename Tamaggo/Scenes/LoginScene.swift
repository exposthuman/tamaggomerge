import SpriteKit

final class LoginScene: BaseScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setTitle("Login")
        createButton(title: "Continue", name: "continue", y: size.height / 2)
        createButton(title: "Back", name: "back", y: size.height / 2 - 60)
    }

    private func createButton(title: String, name: String, y: CGFloat) {
        let label = SKLabelNode(text: title)
        label.fontName = "AvenirNext-Regular"
        label.fontSize = 20
        label.position = CGPoint(x: size.width / 2, y: y)
        label.name = name
        addChild(label)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = nodes(at: location)
        for node in nodes {
            switch node.name {
            case "continue":
                let scene = GameScene(size: size)
                navigator?.navigate(to: scene, transition: .push(with: .left, duration: 0.3))
            case "back":
                let scene = WelcomeScene(size: size)
                navigator?.navigate(to: scene, transition: .moveIn(with: .left, duration: 0.3))
            default:
                break
            }
        }
    }
}
