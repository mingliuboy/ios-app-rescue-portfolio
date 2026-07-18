import Foundation

struct User: Decodable, Equatable, Identifiable, Sendable {
    let id: Int
    let name: String
    let email: String
}
