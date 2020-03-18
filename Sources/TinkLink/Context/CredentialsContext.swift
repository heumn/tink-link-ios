import Foundation

/// An object that you use to access the user's credentials and supports the flow for adding credentials.
public final class CredentialsContext {
    private let tink: Tink
    private let service: CredentialsService
    private var credentialThirdPartyCallbackObserver: Any?
    private var thirdPartyCallbackCanceller: RetryCancellable?

    // MARK: - Creating a Credentials Context

    /// Creates a new CredentialsContext for the given Tink instance.
    ///
    /// - Parameter tink: Tink instance, defaults to `shared` if not provided.
    /// - Parameter user: `User` that will be used for adding credentials with the Tink API.
    public init(tink: Tink = .shared, user: User) {
        self.tink = tink
        self.service = CredentialsService(tink: tink, accessToken: user.accessToken)
        service.accessToken = user.accessToken
        addStoreObservers()
    }

    private func addStoreObservers() {
        credentialThirdPartyCallbackObserver = NotificationCenter.default.addObserver(forName: .credentialThirdPartyCallback, object: nil, queue: .main) { [weak self] notification in
            guard let self = self else { return }
            if let userInfo = notification.userInfo as? [String: String] {
                var parameters = userInfo
                let stateParameterName = "state"
                guard let state = parameters.removeValue(forKey: stateParameterName) else { return }
                self.thirdPartyCallbackCanceller = self.service.thirdPartyCallback(
                    state: state,
                    parameters: parameters,
                    completion: { _ in }
                )
            }
        }
    }

    private func removeObservers() {
        credentialThirdPartyCallbackObserver = nil
    }

    deinit {
        removeObservers()
    }

    // MARK: - Adding Credentials

    /// Adds a credentials for the user.
    ///
    /// You need to handle status changes in `progressHandler` to successfuly add a credentials for some providers.
    ///
    ///     credentialsContext.addCredentials(for: provider, form: form, progressHandler: { status in
    ///         switch status {
    ///         case .awaitingSupplementalInformation(let supplementInformationTask):
    ///             <#Present form for supplemental information task#>
    ///         case .awaitingThirdPartyAppAuthentication(let thirdPartyAppAuthentication):
    ///             <#Open third party app deep link URL#>
    ///         default:
    ///             break
    ///         }
    ///     }, completion: { result in
    ///         <#Handle result#>
    ///     }
    ///
    /// - Parameters:
    ///   - provider: The provider (financial institution) that the credentials is connected to.
    ///   - form: This is a form with fields from the Provider to which the credentials belongs to.
    ///   - completionPredicate: Predicate for when credentials task should complete.
    ///   - progressHandler: The block to execute with progress information about the credential's status.
    ///   - status: Indicates the state of a credentials being added.
    ///   - completion: The block to execute when the credentials has been added successfuly or if it failed.
    ///   - result: Represents either a successfully added credentials or an error if adding the credentials failed.
    /// - Returns: The add credentials task.
    @discardableResult
    public func addCredentials(for provider: Provider, form: Form,
                              completionPredicate: AddCredentialsTask.CompletionPredicate = .init(successPredicate: .updated, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: true),
                              progressHandler: @escaping (_ status: AddCredentialsTask.Status) -> Void,
                              completion: @escaping (_ result: Result<Credentials, Error>) -> Void) -> AddCredentialsTask {
        let task = AddCredentialsTask(
            credentialsService: service,
            completionPredicate: completionPredicate,
            progressHandler: progressHandler,
            completion: completion
        )

        let appURI = tink.configuration.redirectURI

        task.callCanceller = addCredentialAndAuthenticateIfNeeded(for: provider, fields: form.makeFields(), appURI: appURI) { [weak task] result in
            do {
                let credentials = try result.get()
                task?.startObserving(credentials)
            } catch {
                let mappedError = AddCredentialsTask.Error(addCredentialsError: error) ?? error
                completion(.failure(mappedError))
            }
        }
        return task
    }

