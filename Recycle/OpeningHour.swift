import Foundation

struct OpeningHour {
    let openAt: String?
    let closeAt: String?
    let isUnknown: Bool

    var isClosed: Bool {
        return !isUnknown && openAt == nil && closeAt == nil
    }

    var openingText: String {
        if isUnknown {
            return ""
        } else if isClosed {
            return "Stängt"
        } else {
            return "\(openAt ?? "") - \(closeAt ?? "")"
        }
    }
}
