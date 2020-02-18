import UIKit

enum Icon {
    case bankID
    case password
    case profile

    private var base64Encoded: String {
        switch self {
        case .bankID:
            return "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"
        case .password:
            return "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"
        case .profile:
            return "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAAAAXNSR0IArs4c6QAAAGxlWElmTU0AKgAAAAgABAEaAAUAAAABAAAAPgEbAAUAAAABAAAARgEoAAMAAAABAAIAAIdpAAQAAAABAAAATgAAAAAAAADYAAAAAQAAANgAAAABAAKgAgAEAAAAAQAAADCgAwAEAAAAAQAAADAAAAAADzpsYgAAAAlwSFlzAAAhOAAAITgBRZYxYAAAABxpRE9UAAAAAgAAAAAAAAAYAAAAKAAAABgAAAAYAAACSMf19vwAAAIUSURBVGgFzJfPKwVRFMcvNkIKWYjekqWSxEphYcHWilJioSgbCxtvo2woS6X8GRILyspKNmRBskTyI4n8+H7rzZvpOKM7c++859S3d+fMuZ/vue+9uTNjjL+oBKoPWoUOoQvouSCOD6AVqAeqgP5NVKGTGegG+rbUFeomIS66rNEL9zPItnFZd4q5XeVawTiM3xyaDxbzCsZYqRcxa9n4NeqooNm/PqdLtYgBGH3ENPWA/DI0DDVDQXDMHM+xRlvIO/L9UKbRBPodpDWwi3yrhXsbalirMW6Rb7RgpC5ZjzGeT0jkNso52iLWErKsy3Oo1C7aTWvC70LOlYugB728xxKI0uwSuToHJ84lQ3Lp5T2OQZRGQx5cyJBcenkN7iJfUNToBce8C7sGGWRF2fSK7mKuHqZbGNDsyJkaAsiKLoBjenqLUZCkwYY3ujFkST49vcUESNJgwRvdGLIkn48q3oJ3UWmw5Y1uDFmS72ODKLbYqRicFM+6D8iSC+hwx4aEegzl8w+Pq8OS1CMyJPsTuZrUxJiJ+8jLb2kqpjZJmgzJ3UsCsK2dU4wekcvZApQ6ziVDLoCbhvdoAFF7FOa3leYdl3M4Vzb/hFwtlEksgioNebwN8TqxDdZyjsbiL51Z8II7hzRjvnkNWjizhrUag3fkzF/0ub1pfyU2xGeYHSgPjUAtBXGch3iONVrz98i3Q4niBwAA//9o34OxAAAB7UlEQVTNls0rBVEYh8dHkvK5IKWUjSXJ0k5K2SgLpdTdsREbW1YWIn+ElA0lJclCibKzwUoKSyLRZeHr+S3ube7bufe6Zu7MvPU05+M95/29Z87MOZ73PxtiWBp+QuKReXogUusj2j0ETeKTOQYiVe4L1kZ5A74hSCLPjF+ARojFeom6DUG3lRKZgwqIxeqIOgrLsA6HcAFPUMobOsK/ExJltajpghTswgcUSuqF/kFIrNWjLAU3kC+RV/r6IdFWg7pZeABXImrvhpJsAu8ViPJjaiLePriSuKW9A/5k2qfaf5poE7RCUVkVgVbBlcQl7S3FhFTjcGYmOKKu1YnSpgnmSuKU9spCQnSYuAaOFxpUpr58b2IqXzytcmbr+JPYyTegzO3aTq5vQh91syv2Io1+4SrLudXlHFGbFlUarC69nRxroOY6LcdyvOKp6BdrE5BWHYxZm6Fkna6yvfEW9Bd0HXaTflkHVGwC836HmMsph77jjCZdwN6Ng+7o7RmHBDx17bB3py/atPW9EbCrv6eOhJkugFbnsDSuOTruaNOBFgZME4qlmMUmsKSZtxwd1jFIXTHCMF1xrA59u96Jo8M6BqkrRhim36bVca6Jrx0d1jFIXTHCMntWaat7bxBEYLGxYYnXPLqR+uOlfwGguJV3//UbjwAAAABJRU5ErkJggg=="
        }
    }

    func makeImage() -> UIImage? {
        guard let data = Data(base64Encoded: base64Encoded),
            let image = UIImage(data: data)
            else { return nil }
        return image.withRenderingMode(.alwaysTemplate)
    }
}
