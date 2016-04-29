import UIKit
import MapKit
import CoreLocation

class ListViewController: UIViewController {
    var locationManager: CLLocationManager?
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

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            setupMap()
        }
    }

    @IBOutlet weak var glassButton: UIButton!
    @IBOutlet weak var cardboardButton: UIButton!
    @IBOutlet weak var plasticButton: UIButton!
    @IBOutlet weak var magazinesButton: UIButton!
    @IBOutlet weak var metalButton: UIButton!

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = UIColor(red:0.89, green:0.14, blue:0.07, alpha:1.00)
        navigationController?.navigationBar.barStyle = .Black
        navigationController?.navigationBar.shadowImage = nil
        navigationController?.navigationBar.translucent = false
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
        } else if segue.identifier == "detailFromAnnotation" {
            let toView = segue.destinationViewController as! DetailTableViewController
            let annotation = sender as! RecycleLocationPointAnnotation
            toView.recycleLocation = annotation.recycleLocation
        }
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

    func buttonImage(baseName: String, active: Bool) -> UIImage? {
        let name = active ? "\(baseName)Icon" : "\(baseName)InactiveIcon"
        return UIImage(named: name)
    }

    func filterRecycleLocations() {
        let materials = self.materials.map { $0.rawValue }
        filteredRecycleLocations = recycleLocations.filter { location in
            return materials.isEmpty || materials.filter({ material in
                return location.materials.contains(material)
            }).count == materials.count
        }

        tableView.reloadData()
    }

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

    private var _fetchDataFromAPICalled = false
    func fetchDataFromAPI(coordinate: CLLocationCoordinate2D) {
        guard !_fetchDataFromAPICalled else { return }
        _fetchDataFromAPICalled = true


        APIClient.sharedInstance.recycleLocations.index(coordinate) { recycleLocations in
            self.recycleLocations = recycleLocations
            self.addMapAnnotations()
            self.tableView.reloadData()
        }
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
        debugPrint(error)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

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
