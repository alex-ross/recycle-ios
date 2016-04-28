import CoreLocation

struct RecycleLocation {
    let id: Int
    let name: String
    let kind: String
    let materials: [String]
    let coordinates: CLLocationCoordinate2D
    let address: Address

    var localizedKind: String {
        switch kind {
        case "recycle_station":
            return "Återvinningstation"
        case "recycle_central":
            return "Återvinningcentral"
        default:
            return "Okänd typ"
        }
    }
}