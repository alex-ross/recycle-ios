import Foundation
import SwiftyJSON
import Alamofire
import CoreLocation

class APIClient: NSObject {
    static let sharedInstance = APIClient()
    private var manager: Manager?
    let endpoint = "https://protected-scrubland-88729.herokuapp.com"
    var recycleLocations: RecycleLocations!

    override init() {
        super.init()
        recycleLocations = RecycleLocations(client: self)
    }

    private func apiManager() -> Manager {
        if let m = self.manager {
            return m
        } else {
            let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
            configuration.HTTPAdditionalHeaders = [
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]

            let tempManager = Alamofire.Manager(configuration: configuration)
            self.manager = tempManager
            return self.manager!
        }
    }

    class RecycleLocations {
        let client: APIClient
        init(client: APIClient) {
            self.client = client
        }

        func index(coordinate: CLLocationCoordinate2D, success: [RecycleLocation] -> ()) {
            let parameters = [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude
            ]
            client.apiManager()
                .request(.GET, "\(client.endpoint)/recycle_locations", parameters: parameters)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        let json = JSON(data: response.data!)
                        let locations = RecycleLocationDeserializer.deserialize(jsonList: json["recycle_locations"].arrayValue)
                        success(locations)
                    case .Failure:
                        break
                    }
                }
        }
    }
}
