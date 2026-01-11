import SpriteKit

protocol SceneNavigating: AnyObject {
    func navigate(to scene: SKScene, transition: SKTransition)
}

class BaseScene: SKScene {
    weak var navigator: SceneNavigating?

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .black
        if navigator == nil {
            navigator = view as? SceneNavigating ?? SceneNavigator(view: view)
        }
    }

    func setTitle(_ text: String) {
        let titleNode = SKLabelNode(text: text)
        titleNode.fontName = "AvenirNext-Bold"
        titleNode.fontSize = 28
        titleNode.position = CGPoint(x: size.width / 2, y: size.height - 80)
        titleNode.name = "title"
        addChild(titleNode)
    }
}

final class SceneNavigator: SceneNavigating {
    private weak var view: SKView?

    init(view: SKView) {
        self.view = view
    }

    func navigate(to scene: SKScene, transition: SKTransition) {
        scene.scaleMode = .resizeFill
        view?.presentScene(scene, transition: transition)
    }
}
