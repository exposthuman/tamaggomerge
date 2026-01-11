import UIKit
import SpriteKit

final class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = self.view as? SKView else { return }

        // 1) Онбординг, если еще не пройден
        if !UserDefaults.standard.bool(forKey: OnboardingScene.onboardingKey) {
            let onboarding = OnboardingScene(size: skView.bounds.size)
            onboarding.scaleMode = .aspectFill
            skView.presentScene(onboarding)
        } else {
            // 2) Основная сцена (комната)
            let scene = RoomScene(roomId: "living_room", size: skView.bounds.size)
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }

        // Общие настройки вью
        skView.ignoresSiblingOrder = true
        skView.shouldCullNonVisibleNodes = true
        skView.preferredFramesPerSecond = 60

        // Дебаг (можешь выключить позже)
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}
