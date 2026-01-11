import Foundation

struct Pet: Identifiable, Equatable {
    let id: String
    let displayName: String
    let spriteAtlasName: String

    static let all: [Pet] = [
        Pet(id: "fox", displayName: "Лис", spriteAtlasName: "Fox"),
        Pet(id: "cat", displayName: "Кот", spriteAtlasName: "Cat"),
        Pet(id: "dog", displayName: "Пёс", spriteAtlasName: "Dog")
    ]
}
