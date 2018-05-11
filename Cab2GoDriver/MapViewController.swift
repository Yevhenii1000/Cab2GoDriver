//
//  MapViewController.swift
//  Cab2GoDriver
//
//  Created by Yevhenii on 18.04.2018.
//  Copyright © 2018 Yevhenii. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController, CabUnitDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var cancelRiderButton: UIButton!
    
    private var locationManager = CLLocationManager()
    
    private var driversLocation: CLLocationCoordinate2D?
    private var ridersLocation: CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var acceptedRide = false
    private var driverCancelledRide = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CabUnitManager.defaultManager.cabUnitDelegate = self
        CabUnitManager.defaultManager.observeCarRequests()
        
        mapView.delegate = self
        
        mapView.layer.cornerRadius = 20
        
        cancelRiderButton.layer.cornerRadius = 10
        setLocationManager()
    }
    
    //MARK: - Methods
    
    //Cab Request Notification Delegate
    
    func didGetCabRequest(fromLat lat: Double, long: Double) {
        
        if !acceptedRide {
            
            alertAboutCabRequest(withTitle: "Cab Requested", message: "The rider in your area requested a ride, location \(lat),\(long)", requestIsAlive: true)
            
        }
    }
    
    func didCanceledRequest() {
        
        if !driverCancelledRide {
            
            CabUnitManager.defaultManager.cancelRideForDriver()
            //cancel the ride from driver`s perspective
            self.cancelRiderButton.isHidden = true
            self.acceptedRide = false
            alertAboutCabRequest(withTitle: "Ride Cancelled", message: "Rider has cancelled the ride", requestIsAlive: false)
        }
        
    }
    
    func didCancelRide() {
        acceptedRide = false
        //invalidate timer
        
        timer.invalidate()
        
    }
    
    func didUpdateRidersLocation(lat: Double, long: Double) {
        ridersLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    @objc func updateDriversLocation() {
        
        CabUnitManager.defaultManager.updateDriverLocation(lat: (driversLocation?.latitude)!, long: (driversLocation?.longitude)!)
        
    }
    
    //MARK: - Settings
    
    func setLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    private func alertAboutCabRequest(withTitle title:String, message: String, requestIsAlive: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if requestIsAlive {
            
            let acceptRideAction = UIAlertAction(title: "Accept", style: .default, handler: { action in
                
                self.acceptedRide = true
                self.cancelRiderButton.isHidden = false
                
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(5),
                                             target: self,
                                             selector: #selector(MapViewController.updateDriversLocation),
                                             userInfo: nil,
                                             repeats: true)
                
                CabUnitManager.defaultManager.cabAccepted(Double((self.driversLocation?.latitude)!), long: Double((self.driversLocation?.longitude)!))
                
            })
            let cancelRideAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            
            alert.addAction(acceptRideAction)
            alert.addAction(cancelRideAction)
        } else {
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func alertUser(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alerAction_OK = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alerAction_OK)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Actions
    
    @IBAction func logOutButtonPressed(_ sender: UIBarButtonItem) {
        if UsersAuthenticationManager.authManager.logOut() {
            
            if acceptedRide {
                
                cancelRiderButton.isHidden = true
                CabUnitManager.defaultManager.cancelRideForDriver()
                timer.invalidate()
                
            }
            
            dismiss(animated: true, completion: nil)
            
        } else {
            
            alertUser(title: "Problem signing out", message: "Please, try again later")
            
        }
    }

    @IBAction func cancelRiderButtonPressed(_ sender: UIButton) {
        
        if acceptedRide {
            driverCancelledRide = true
            CabUnitManager.defaultManager.cancelRideForDriver()
            //invalidate timer
            
            timer.invalidate()
            
        }
        
        
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coordinate = locationManager.location?.coordinate {
            
            driversLocation = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let region = MKCoordinateRegion(center: driversLocation!,
                                   span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapView.setRegion(region, animated: true)
            
            mapView.removeAnnotations(mapView.annotations)
            
            if ridersLocation != nil && acceptedRide {
                
                let riderAnnotation = MKPointAnnotation()
                riderAnnotation.coordinate = ridersLocation!
                riderAnnotation.title = "Cab Rider"
                mapView.addAnnotation(riderAnnotation)
                
            }
            
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = coordinate
//            annotation.title = "Driver`s Location"
//            mapView.addAnnotation(annotation)
        }
    }
    
}
