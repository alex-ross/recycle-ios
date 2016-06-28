import UIKit
import MapKit
import CoreLocation
import MBProgressHUD

class ListViewController: UIViewController {
    var locationManager = CLLocationManager()
    var refreshControl = UIRefreshControl()
    var progressHUD: MBProgressHUD?
    private var progressHUDUsed = false

    var annotations = [RecycleLocationPointAnnotation]()
    var mapView: MKMapView! {
        didSet {
            mapView.delegate = self
        }
    }
    var recycleLocations = [RecycleLocation]() {
        didSet {
            filterRecycleLocations()
        }
    }
    var filteredRecycleLocations = [RecycleLocation]()
    var materials = [Material]()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var glassButton: UIButton!
    @IBOutlet weak var cardboardButton: UIButton!
    @IBOutlet weak var plasticButton: UIButton!
    @IBOutlet weak var magazinesButton: UIButton!
    @IBOutlet weak var metalButton: UIButton!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        setupMap()
        setupNavigationController()
        setupRefreshControl()
    }

    private func setupNavigationController() {
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red:0.89, green:0.14, blue:0.07, alpha:1.00)
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.translucent = false
    }

    private func setupMap() {
        locationManager.delegate = self

        let frame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: 160.0)
        mapView = MKMapView(frame: frame)

        if !progressHUDUsed {
            progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
            progressHUD?.labelText = "1/2 Hämtar position"
            progressHUDUsed = true
        }

        if CLLocationManager.authorizationStatus() == .AuthorizedAlways ||
            CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            setupMapRegion()
        } else {
            locationManager.requestAlwaysAuthorization()
        }

        tableView.tableHeaderView = mapView
    }

    private func setupMapRegion() {
        locationManager.requestLocation()
        mapView.showsUserLocation = true
    }

    private var _fetchDataFromAPICalled = false
    func fetchDataFromAPI(coordinate: CLLocationCoordinate2D) {
        guard !_fetchDataFromAPICalled else { return }
        _fetchDataFromAPICalled = true

        NSLog("Will fetch fetch recycle locations for coordinate \(coordinate)")

        progressHUD?.labelText = "2/2 Hämtar sorteringsplatser"

        APIClient.sharedInstance.recycleLocations.index(coordinate) { recycleLocations in
            NSLog("Got \(recycleLocations.count) recycle locations for coordinate \(coordinate)")

            // End refresh control if it is running
            self.refreshControl.endRefreshing()
            self.progressHUD?.hide(true)

            self.recycleLocations = recycleLocations
            self.addMapAnnotations()
            self.tableView.reloadData()
        }
    }

    // MARK: - Annotations

    private func addMapAnnotations() {
        annotations = filteredRecycleLocations.map({ recycleLocation in
            RecycleLocationPointAnnotation(recycleLocation: recycleLocation, controller: self)
        })
        mapView.addAnnotations(annotations)
    }

    private func resetAnnotations() {
        let oldAnnotations = annotations
        addMapAnnotations()
        mapView.removeAnnotations(oldAnnotations)
    }

    // MARK: - Filtering

    @IBAction func filterToggle(sender: UIButton) {
        switch sender {
        case glassButton:
            let active = toggleMaterial(.Glass)
            let image = buttonImage("Glas", active: active)
            sender.setImage(image, forState: .Normal)
        case cardboardButton:
            let active = toggleMaterial(.Cardboard)
            let image = buttonImage("Carboard", active: active)
            sender.setImage(image, forState: .Normal)
        case plasticButton:
            let active = toggleMaterial(.Plastic)
            let image = buttonImage("Plastic", active: active)
            sender.setImage(image, forState: .Normal)
        case magazinesButton:
            let active = toggleMaterial(.Magazines)
            let image = buttonImage("Papers", active: active)
            sender.setImage(image, forState: .Normal)
        case metalButton:
            let active = toggleMaterial(.Metal)
            let image = buttonImage("Metal", active: active)
            sender.setImage(image, forState: .Normal)
        default:
            break
        }

        filterRecycleLocations()
    }

    func toggleMaterial(material: Material) -> Bool {
        if let index = materials.indexOf(material) {
            materials.removeAtIndex(index)
            return false
        } else {
            materials.append(material)
            return true
        }
    }

    func filterRecycleLocations() {
        let materials = self.materials.map { $0.rawValue }
        filteredRecycleLocations = recycleLocations.filter { location in
            return materials.isEmpty || materials.filter({ material in
                return location.materials.contains(material)
            }).count == materials.count
        }
        resetAnnotations()
        tableView.reloadData()
    }

    /// - Returns: `UIImage` view for filter toggle buttons
    func buttonImage(baseName: String, active: Bool) -> UIImage? {
        let name = active ? "\(baseName)Icon" : "\(baseName)InactiveIcon"
        return UIImage(named: name)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailFromCell" {
            let toView = segue.destinationViewController as! DetailTableViewController
            let cell = sender as! RecycleLocationTableViewCell
            toView.recycleLocation = cell.recycleLocation
        } else if segue.identifier == "detailFromAnnotation" {
            let toView = segue.destinationViewController as! DetailTableViewController
            let annotation = sender as! RecycleLocationPointAnnotation
            toView.recycleLocation = annotation.recycleLocation
        }
    }

    // MARK: - Refresh control

    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), forControlEvents: .ValueChanged)
        self.tableView.insertSubview(refreshControl, atIndex: 0)
    }

    func refreshData() {
        NSLog("Refresh controll was called")
        _fetchDataFromAPICalled = false
        locationManager.requestLocation()
    }

}

extension ListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecycleLocations.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! RecycleLocationTableViewCell
        cell.recycleLocation = filteredRecycleLocations[indexPath.row]
        return cell
    }
}

extension ListViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("LocationManager did fail with error: \(error)")
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        NSLog("LocationManager did update with location: \(location)")

        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)

        fetchDataFromAPI(location.coordinate)
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

extension ListViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.isMemberOfClass(RecycleLocationPointAnnotation) else { return nil }

        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "loc")

        let infoButton = UIButton(type: .DetailDisclosure)
        infoButton.addTarget(annotation,
                             action: #selector(RecycleLocationPointAnnotation.visit),
                             forControlEvents: .TouchUpInside)

        view.rightCalloutAccessoryView = infoButton
        view.canShowCallout = true

        return view
    }
}
