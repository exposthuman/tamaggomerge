import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(skView)
        let scene = WelcomeScene(size: skView.bounds.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
