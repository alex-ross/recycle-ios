struct Address: Decodable {
    let street: String?
    let zipCode: String?
    let city: String?

    enum CodingKeys: String, CodingKey {
        case street = "streetName"
        case zipCode = "zipCode"
        case city = "city"
    }

    public init(street: String?, zipCode: String?, city: String?) {
        self.street = street
        self.zipCode = zipCode
        self.city = city
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        street = try values.decode(String?.self, forKey: .street)
        zipCode = try values.decode(String?.self, forKey: .zipCode)
        city = try values.decode(String?.self, forKey: .city)
    }
}
