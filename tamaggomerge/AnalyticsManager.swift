//
//  AnalyticsManager.swift
//  tamaggomerge
//
//  Created by admin on 11.01.2026.
//

import Foundation

enum AnalyticsEvent: String {
    case login
    case startMinigame
    case purchase
    case spendCurrency
    case buyItem
}

final class AnalyticsManager {
    static let shared = AnalyticsManager()

    private let queue = DispatchQueue(label: "analytics.queue", qos: .utility)

    private init() {}

    func log(_ event: AnalyticsEvent, metadata: [String: String] = [:]) {
        queue.async {
            let metadataPayload = metadata
                .map { "\($0.key)=\($0.value)" }
                .sorted()
                .joined(separator: ", ")
            if metadataPayload.isEmpty {
                print("[Analytics] \(event.rawValue)")
            } else {
                print("[Analytics] \(event.rawValue) {\(metadataPayload)}")
            }
        }
    }
}
