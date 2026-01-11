import Foundation

struct PetState: Codable, Equatable {
    var hunger: Double
    var happiness: Double
    var energy: Double
    var lastInteractionAt: Date

    init(hunger: Double = 0.4, happiness: Double = 0.6, energy: Double = 0.7, lastInteractionAt: Date = Date()) {
        self.hunger = hunger
        self.happiness = happiness
        self.energy = energy
        self.lastInteractionAt = lastInteractionAt
    }

    mutating func applyDegradation(from lastDate: Date, to currentDate: Date) {
        let elapsed = max(0, currentDate.timeIntervalSince(lastDate))
        let hours = elapsed / 3600

        hunger = clamp(hunger + hours * 0.08)
        happiness = clamp(happiness - hours * 0.05)
        energy = clamp(energy - hours * 0.06)
        lastInteractionAt = currentDate
    }

    mutating func feed() {
        hunger = clamp(hunger - 0.25)
        energy = clamp(energy + 0.1)
        lastInteractionAt = Date()
    }

    mutating func pet() {
        happiness = clamp(happiness + 0.2)
        energy = clamp(energy + 0.05)
        lastInteractionAt = Date()
    }

    private func clamp(_ value: Double) -> Double {
        min(max(value, 0.0), 1.0)
    }
}
