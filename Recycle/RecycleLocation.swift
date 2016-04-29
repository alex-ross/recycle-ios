import CoreLocation

struct RecycleLocation {
    let id: Int
    let name: String
    let kind: String
    let materials: [String]
    let coordinates: CLLocationCoordinate2D
    let address: Address

    let openingHours: [OpeningHour]

    var localizedKind: String {
        switch kind {
        case "recycle_station":
            return "Återvinningstation"
        case "recycle_center":
            return "Återvinningcentral"
        default:
            return "Okänd typ"
        }
    }
}