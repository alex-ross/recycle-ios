import Foundation
import SwiftyJSON
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
            address: parseAddress(aJson)
        )
    }

    private static func parseCoordinates(json: JSON) -> CLLocationCoordinate2D {
        let longitude = json["longitude"].doubleValue
        let latitude = json["latitude"].doubleValue
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private static func parseAddress(json: JSON) -> Address {
        return Address(
            street: json["street_name"].string,
            zipCode: json["zip_code"].string,
            city: json["city"].string
        )
    }

    private static func parseMaterials(json: JSON) -> [String] {
        return json["materials"].arrayValue.map { $0.stringValue }
    }
}
