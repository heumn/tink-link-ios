import Foundation
/// An object that you use to access the user's transfer and beneficiary account and initiate transfer.
public final class TransferContext {
    private let tink: Tink
    private let transferService: TransferService
    private let credentialsService: CredentialsService

    // MARK: - Creating a Context

    /// Creates a context to access the user's transfer and beneficiary account and initiate transfer.
    ///
    /// - Parameter tink: Tink instance, will use the shared instance if nothing is provided.
    public convenience init(tink: Tink = .shared) {
        let transferService = RESTTransferService(client: tink.client)
        let credentialsService = RESTCredentialsService(client: tink.client)
        self.init(tink: tink, transferService: transferService, credentialsService: credentialsService)
    }

    init(tink: Tink, transferService: TransferService, credentialsService: CredentialsService) {
        self.tink = tink
        self.transferService = transferService
        self.credentialsService = credentialsService
    }

    public func initiateTransfer(
        amount: CurrencyDenominatedAmount,
        source: Account,
        destination: Beneficiary,
        sourceMessage: String? = nil,
        destinationMessage: String,
        progressHandler: @escaping (InitiateTransferTask.Status) -> Void = { _ in },
        authenticationHandler: @escaping (InitiateTransferTask.Authentication) -> Void,
        completion: @escaping (Result<InitiateTransferTask.Receipt, Error>) -> Void
    ) -> InitiateTransferTask? {
        guard let sourceURI = source.transferSourceIdentifiers?.first else {
            preconditionFailure("Source account doesn't have a URI.")
        }
        guard let destinationURI = destination.uri else {
            preconditionFailure("Transfer destination doesn't have a URI.")
        }

        let task = InitiateTransferTask(transferService: transferService, credentialsService: credentialsService, appUri: tink.configuration.redirectURI, progressHandler: progressHandler, authenticationHandler: authenticationHandler, completionHandler: completion)

        let transfer = Transfer(
            amount: amount.value,
            id: nil,
            credentialsID: source.credentialsID,
            currency: amount.currencyCode,
            sourceMessage: sourceMessage,
            destinationMessage: destinationMessage,
            dueDate: nil,
            destinationUri: destinationURI,
            sourceUri: sourceURI
        )

        task.canceller = transferService.transfer(transfer: transfer) { [weak task] result in
            do {
                let signableOperation = try result.get()
                task?.startObserving(signableOperation)
            } catch {
                completion(.failure(error))
            }
        }
        return task
    }

    public func fetchAccounts(completion: @escaping (Result<[Account], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: [], completion: completion)
    }

    public func fetchBeneficiaries(for account: Account, completion: @escaping (Result<[Beneficiary], Error>) -> Void) -> RetryCancellable? {
        return transferService.accounts(destinationUris: []) { result in
            do {
                let accounts = try result.get()
                let transferDestinations = accounts.first { $0.id == account.id }?.transferDestinations ?? []
                let filteredTransferDestinations = transferDestinations.filter { !($0.isMatchingMultipleDestinations ?? false) }
                let beneficiaries = filteredTransferDestinations.map { Beneficiary(account: account, transferDestination: $0) }
                completion(.success(beneficiaries))
            } catch {
                completion(.failure(error))
            }
        }
    }

    public func fetchAllBeneficiaries(completion: @escaping (Result<[Account.ID: [Beneficiary]], Error>) -> Void) -> RetryCancellable? {
        transferService.accounts(destinationUris: []) { result in
            do {
                let accounts = try result.get()
                let mappedTransferDestinations = accounts.reduce(into: [Account.ID: [Beneficiary]]()) { result, account in
                    let destinations = account.transferDestinations ?? []
                    let filteredTransferDestinations = destinations.filter { !($0.isMatchingMultipleDestinations ?? false) }
                    let beneficiaries = filteredTransferDestinations.map { Beneficiary(account: account, transferDestination: $0) }
                    result[account.id] = beneficiaries
                }
                completion(.success(mappedTransferDestinations))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
