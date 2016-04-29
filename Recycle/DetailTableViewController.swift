import UIKit
import MapKit

class DetailTableViewController: UITableViewController {
    // MARK: Cell outlets
    @IBOutlet weak var materialsCell: UITableViewCell!
    @IBOutlet weak var openingHoursCell: UITableViewCell!
    @IBOutlet weak var addressCell: AddressTableViewCell!
    @IBOutlet weak var mapCell: UITableViewCell!

    // MARK: Map view outlets
    @IBOutlet weak var mapView: MKMapView!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = recycleLocation.name

        kindLabel.text = recycleLocation.localizedKind

        materialGlass.hidden = !hasMaterial("glass")
        materialCardboard.hidden = !hasMaterial("cardboard")
        materialPlastic.hidden = !hasMaterial("plastic")
        materialMagazines.hidden = !hasMaterial("magazines")
        materialMetal.hidden = !hasMaterial("metal")

        street.text = recycleLocation.address.street
        zipCode.text = recycleLocation.address.zipCode
        city.text = recycleLocation.address.city

        addressCell.coordinates = recycleLocation.coordinates
        addressCell.addressName = recycleLocation.name

        calculateTravelTime()
        setupMapRegion()
    }

    func hasMaterial(material: String) -> Bool {
        return recycleLocation.materials.contains(material)
    }

    func calculateTravelTime() {
        let destination = MKMapItem(placemark: MKPlacemark(
            coordinate: recycleLocation.coordinates,
            addressDictionary: nil))

        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem.mapItemForCurrentLocation()
        directionsRequest.destination = destination
        directionsRequest.transportType = .Automobile

        let directions = MKDirections(request: directionsRequest)

        directions.calculateDirectionsWithCompletionHandler { response, error in
            if error != nil {
                print(error)
                return
            }

            if let time = response?.routes.first?.expectedTravelTime {
                self.setupTravelTime(time)
            }
        }
    }

    func setupMapRegion() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = recycleLocation.coordinates
        mapView.addAnnotation(annotation)

        let region = MKCoordinateRegionMakeWithDistance(recycleLocation.coordinates, 300, 300)
        mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }

    func setupTravelTime(expectedTravelTime: NSTimeInterval) {
        let interval = Int(expectedTravelTime)
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours > 0 {
            travelTime.text = "\(hours)h \(minutes)m"
        } else {
            travelTime.text = "\(minutes) min"
        }
    }

}
