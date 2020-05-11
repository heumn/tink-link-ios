import Foundation

public struct AccountDetails {

    public enum Kind {
        case mortgage
        case blanco
        case membership
        case vehicle
        case land
        case student
        case credit
        case other
        case unknown
    }
    /// Interest of the account. Applicable for loans and savings accounts.
    public let interest: Double?

    /// Populated if available. Describes how many months the interest rate is bound.
    public let numberOfMonthsBound: Int?

    /// Account subtype.
    public let kind: Kind

    /// A timestamp of the next day of terms change of the account. Applicable for loans.
    public let nextDayOfTermsChange: Date?
}

