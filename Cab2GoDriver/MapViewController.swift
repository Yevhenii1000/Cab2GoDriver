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

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var cancelRiderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.layer.cornerRadius = 20
        
        cancelRiderButton.layer.cornerRadius = 10
        
    }

    @IBAction func cancelRiderButtonPressed(_ sender: UIButton) {
    }
    
}
