import SwiftUI

public struct CurrencyBalanceView: View {
    private let soft: Int
    private let hard: Int

    public init(soft: Int, hard: Int) {
        self.soft = soft
        self.hard = hard
    }

    public var body: some View {
        HStack(spacing: 12) {
            balancePill(title: "Soft", value: soft, color: .blue)
            balancePill(title: "Hard", value: hard, color: .purple)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Soft \(soft), Hard \(hard)")
    }

    @ViewBuilder
    private func balancePill(title: String, value: Int, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(value)")
                .font(.caption.weight(.semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
        )
    }
}

#Preview {
    CurrencyBalanceView(soft: 1250, hard: 40)
        .padding()
}
