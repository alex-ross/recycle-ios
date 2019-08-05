import Foundation

struct OpeningHour: Equatable {
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

    init(openAt: String?, closeAt: String?, isUnknown: Bool) {
        self.openAt = openAt
        self.closeAt = closeAt
        self.isUnknown = isUnknown
    }

    init(fromArray array: [String]?) {
        if let array = array {
            openAt = array.first
            closeAt = array.last
            isUnknown = false
        } else {
            openAt = nil
            closeAt = nil
            isUnknown = true
        }
    }
}
