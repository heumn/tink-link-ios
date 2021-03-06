import SwiftUI
import TinkLink

struct CredentialsDetailView: View {
    @EnvironmentObject var credentialsController: CredentialsController

    let credentials: Credentials
    let provider: Provider?

    @State private var isRefreshing = false
    @State private var isAuthenticating = false
    @State private var isUpdating = false
    @State private var isDeleting = false

    private var updatedCredentials: Credentials {
        credentialsController.credentials.first(where: { $0.id == credentials.id }) ?? credentials
    }

    private var canAuthenticate: Bool {
        provider?.accessType == .openBanking
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()

    var body: some View {
        Form {
            Section(footer: Text(updatedCredentials.statusPayload)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(describing: updatedCredentials.status).localizedCapitalized)
                    updatedCredentials.statusUpdated.map {
                        Text("\($0, formatter: dateFormatter)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Button(action: refresh) {
                Text("Refresh")
            }
            .disabled(isRefreshing)
            Button(action: update) {
                Text(verbatim: "Update")
            }
            if canAuthenticate {
                Button(action: authenticate) {
                    Text(verbatim: "Authenticate")
                }
                .disabled(isAuthenticating)
            }
            Section {
                Button(action: delete) {
                    Text("Delete")
                }
                .disabled(isDeleting)
                .foregroundColor(.red)
            }
        }
        .navigationBarTitle(Text(provider?.displayName ?? "Credentials"), displayMode: .inline)
        .sheet(item: .init(get: { self.credentialsController.supplementInformationTask }, set: { self.credentialsController.supplementInformationTask = $0 })) { task in
            SupplementalInformationForm(supplementInformationTask: task) { result in
                self.credentialsController.supplementInformationTask = nil
            }
        }
        .sheet(isPresented: $isUpdating) {
            UpdateCredentialsFlowView(provider: self.provider!, credentials: self.credentials, credentialsController: self.credentialsController) { result in
                self.isUpdating = false
                self.credentialsController.performFetch()
            }
        }
    }

    private func refresh() {
        isRefreshing = true
        credentialsController.performRefresh(credentials: credentials) { result in
            self.isRefreshing = false
        }
    }

    private func update() {
        isUpdating = true
    }

    private func authenticate() {
        isAuthenticating = true
        credentialsController.performAuthentication(credentials: credentials) { result in
            self.isAuthenticating = false
        }
    }

    private func delete() {
        isDeleting = true
        credentialsController.deleteCredentials(credentials: [credentials])
    }
}
