import UIKit
import MapKit
import CoreLocation
import MBProgressHUD

class ListViewController: UIViewController {
    var locationManager = CLLocationManager()
    var refreshControl = UIRefreshControl()
    var progressHUD: MBProgressHUD?
    fileprivate var progressHUDUsed = false

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupMap()
        setupNavigationController()
        setupRefreshControl()
    }

    fileprivate func setupNavigationController() {
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(red:0.89, green:0.14, blue:0.07, alpha:1.00)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.isTranslucent = false
    }

    fileprivate func setupMap() {
        locationManager.delegate = self

        let frame = CGRect(x: 0.0, y: 0.0, width: tableView.bounds.width, height: 160.0)
        mapView = MKMapView(frame: frame)

        if !progressHUDUsed {
            progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
            progressHUD?.label.text = "1/2 Hämtar position"
            progressHUDUsed = true
        }

        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            setupMapRegion()
        } else {
            locationManager.requestAlwaysAuthorization()
        }

        tableView.tableHeaderView = mapView
    }

    fileprivate func setupMapRegion() {
        locationManager.requestLocation()
        mapView.showsUserLocation = true
    }

    fileprivate var _fetchDataFromAPICalled = false
    func fetchDataFromAPI(_ coordinate: CLLocationCoordinate2D) {
        guard !_fetchDataFromAPICalled else { return }
        _fetchDataFromAPICalled = true

        NSLog("Will fetch fetch recycle locations for coordinate \(coordinate)")

        progressHUD?.label.text = "2/2 Hämtar sorteringsplatser"

        APIClient.sharedInstance.recycleLocations.index(coordinate) { recycleLocations in
            NSLog("Got \(recycleLocations.count) recycle locations for coordinate \(coordinate)")
            DispatchQueue.main.async {
                // End refresh control if it is running
                self.refreshControl.endRefreshing()
                self.progressHUD?.hide(animated: true)

                self.recycleLocations = recycleLocations
                self.addMapAnnotations()
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Annotations

    fileprivate func addMapAnnotations() {
        annotations = filteredRecycleLocations.map({ recycleLocation in
            RecycleLocationPointAnnotation(recycleLocation: recycleLocation, controller: self)
        })
        mapView.addAnnotations(annotations)
    }

    fileprivate func resetAnnotations() {
        let oldAnnotations = annotations
        addMapAnnotations()
        mapView.removeAnnotations(oldAnnotations)
    }

    // MARK: - Filtering

    @IBAction func filterToggle(_ sender: UIButton) {
        switch sender {
        case glassButton:
            let active = toggleMaterial(.Glass)
            let image = buttonImage("Glas", active: active)
            sender.setImage(image, for: UIControlState())
        case cardboardButton:
            let active = toggleMaterial(.Cardboard)
            let image = buttonImage("Carboard", active: active)
            sender.setImage(image, for: UIControlState())
        case plasticButton:
            let active = toggleMaterial(.Plastic)
            let image = buttonImage("Plastic", active: active)
            sender.setImage(image, for: UIControlState())
        case magazinesButton:
            let active = toggleMaterial(.Magazines)
            let image = buttonImage("Papers", active: active)
            sender.setImage(image, for: UIControlState())
        case metalButton:
            let active = toggleMaterial(.Metal)
            let image = buttonImage("Metal", active: active)
            sender.setImage(image, for: UIControlState())
        default:
            break
        }

        filterRecycleLocations()
    }

    func toggleMaterial(_ material: Material) -> Bool {
        if let index = materials.index(of: material) {
            materials.remove(at: index)
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
    func buttonImage(_ baseName: String, active: Bool) -> UIImage? {
        let name = active ? "\(baseName)Icon" : "\(baseName)InactiveIcon"
        return UIImage(named: name)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailFromCell" {
            let toView = segue.destination as! DetailTableViewController
            let cell = sender as! RecycleLocationTableViewCell
            toView.recycleLocation = cell.recycleLocation
        } else if segue.identifier == "detailFromAnnotation" {
            let toView = segue.destination as! DetailTableViewController
            let annotation = sender as! RecycleLocationPointAnnotation
            toView.recycleLocation = annotation.recycleLocation
        }
    }

    // MARK: - Refresh control

    fileprivate func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.tableView.insertSubview(refreshControl, at: 0)
    }

    func refreshData() {
        NSLog("Refresh controll was called")
        _fetchDataFromAPICalled = false
        locationManager.requestLocation()
    }

}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRecycleLocations.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecycleLocationTableViewCell
        cell.recycleLocation = filteredRecycleLocations[indexPath.row]
        return cell
    }
}

extension ListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("LocationManager did fail with error: \(error)")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        NSLog("LocationManager did update with location: \(location)")

        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)

        fetchDataFromAPI(location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            setupMapRegion()
        default:
            break
        }
    }
}

extension ListViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation.isMember(of: RecycleLocationPointAnnotation.self) else { return nil }

        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "loc")

        let infoButton = UIButton(type: .detailDisclosure)
        infoButton.addTarget(annotation,
                             action: #selector(RecycleLocationPointAnnotation.visit),
                             for: .touchUpInside)

        view.rightCalloutAccessoryView = infoButton
        view.canShowCallout = true

        return view
    }
}
