import Foundation

protocol AnalyticsService {
    func track(event: String, properties: [String: String])
}

final class StubAnalyticsService: AnalyticsService {
    func track(event: String, properties: [String: String]) {
        // TODO: Replace with analytics SDK integration.
        _ = (event, properties)
    }
}
