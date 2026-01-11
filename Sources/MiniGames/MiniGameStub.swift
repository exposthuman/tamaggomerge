import Foundation

public protocol MiniGameRewarding {
    var rewardSoftCurrency: Int { get }
    func grantReward(using currencyService: CurrencyService)
}

public struct MatchThreeMiniGameStub: MiniGameRewarding {
    public let rewardSoftCurrency: Int

    public init(rewardSoftCurrency: Int = 50) {
        self.rewardSoftCurrency = rewardSoftCurrency
    }

    public func grantReward(using currencyService: CurrencyService) {
        currencyService.addSoft(rewardSoftCurrency)
    }
}

public struct PuzzleMiniGameStub: MiniGameRewarding {
    public let rewardSoftCurrency: Int

    public init(rewardSoftCurrency: Int = 75) {
        self.rewardSoftCurrency = rewardSoftCurrency
    }

    public func grantReward(using currencyService: CurrencyService) {
        currencyService.addSoft(rewardSoftCurrency)
    }
}
