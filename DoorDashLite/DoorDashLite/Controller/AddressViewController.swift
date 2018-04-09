//
//  ViewController.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/6/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import UIKit
import MapKit


final class AddressViewController: UIViewController {
    
    // MARK: - IBOutlets

    @IBOutlet weak private var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
            mapView.delegate = self
        }
    }
    
    @IBOutlet weak private var location: UILabel!
    @IBOutlet weak private var confirmAddress: UIButton! {
        didSet {
            confirmAddress.isEnabled = false
        }
    }
    
    // MARK: - Private properties
    
    private let geoCoder = CLGeocoder()
    private var selectedLocation: Location? {
        didSet {
            if let location = selectedLocation {
                self.updateAnnotation(with: location)
                self.confirmAddress.isEnabled = true
            } else {
                self.confirmAddress.isEnabled = false
            }
        }
    }
    
    private lazy var locationManager: CLLocationManager = {
        let locManager = CLLocationManager()
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        return locManager
    }()
    
    private var annotation = MKPointAnnotation() {
        didSet {
            // Set map's zoom level
            let region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 5000, 5000)
            mapView.setRegion(region, animated: false)
            
            // Add annotation to map view
            mapView.addAnnotation(annotation)

            // Update location text
            if let street = self.annotation.title,
                let city = self.annotation.subtitle,
                !street.isEmpty,
                !city.isEmpty
            {
                self.location.text = street + ", " + city
            }
        }
    }
    
    private lazy var offlineAlertController: UIAlertController = {
        let offlineController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Internet connection appears to be offline", comment:""), preferredStyle: .alert)
        let doneAction = UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .default, handler: nil)
        offlineController.addAction(doneAction)
        return offlineController
    }()
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NetworkManager.startObservingReachability(self) { (reachable) in
            if !reachable {
                self.selectedLocation = nil
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NetworkManager.stopObservingReachability(self)
    }

    
    // MARK: - Private methods

    private func updateAnnotation(with location: Location) {
        // Remove previous annotation
        mapView.removeAnnotations(mapView.annotations)
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = location.coordinate
        newAnnotation.title = location.street
        newAnnotation.subtitle = location.city
        
        self.annotation = newAnnotation
    }
    
    private func reverseGeocode(location: CLLocation) {
        if Reachability.forInternetConnection().currentReachabilityStatus().rawValue != 0 {
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                guard let placemarks = placemarks else { return }
                
                if let placemark = placemarks.last,
                    let location = placemark.location,
                    let name = placemark.name,
                    let locality = placemark.locality
                {
                    self.selectedLocation = Location(coordinate: location.coordinate, street: name, city: locality)
                }
            })
        }
    }
}

extension AddressViewController {
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO: may be seguable
        if segue.identifier == "showExplore" {
            if let destinationTabController = segue.destination as? UITabBarController,
                let exploreNavigationController = destinationTabController.childViewControllers[0] as? UINavigationController,
                let exploreVC = exploreNavigationController.topViewController as? ExploreViewController
            {
                exploreVC.inject(self.selectedLocation)
            }
        }
    }
    
    
    @IBAction func closeNearbyList(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - MapViewDelegate methods
extension AddressViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Get location
        let centerLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        updateAnnotation(with: Location(coordinate: centerLocation.coordinate))
        reverseGeocode(location: centerLocation)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        // If no location is selected, then choose user's current location
        if selectedLocation == nil {
            updateAnnotation(with: Location(coordinate: userLocation.coordinate))
            reverseGeocode(location: userLocation.location!)
        }
    }

}
