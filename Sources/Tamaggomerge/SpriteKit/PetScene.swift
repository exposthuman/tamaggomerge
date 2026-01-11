import SpriteKit

final class PetScene: SKScene {
    private let petNode = SKSpriteNode()
    private var atlasName: String = ""

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        petNode.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(petNode)
        playIdle()
    }

    func configure(with pet: Pet) {
        atlasName = pet.spriteAtlasName
        playIdle()
    }

    func playIdle() {
        playAnimation(named: "idle")
    }

    func playHappy() {
        playAnimation(named: "happy")
    }

    func playSleep() {
        playAnimation(named: "sleep")
    }

    private func playAnimation(named name: String) {
        guard !atlasName.isEmpty else { return }
        let atlas = SKTextureAtlas(named: atlasName)
        let textures = atlas.textureNames
            .filter { $0.hasPrefix(name) }
            .sorted()
            .map { atlas.textureNamed($0) }

        guard !textures.isEmpty else { return }
        let action = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.15))
        petNode.removeAllActions()
        petNode.run(action, withKey: name)
        petNode.texture = textures.first
    }
}
