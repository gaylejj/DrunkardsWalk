//
//  VisitNotifications.swift
//  DrunkardsWalk
//
//  Created by Leonardo Lee on 9/8/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

//Develop a class for the notifications themselves and also an extension to the MapEngine.
/*
Sorry if this looks pretty bad, this is where I've been developing 3 different parts of the project.
*/

extension MapViewController {
    
    //MARK: -
    func startMonitoring() {
        if CLLocationManager.locationServicesEnabled() {
            self.locationManager.startMonitoringVisits()
            
        } else {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    func stopMonitoring() {
        self.locationManager.stopMonitoringVisits()
    }
    
    //MARK: - CLLocationManager
    //MARK: Region Monitoring
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("Entered region: \(region)")
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        println("Exited region: \(region)")
    }
    
    //MARK: Visit Monitoring
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
        
        //Grabs the departure date of the visit, this is useful for sending notifications the user.
        visit.coordinate
        visit.departureDate
        
    }
}