    private func addCredentialAndAuthenticateIfNeeded(for provider: Provider, fields: [String: String], appURI: URL, completion: @escaping (Result<Credentials, Error>) -> Void) -> RetryCancellable? {
        return service.createCredential(providerID: provider.id, fields: fields, appURI: appURI, completion: completion)
    }

    // MARK: - Fetching Credentials

    /// Gets the user's credentials.
    /// - Parameter completion: The block to execute when the call is completed.
    /// - Parameter result: A result that either contain a list of the user credentials or an error if the fetch failed.
    @discardableResult
    public func fetchCredentials(completion: @escaping (_ result: Result<[Credentials], Error>) -> Void) -> RetryCancellable? {
        return service.credentials { result in
            do {
                let credentials = try result.get()
                let storedCredentials = credentials.sorted(by: { $0.id.value < $1.id.value })
                completion(.success(storedCredentials))
            } catch {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Managing Credentials

    /// Refresh the user's credentials.
    /// - Parameters:
    ///   - credentials: List fo credentials that needs to be refreshed.
    ///   - shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Determines how the task handles the case when a user doesn't have the required authentication app installed.
    ///   - progressHandler: The block to execute with progress information about the credential's status.
    ///   - status: Indicates the state of a credentials being refreshed.
    ///   - completion: The block to execute when the credentials has been refreshed successfuly or if it failed.
    ///   - result: A result that either a list of updated credentials when refresh successed or an error if failed.
    /// - Returns: The refresh credentials task.
    public func refresh(_ credentials: [Credentials],
                                   shouldFailOnThirdPartyAppAuthenticationDownloadRequired: Bool = true,
                                   progressHandler: @escaping (_ status: RefreshCredentialTask.Status) -> Void,
                                   completion: @escaping (_ result: Result<[Credentials], Swift.Error>) -> Void) -> RefreshCredentialTask {
        let task = RefreshCredentialTask(credentials: credentials, credentialService: service, shouldFailOnThirdPartyAppAuthenticationDownloadRequired: shouldFailOnThirdPartyAppAuthenticationDownloadRequired, progressHandler: progressHandler, completion: completion)

        task.callCanceller = service.refreshCredentials(credentialIDs: credentials.map { $0.id }, completion: { result in
            switch result {
            case .success:
                task.startObserving()
            case .failure(let error):
                completion(.failure(error))
            }
        })

        return task
    }

    /// Update the user's credential.
    /// - Parameters:
    ///   - credential: Credentials that needs to be updated.
    ///   - form: This is a form with fields from the Provider to which the credentials belongs to.
    ///   - completion: The block to execute when the credentials has been updated successfuly or if it failed.
    ///   - result: A result with either an updated credentials if the update succeeded or an error if failed.
    /// - Returns: The update credentials task.
    @discardableResult
    public func update(_ credential: Credentials, form: Form? = nil,
                       completion: @escaping (_ result: Result<Credentials, Swift.Error>) -> Void) -> RetryCancellable? {
        service.updateCredential(credentialID: credential.id, fields: form?.makeFields() ?? [:], completion: completion)
    }

    /// Delete the user's credential.
    /// - Parameters:
    ///   - credentials: Credentials that needs to be deleted.
    ///   - completion: The block to execute when the credentials has been deleted successfuly or if it failed.
    ///   - result: A result representing that the delete succeeded or an error if failed.
    /// - Returns: The delete credentials task.
    @discardableResult
    public func delete(_ credentials: Credentials,
                       completion: @escaping (_ result: Result<Void, Swift.Error>) -> Void) -> RetryCancellable? {
        return service.deleteCredential(credentialID: credentials.id, completion: completion)
    }
}

extension Notification.Name {
    static let credentialThirdPartyCallback = Notification.Name("TinkLinkCredentialThirdPartyCallbackNotificationName")
}