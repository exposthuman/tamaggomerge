import SwiftUI

struct PetSelectionView: View {
    let pets: [Pet]
    let onSelect: (Pet) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Выберите питомца")
                .font(.title2)
                .bold()

            ForEach(pets) { pet in
                Button {
                    onSelect(pet)
                } label: {
                    HStack {
                        Text(pet.displayName)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
            }
        }
        .padding()
    }
}
