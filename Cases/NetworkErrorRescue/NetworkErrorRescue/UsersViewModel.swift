import Foundation
import Combine

@MainActor
final class UsersViewModel: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var hasLoaded = false

    private let service: any UserServiceProtocol

    init(service: any UserServiceProtocol = UserService()) {
        self.service = service
    }

    func loadUsers() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            users = try await service.fetchUsers()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = Self.message(for: error)
        }
    }

    private static func message(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "You appear to be offline. Check your connection and try again."
            case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                return "The server could not be reached. Please try again later."
            case .timedOut:
                return "The request timed out. Please try again."
            default:
                break
            }
        }

        return error.localizedDescription
    }
}
