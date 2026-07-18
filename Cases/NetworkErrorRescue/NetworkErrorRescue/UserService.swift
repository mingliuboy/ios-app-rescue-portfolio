import Foundation

nonisolated protocol UserServiceProtocol: Sendable {
    func fetchUsers() async throws -> [User]
}

nonisolated struct UserService: UserServiceProtocol {
    private let session: URLSession
    private let endpoint: URL

    init(
        session: URLSession = .shared,
        endpoint: URL = URL(string: "https://jsonplaceholder.typicode.com/users")!
    ) {
        self.session = session
        self.endpoint = endpoint
    }

    func fetchUsers() async throws -> [User] {
        let (data, response) = try await session.data(from: endpoint)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw UserServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw UserServiceError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode([User].self, from: data)
        } catch {
            throw UserServiceError.invalidData
        }
    }
}

enum UserServiceError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case invalidData

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "The server returned an invalid response."
        case let .httpStatus(statusCode):
            "The server returned status code \(statusCode)."
        case .invalidData:
            "The response could not be read."
        }
    }
}
