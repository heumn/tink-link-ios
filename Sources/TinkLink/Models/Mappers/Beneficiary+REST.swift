import Foundation

extension Beneficiary {
    init(restBeneficiary beneficiary: RESTBeneficiary) {
        self.accountNumberType = beneficiary.accountNumberType
        self.ownerAccountID = Account.ID(beneficiary.ownerAccountId)
        self.accountNumber = beneficiary.accountNumber
        self.name = beneficiary.name
    }
}
