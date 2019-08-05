import Foundation
import CoreLocation

class APIClient: NSObject {
    static let sharedInstance = APIClient()
    let endpoint = "https://protected-scrubland-88729.herokuapp.com"
    var recycleLocations: RecycleLocations!

    override init() {
        super.init()
        recycleLocations = RecycleLocations(client: self)
    }

    class RecycleLocations {
        let client: APIClient
        init(client: APIClient) {
            self.client = client
        }

        func index(_ coordinate: CLLocationCoordinate2D, success: @escaping ([RecycleLocation]) -> ()) {
            var urlComponents = URLComponents(string: "\(client.endpoint)/recycle_locations")!
            
            urlComponents.queryItems = [
                URLQueryItem(name: "latitude", value: String(describing: coordinate.latitude)),
                URLQueryItem(name: "longitude", value: String(describing: coordinate.longitude))
            ]
            
            var request = URLRequest(url: urlComponents.url!)
            let session = URLSession.shared
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTask(with: request) { (data, urlResponse, error) in
                guard let data = data,
                    let response = urlResponse as? HTTPURLResponse,
                    (200..<300) ~= response.statusCode,
                    error == nil else {
                        return
                }

                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let recycleLocationsResponse = try! decoder.decode(RecycleLocationsResponse.self, from: data)

                success(recycleLocationsResponse.recycleLocations)
            }
            
            task.resume()
        }
    }
}

struct RecycleLocationsResponse: Decodable {
    let recycleLocations: [RecycleLocation]
}
