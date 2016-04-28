import UIKit
import MapKit
import CoreLocation

class ListViewController: UIViewController {
    private var startLocation: CLLocation?
    var locationManager: CLLocationManager?
    var mapView: MKMapView!
    var recycleLocations = [RecycleLocation]()
    var deviceLocation: CLLocationCoordinate2D?
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setupMap()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red:0.89, green:0.14, blue:0.07, alpha:1.00)
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.translucent = false


        APIClient.sharedInstance.recycleLocations.index { recycleLocations in
            self.recycleLocations = recycleLocations
            self.addMapAnnotations()
            self.tableView.reloadData()
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

    private func addMapAnnotations() {
        let annotations = recycleLocations.map({ recycleLocation in
            RecycleLocationPointAnnotation(recycleLocation: recycleLocation, controller: self)
        })
        mapView.addAnnotations(annotations)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailFromCell" {
            let toView = segue.destinationViewController as! DetailTableViewController
            let cell = sender as! RecycleLocationTableViewCell
            toView.recycleLocation = cell.recycleLocation
            toView.deviceLocation = deviceLocation
        }
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recycleLocations.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! RecycleLocationTableViewCell
        cell.recycleLocation = recycleLocations[indexPath.row]
        return cell
    }
}

extension ListViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        debugPrint(error)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        deviceLocation = location.coordinate

        guard startLocation == nil else { return }


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
