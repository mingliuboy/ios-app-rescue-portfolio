import SwiftUI

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let email: String
}

struct ContentView: View {
    @State private var users: [User] = []

    var body: some View {
        NavigationStack {
            VStack {
                Button("Load Users") {
                    Task {
                        let url = URL(
                            string: "https://jsonplaceholder.typicode.com/users"
                        )!

                        let result = try? await URLSession.shared.data(from: url)

                        if let data = result?.0 {
                            users = (
                                try? JSONDecoder().decode(
                                    [User].self,
                                    from: data
                                )
                            ) ?? []
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                List(users) { user in
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)

                        Text(user.email)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Users")
        }
    }
}

#Preview {
    ContentView()
}
