import Foundation
import TinkLink

extension AddCredentialsTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .permanentFailure:
            return Strings.Credentials.Error.permanentFailure
        case .temporaryFailure:
            return Strings.Credentials.Error.temporaryFailure
        case .authenticationFailed:
            return Strings.Credentials.Error.authenticationFailed
        case .credentialsAlreadyExists:
            return Strings.Generic.error
        case .cancelled:
            return Strings.Generic.cancelled
        }
    }

    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload):
            // TODO: Localize this somehow?
            return payload
        case .credentialsAlreadyExists:
            return Strings.Credentials.Error.credentialsAlreadyExists
        case .cancelled:
            return nil
        }
    }
}

extension RefreshCredentialsTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .permanentFailure:
            return Strings.Credentials.Error.permanentFailure
        case .temporaryFailure:
            return Strings.Credentials.Error.temporaryFailure
        case .authenticationFailed:
            return Strings.Credentials.Error.authenticationFailed
        case .deleted:
            return Strings.Generic.error
        case .cancelled:
            return Strings.Generic.cancelled
        }
    }

    public var failureReason: String? {
        switch self {
        case .permanentFailure(let payload), .temporaryFailure(let payload), .authenticationFailed(let payload), .deleted(let payload):
            // TODO: Localize this somehow?
            return payload ?? Strings.Generic.error
        case .cancelled:
            return nil
        }
    }
}

extension ThirdPartyAppAuthenticationTask.Error: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired(let title, _, _):
            return title
        case .doesNotSupportAuthenticatingOnAnotherDevice:
            return nil
        case .decodingQRCodeImageFailed:
            return nil
        case .cancelled:
            return nil
        }
    }

    public var failureReason: String? {
        switch self {
        case .deeplinkURLNotFound:
            return nil
        case .downloadRequired(_, let message, _):
            return message
        case .doesNotSupportAuthenticatingOnAnotherDevice:
            return nil
        case .decodingQRCodeImageFailed:
            return nil
        case .cancelled:
            return nil
        }
    }
}
