import Foundation

public struct Scope {
    let name: String
    let access: [String]
}

public extension Scope {
    var scopeDescription: String {
        access.map { "\(name):\($0)" }.joined(separator: ",")
    }
}

public extension Array where Element == Scope {
    var scopeDescription: String { map { $0.scopeDescription }.joined(separator: ",") }
}
public extension Scope {

    enum ReadAccess: String {
        case read
    }

    enum ReadWriteAccess: String {
        case read, write
    }

    enum AuthorizationAccess: String {
        case grant, read, revoke
    }

    enum CredentialsAccess: String {
        case read, write, refresh
    }

    enum TransactionAccess: String {
        case read, write, categorize
    }

    enum TransferAccess: String {
        case read, execute
    }

    enum UserAccess: String {
        case create, delete, read, webHooks = "web_hooks", write
    }

    static func accounts(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "accounts", access: access.map { $0.rawValue })
    }

    static func activities(_ access: ReadAccess...) -> Scope {
        return Scope(name: "activities", access: access.map { $0.rawValue })
    }

    static func authorization(_ access: AuthorizationAccess...) -> Scope {
        return Scope(name: "authorization", access: access.map { $0.rawValue })
    }

    static func budgets(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "budgets", access: access.map { $0.rawValue })
    }

    static func calendar(_ access: ReadAccess...) -> Scope {
        return Scope(name: "calendar", access: access.map { $0.rawValue })
    }

    static func categories(_ access: ReadAccess...) -> Scope {
        return Scope(name: "categories", access: access.map { $0.rawValue })
    }

    static func contacts(_ access: ReadAccess...) -> Scope {
        return Scope(name: "contacts", access: access.map { $0.rawValue })
    }

    static func credentials(_ access: CredentialsAccess...) -> Scope {
        return Scope(name: "credentials", access: access.map { $0.rawValue })
    }

    static func dataExports(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "data-exports", access: access.map { $0.rawValue })
    }

    static func documents(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "documents", access: access.map { $0.rawValue })
    }

    static func follow(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "follow", access: access.map { $0.rawValue })
    }

    static func identity(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "identity", access: access.map { $0.rawValue })
    }

    static func insights(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "insights", access: access.map { $0.rawValue })
    }

    static func investments(_ access: ReadAccess...) -> Scope {
        return Scope(name: "investments", access: access.map { $0.rawValue })
    }

    static func properties(_ access: ReadWriteAccess...) -> Scope {
        return Scope(name: "properties", access: access.map { $0.rawValue })
    }

    static func providers(_ access: ReadAccess...) -> Scope {
        return Scope(name: "providers", access: access.map { $0.rawValue })
    }

    static func statistics(_ access: ReadAccess...) -> Scope {
        return Scope(name: "statistics", access: access.map { $0.rawValue })
    }

    static func suggestions(_ access: ReadAccess...) -> Scope {
        return Scope(name: "suggestions", access: access.map { $0.rawValue })
    }

    static func transactions(_ access: TransactionAccess...) -> Scope {
        return Scope(name: "transactions", access: access.map { $0.rawValue })
    }

    static func transfer(_ access: TransferAccess...) -> Scope {
        return Scope(name: "transfer", access: access.map { $0.rawValue })
    }

    static func user(_ access: UserAccess...) -> Scope {
        return Scope(name: "user", access: access.map { $0.rawValue })
    }
}
