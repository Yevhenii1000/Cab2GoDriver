//
//  CabHandler.swift
//  Cab2GoDriver
//
//  Created by Yevhenii on 04.05.2018.
//  Copyright © 2018 Yevhenii. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol CabUnitDelegate: class {
    
    func didGetCabRequest(fromLat lat: Double, long: Double)
    func didCanceledRequest()
    func didCancelRide()
    func didUpdateRidersLocation(lat: Double, long: Double)
}

class CabUnitManager {
    
    private static let instance = CabUnitManager()
    
    var cabUnitDelegate: CabUnitDelegate?
    
    static var defaultManager: CabUnitManager {
        return instance
    }
    
    var rider = ""
    var driver = ""
    var driver_id = ""
    
    func observeCarRequests() {
        DatabaseManager.defaultManager.cabRequestReference.observe(.childAdded, with: {(dataSnapshot: DataSnapshot) in
            
            if let data = dataSnapshot.value as? NSDictionary {
                if let lat = data[Constants.latitude] as? Double,let long = data[Constants.longitude] as? Double {
                    
                    if let delegate = self.cabUnitDelegate {
                        delegate.didGetCabRequest(fromLat: lat, long: long)
                    }
                    
                }
                
                if let name = data[Constants.name] as? String {
                    
                    self.rider = name
                    
                }
                
            }
            
            DatabaseManager.defaultManager.cabRequestReference.observe(.childAdded, with: {(dataSnapshot) in
                
                if let data = dataSnapshot.value as? NSDictionary {
                    
                    if let name = data[Constants.name] as? String {
                        if name == self.rider {
                            
                            self.rider = ""
                            self.cabUnitDelegate?.didCanceledRequest()
                            
                        }
                        
                    }
                    
                }
                
            })
            
        })
        
        //Rider Location Updating
        
        DatabaseManager.defaultManager.cabRequestReference.observe(.childChanged, with: {(dataSnapshot) in
            
            if let data = dataSnapshot.value as? NSDictionary {
                
                if let lat = data[Constants.latitude] as? Double, let long = data[Constants.longitude] as? Double {
                    
                    self.cabUnitDelegate?.didUpdateRidersLocation(lat: lat, long: long)
                    
                }
                
            }
            
        })
        
        //Driver accepts the ride
        
        DatabaseManager.defaultManager.cabRequestAcceptedReference.observe(.childAdded, with: {dataSnapshot in
            
            if let data = dataSnapshot.value as? NSDictionary {
                
                if let name = data[Constants.name] as? String {
                    
                    if name == self.driver {
                        
                        self.driver_id = dataSnapshot.key
                        
                    }
                    
                }
                
            }
            
        })
        
        //Driver canceled ride
        DatabaseManager.defaultManager.cabRequestReference.observe(.childRemoved, with: {dataSnapshot in
            
            if let data = dataSnapshot as? NSDictionary {
                
                if let name = data[Constants.name] as? String {
                    
                    if name == self.driver {
                        
                        self.cabUnitDelegate?.didCancelRide()
                        
                    }
                    
                }
                
            }
            
        })
        
    }
    
    func cabAccepted(_ lat: Double, long: Double) {
        
        let data: Dictionary<String,Any> = [Constants.name : driver, Constants.latitude : lat, Constants.longitude : long]
        
        DatabaseManager.defaultManager.cabRequestAcceptedReference.childByAutoId().setValue(data)
        
    }
    
    func updateDriverLocation(lat: Double, long: Double) {
        
        DatabaseManager.defaultManager.cabRequestAcceptedReference.child(driver_id).updateChildValues([Constants.latitude:lat, Constants.longitude: long])
        
    }
    
    func cancelRideForDriver() {
        
        DatabaseManager.defaultManager.cabRequestAcceptedReference.child(driver_id).removeValue()
        
    }
    
    func cancelRide() {
        
        DatabaseManager.defaultManager.cabRequestReference.child(driver_id).removeValue()
        
    }
    
}
