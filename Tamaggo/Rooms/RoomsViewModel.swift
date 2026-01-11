import Foundation

final class RoomsViewModel {
    private(set) var rooms: [RoomState]

    init(rooms: [RoomState]) {
        self.rooms = rooms
    }

    func updateRoom(_ room: RoomState) {
        if let index = rooms.firstIndex(where: { $0.id == room.id }) {
            rooms[index] = room
        }
    }
}
