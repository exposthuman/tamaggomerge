//
//  GameViewController.swift
//  tamaggomerge
//
//  Created by admin on 11.01.2026.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = GKScene(fileNamed: "GameScene") {
            if let sceneNode = scene.rootNode as? GameScene {
                sceneNode.entities = scene.entities
                sceneNode.graphs = scene.graphs
                sceneNode.scaleMode = .aspectFill

                if let view = self.view as? SKView {
                    view.presentScene(sceneNode)
                    view.ignoresSiblingOrder = true
                    view.shouldCullNonVisibleNodes = true
                    view.preferredFramesPerSecond = 60
                    view.showsFPS = false
                    view.showsNodeCount = false
                    view.showsDrawCount = false
                }
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
