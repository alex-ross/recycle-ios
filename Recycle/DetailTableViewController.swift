import UIKit
import MapKit
import CoreLocation

class DetailTableViewController: UITableViewController {
    // MARK: Cell outlets
    @IBOutlet weak var materialsCell: MaterialsTableViewCell!
    @IBOutlet weak var openingHoursCell: OpeningHoursTableViewCell!
    @IBOutlet weak var addressCell: AddressTableViewCell!
    @IBOutlet weak var mapCell: MapTableViewCell!

    // MARK: Kind outlets
    @IBOutlet weak var kindLabel: UILabel!

    // MARK: Materials outlets
    @IBOutlet weak var materialGlass: UIView!
    @IBOutlet weak var materialCardboard: UIView!
    @IBOutlet weak var materialPlastic: UIView!
    @IBOutlet weak var materialMagazines: UIView!
    @IBOutlet weak var materialMetal: UIView!

    // MARK: Address outlets
    @IBOutlet weak var street: UILabel!
    @IBOutlet weak var zipCode: UILabel!
    @IBOutlet weak var city: UILabel!
    @IBOutlet weak var travelTime: UILabel!

    // MARK: Opening hours outlets
    @IBOutlet weak var openingHoursMonday: UILabel!
    @IBOutlet weak var openingHoursTuesday: UILabel!
    @IBOutlet weak var openingHoursWednesday: UILabel!
    @IBOutlet weak var openingHoursThursday: UILabel!
    @IBOutlet weak var openingHoursFriday: UILabel!
    @IBOutlet weak var openingHoursSaturday: UILabel!
    @IBOutlet weak var openingHoursSunday: UILabel!

    var recycleLocation: RecycleLocation!
    var deviceLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        kindLabel.text = recycleLocation.localizedKind

        materialGlass.hidden = !hasMaterial("glass")
        materialCardboard.hidden = !hasMaterial("cardboard")
        materialPlastic.hidden = !hasMaterial("plastic")
        materialMagazines.hidden = !hasMaterial("magazines")
        materialMetal.hidden = !hasMaterial("metal")

        street.text = recycleLocation.address.street
        zipCode.text = recycleLocation.address.zipCode
        city.text = recycleLocation.address.city

        calculateTravelTime()
    }

    func hasMaterial(material: String) -> Bool {
        return recycleLocation.materials.contains(material)
    }

    func calculateTravelTime() {
        guard let location = deviceLocation else { return }

        let source = MKMapItem( placemark: MKPlacemark(
            coordinate: location,
            addressDictionary: nil))
        let destination = MKMapItem(placemark: MKPlacemark(
            coordinate: recycleLocation.coordinates,
            addressDictionary: nil))

        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = source
        directionsRequest.destination = destination
        directionsRequest.transportType = .Automobile

        let directions = MKDirections(request: directionsRequest)

        directions.calculateDirectionsWithCompletionHandler { (response, error) in
            print(error)

            if let time = response?.routes.first?.expectedTravelTime {
                self.setupTravelTime(time)
            }
        }
    }

    func setupTravelTime(expectedTravelTime: NSTimeInterval) {
        let interval = Int(expectedTravelTime)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours > 0 {
            travelTime.text = "\(hours)h \(minutes)m"
        } else {
            travelTime.text = "\(minutes)m"
        }
    }

}
