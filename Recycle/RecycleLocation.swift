import CoreLocation

struct RecycleLocation: Decodable {
    let id: Int
    let name: String
    let kind: RecycleLocationKind
    let materials: [String]
    let coordinates: CLLocationCoordinate2D
    let address: Address

    let openingHours: [OpeningHour]

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case kind
        case materials
        case openingHours
    }

    init(id: Int, name: String, kind: RecycleLocationKind, materials: [String], coordinates: CLLocationCoordinate2D, address: Address, openingHours: [OpeningHour]) {
        self.id = id
        self.name = name
        self.kind = kind
        self.materials = materials
        self.coordinates = coordinates
        self.address = address
        self.openingHours = openingHours
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(Int.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        kind = try values.decode(RecycleLocationKind.self, forKey: .kind)
        materials = try values.decode([String].self, forKey: .materials)

        coordinates = try CLLocationCoordinate2D(from: decoder)
        address = try Address(from: decoder)

        openingHours = try values
            .decode([[String]?].self, forKey: .openingHours)
            .map(OpeningHour.init(fromArray:))
    }
}
