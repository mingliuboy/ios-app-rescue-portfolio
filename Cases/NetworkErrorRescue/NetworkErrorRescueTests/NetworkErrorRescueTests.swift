import XCTest
@testable import NetworkErrorRescue

@MainActor
final class NetworkErrorRescueTests: XCTestCase {
    func testLoadUsersPublishesUsersOnSuccess() async {
        let expectedUsers = [User(id: 1, name: "Ada", email: "ada@example.com")]
        let service = MockUserService(result: .success(expectedUsers))
        let viewModel = UsersViewModel(service: service)

        await viewModel.loadUsers()

        XCTAssertEqual(viewModel.users, expectedUsers)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.hasLoaded)
        XCTAssertEqual(service.fetchCallCount, 1)
    }

    func testLoadUsersPublishesReadableOfflineError() async {
        let service = MockUserService(
            result: .failure(URLError(.notConnectedToInternet))
        )
        let viewModel = UsersViewModel(service: service)

        await viewModel.loadUsers()

        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertEqual(
            viewModel.errorMessage,
            "You appear to be offline. Check your connection and try again."
        )
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.hasLoaded)
    }

    func testLoadUsersPublishesEmptyState() async {
        let service = MockUserService(result: .success([]))
        let viewModel = UsersViewModel(service: service)

        await viewModel.loadUsers()

        XCTAssertTrue(viewModel.users.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.hasLoaded)
    }
}

private final class MockUserService: UserServiceProtocol, @unchecked Sendable {
    private let result: Result<[User], Error>
    private(set) var fetchCallCount = 0

    init(result: Result<[User], Error>) {
        self.result = result
    }

    func fetchUsers() async throws -> [User] {
        fetchCallCount += 1
        return try result.get()
    }
}
