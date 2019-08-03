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
    @IBOutlet weak var openingHoursMonday:    UILabel!
    @IBOutlet weak var openingHoursTuesday:   UILabel!
    @IBOutlet weak var openingHoursWednesday: UILabel!
    @IBOutlet weak var openingHoursThursday:  UILabel!
    @IBOutlet weak var openingHoursFriday:    UILabel!
    @IBOutlet weak var openingHoursSaturday:  UILabel!
    @IBOutlet weak var openingHoursSunday:    UILabel!

    var recycleLocation: RecycleLocation!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = recycleLocation.name

        kindLabel.text = recycleLocation.localizedKind

        materialGlass.isHidden = !hasMaterial("glass")
        materialCardboard.isHidden = !hasMaterial("cardboard")
        materialPlastic.isHidden = !hasMaterial("plastic")
        materialMagazines.isHidden = !hasMaterial("magazines")
        materialMetal.isHidden = !hasMaterial("metal")

        street.text = recycleLocation.address.street
        zipCode.text = recycleLocation.address.zipCode
        city.text = recycleLocation.address.city

        addressCell.coordinates = recycleLocation.coordinates
        addressCell.addressName = recycleLocation.name

        openingHoursMonday.text = opening(0)
        openingHoursTuesday.text = opening(1)
        openingHoursWednesday.text = opening(2)
        openingHoursThursday.text = opening(3)
        openingHoursFriday.text = opening(4)
        openingHoursSaturday.text = opening(5)
        openingHoursSunday.text = opening(6)

        calculateTravelTime()
        setupMapRegion()
    }

    func opening(_ day: Int) -> String {
        if day < recycleLocation.openingHours.count {
            return recycleLocation.openingHours[day].openingText
        } else {
            return ""
        }
    }

    func hasMaterial(_ material: String) -> Bool {
        return recycleLocation.materials.contains(material)
    }

    func calculateTravelTime() {
        let destination = MKMapItem(placemark: MKPlacemark(
            coordinate: recycleLocation.coordinates,
            addressDictionary: nil))

        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem.forCurrentLocation()
        directionsRequest.destination = destination
        directionsRequest.transportType = .automobile

        let directions = MKDirections(request: directionsRequest)

        directions.calculate { response, error in
            if let error = error {
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

    func setupTravelTime(_ expectedTravelTime: TimeInterval) {
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
