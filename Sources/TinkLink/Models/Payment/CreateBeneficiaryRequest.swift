import Foundation

/// Initiates a request to add beneficiary to the given account belonging to the authenticated user.
struct CreateBeneficiaryRequest {
    /// The type of the `accountNumber` that this beneficiary has.
    var accountNumberKind: String
    /// The account number for the beneficiary. The structure of this field depends on the `accountNumberKind`.
    var accountNumber: String
    /// The name chosen by the user for this beneficiary.
    var name: String
    /// The identifier of the source account that this beneficiary should be added to.
    var ownerAccountID: Account.ID
    /// The ID of the `Credentials` used to add the beneficiary. Note that you can send in a different ID here than the credentials ID to which the account belongs. This functionality exists to support the case where you may have double credentials for one financial institution, due to PSD2 regulations.
    var credentialsID: Credentials.ID
}
