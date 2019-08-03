import UIKit
import MapKit
import CoreLocation

class AddressTableViewCell: UITableViewCell {
    var coordinates: CLLocationCoordinate2D!
    var addressName: String?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = addressName
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }

}
