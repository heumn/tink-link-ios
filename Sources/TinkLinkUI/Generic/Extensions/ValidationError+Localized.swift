import Foundation
import TinkLink

extension Form.Field.ValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalid(_, let reason):
            return reason
        case .maxLengthLimit(let fieldName, let maxLength):
            return String(format: Strings.Credentials.Validation.maxLengthLimit, fieldName, maxLength)
        case .minLengthLimit(let fieldName, let minLength):
            return String(format: Strings.Credentials.Validation.minLengthLimit, fieldName, minLength)
        case .requiredFieldEmptyValue(let fieldName):
            return String(format: Strings.Credentials.Validation.requiredFieldEmptyValue, fieldName)
        }
    }
}
