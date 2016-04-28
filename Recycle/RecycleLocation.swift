import CoreLocation

struct RecycleLocation {
    let id: Int
    let name: String
    let kind: String
    let materials: [String]
    let coordinates: CLLocationCoordinate2D
    let address: Address
}