import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: UsersViewModel

    @MainActor
    init() {
        _viewModel = StateObject(wrappedValue: UsersViewModel())
    }

    @MainActor
    init(viewModel: UsersViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.users.isEmpty {
                    ProgressView("Loading users…")
                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.users.isEmpty {
                    ContentUnavailableView {
                        Label("Unable to Load Users", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(errorMessage)
                    } actions: {
                        Button("Try Again") {
                            Task { await viewModel.loadUsers() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if viewModel.hasLoaded && viewModel.users.isEmpty {
                    ContentUnavailableView(
                        "No Users",
                        systemImage: "person.3",
                        description: Text("The server returned an empty list.")
                    )
                } else {
                    usersList
                }
            }
            .navigationTitle("Users")
            .toolbar {
                Button {
                    Task { await viewModel.loadUsers() }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Label("Reload", systemImage: "arrow.clockwise")
                    }
                }
                .disabled(viewModel.isLoading)
            }
            .task {
                await viewModel.loadUsers()
            }
        }
    }

    private var usersList: some View {
        List(viewModel.users) { user in
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)

                Text(user.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityElement(children: .combine)
        }
        .refreshable {
            await viewModel.loadUsers()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: UsersViewModel(service: PreviewUserService()))
            .previewDisplayName("Loaded")
    }
}

private struct PreviewUserService: UserServiceProtocol {
    func fetchUsers() async throws -> [User] {
        [User(id: 1, name: "Ada Lovelace", email: "ada@example.com")]
    }
}
