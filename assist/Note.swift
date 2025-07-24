import Foundation

struct Note: Identifiable, Codable {
    let id: UUID
    let text: String
    let timestamp: Date
}
