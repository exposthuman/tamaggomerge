import Foundation

final class MinigamesViewModel {
    private(set) var unlockedMinigames: [String]

    init(unlockedMinigames: [String]) {
        self.unlockedMinigames = unlockedMinigames
    }

    func unlock(_ minigame: String) {
        guard !unlockedMinigames.contains(minigame) else { return }
        unlockedMinigames.append(minigame)
    }
}
