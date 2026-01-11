import SpriteKit

final class GameScene: BaseScene {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setTitle("Main")
        let label = SKLabelNode(text: "Main Scene")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 24
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)
    }
}
