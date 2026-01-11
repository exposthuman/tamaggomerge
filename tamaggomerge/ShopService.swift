import Foundation

final class ShopService {
    static let shared = ShopService()

    private init() {}

    func purchase(item: Item) -> Bool {
        let state = GameState.shared
        guard state.canAfford(item: item) else {
            return false
        }

        state.deduct(item: item)
        state.addOwned(itemId: item.id)
        return true
    }
}
