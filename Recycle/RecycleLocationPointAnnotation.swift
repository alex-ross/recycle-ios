import UIKit
import MapKit

class RecycleLocationPointAnnotation: MKPointAnnotation {
    let recycleLocation: RecycleLocation
    let controller: UIViewController

    init(recycleLocation: RecycleLocation, controller: UIViewController) {
        self.recycleLocation = recycleLocation
        self.controller = controller
        super.init()

        coordinate = recycleLocation.coordinates
        title = recycleLocation.name
        subtitle = recycleLocation.kind.localized
    }

    @objc func visit() {
        controller.performSegue(withIdentifier: "detailFromAnnotation", sender: self)
    }
}
