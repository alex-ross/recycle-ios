import Foundation
import CoreLocation

class RecycleLocationDeserializer: NSObject {
    static func deserialize(jsonList list: [JSON]) -> [RecycleLocation] {
        var recycleLocations = [RecycleLocation]()
        for json in list {
            recycleLocations.append(deserialize(json: json))
        }
        return recycleLocations
    }

    static func deserialize(json aJson: JSON) -> RecycleLocation {
        return RecycleLocation(
            id: aJson["id"].intValue,
            name: aJson["name"].stringValue,
            kind: aJson["kind"].stringValue,
            materials: parseMaterials(aJson),
            coordinates: parseCoordinates(aJson),
            address: parseAddress(aJson),
            openingHours: parseOpeningHours(aJson)
        )
    }

    fileprivate static func parseCoordinates(_ json: JSON) -> CLLocationCoordinate2D {
        let longitude = json["longitude"].doubleValue
        let latitude = json["latitude"].doubleValue
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    fileprivate static func parseAddress(_ json: JSON) -> Address {
        return Address(
            street: json["street_name"].string,
            zipCode: json["zip_code"].string,
            city: json["city"].string
        )
    }

    fileprivate static func parseMaterials(_ json: JSON) -> [String] {
        return json["materials"].arrayValue.map { $0.stringValue }
    }

    fileprivate static func parseOpeningHours(_ json: JSON) -> [OpeningHour] {
        return json["opening_hours"].arrayValue.map { openingHour in
            if let array = openingHour.arrayObject {
                return OpeningHour(openAt: array.first as? String, closeAt: array.last as? String, isUnknown: false)
            } else {
                return OpeningHour(openAt: nil, closeAt: nil, isUnknown: true)
            }
        }
    }
}
