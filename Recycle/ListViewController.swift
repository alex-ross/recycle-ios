import UIKit
import MapKit
import CoreLocation

class ListViewController: UIViewController {
    private var startLocation: CLLocation?
    var locationManager: CLLocationManager?
    var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setupMap()
        }
    }

    private func setupMap() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self


        let frame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: 160.0)
        mapView = MKMapView(frame: frame)



        if CLLocationManager.authorizationStatus() == .AuthorizedAlways ||
            CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            setupMapRegion()
        } else {
            locationManager?.requestAlwaysAuthorization()
        }

        tableView.tableHeaderView = mapView
    }

    private func setupMapRegion() {
        locationManager?.requestLocation()
        mapView.showsUserLocation = true
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")!
        return cell
    }
}

extension ListViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        debugPrint(error)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard startLocation == nil else { return }
        guard let location = locations.first else { return }

        startLocation = location

        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedWhenInUse, .AuthorizedAlways:
            setupMapRegion()
        default:
            break
        }
    }
}
