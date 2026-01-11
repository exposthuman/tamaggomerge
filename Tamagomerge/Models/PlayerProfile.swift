import Foundation
import FirebaseFirestore

struct PlayerProfile: Identifiable, Codable, Equatable {
    let id: String
    var displayName: String
    var email: String
    var createdAt: Date
    var updatedAt: Date

    init(id: String, displayName: String, email: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let displayName = data["displayName"] as? String,
            let email = data["email"] as? String,
            let createdTimestamp = data["createdAt"] as? Timestamp,
            let updatedTimestamp = data["updatedAt"] as? Timestamp
        else {
            return nil
        }

        self.id = document.documentID
        self.displayName = displayName
        self.email = email
        self.createdAt = createdTimestamp.dateValue()
        self.updatedAt = updatedTimestamp.dateValue()
    }

    var firestoreData: [String: Any] {
        [
            "displayName": displayName,
            "email": email,
            "createdAt": Timestamp(date: createdAt),
            "updatedAt": Timestamp(date: updatedAt)
        ]
    }
}
