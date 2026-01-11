import SpriteKit

final class WelcomeScene: BaseScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setTitle("Welcome")
        createButton(title: "Login", name: "login", y: size.height / 2 + 20)
        createButton(title: "Sign Up", name: "signup", y: size.height / 2 - 40)
    }

    private func createButton(title: String, name: String, y: CGFloat) {
        let label = SKLabelNode(text: title)
        label.fontName = "AvenirNext-Regular"
        label.fontSize = 22
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
            case "login":
                let scene = LoginScene(size: size)
                navigator?.navigate(to: scene, transition: .fade(withDuration: 0.3))
            case "signup":
                let scene = SignUpScene(size: size)
                navigator?.navigate(to: scene, transition: .fade(withDuration: 0.3))
            default:
                break
            }
        }
    }
}
