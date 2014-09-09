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

class VisitNotifications: NSObject, CLLocationManagerDelegate {
    var appDelegate : AppDelegate
    var runName : String
    var locations : [CLLocation]?
    
    var fakeRegionManager : CLLocationManager
    
    init(name runCalled: String){
        self.runName = runCalled
        self.fakeRegionManager = CLLocationManager()
        self.appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

    }
    
    func startMonitoring() {
        if CLLocationManager.locationServicesEnabled() {
            self.fakeRegionManager.startMonitoringVisits()
            
        } else {
            fakeRegionManager.requestAlwaysAuthorization()
        }
    }
    
    func stopMonitoring() {
        self.fakeRegionManager.stopMonitoringVisits()
    }
    
    /*
    This method is called by the MapSearchEngine's delegate searchResults method.
    */
    func generateNotifications(searchResult: [MKMapItem]) {
        
        for mapItem in searchResult {
            if mapItem.name != "Current Location" {
                var coordinate = mapItem.placemark.coordinate
                var region = CLCircularRegion(circularRegionWithCenter: coordinate, radius: 25, identifier: "PubRegions")
                
                //This should present a notification to changes to the CLCircularRegion on exit.
                region.notifyOnEntry = true //As of right now lets let this stay on.
                region.notifyOnExit = true
                
                //Monitor regions from here.
                //self.fakeRegionManager.startMonitoringRegions(region)
                
                //With new architecture idea I am having for the notifications, this is where I'll send the region information to the appDelegate's notificationController.
                self.appDelegate.notificationController.scheduleNotificationWithRegion(region)
            }
        }
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
    
    //MARK: - Notification Actions
    func setupNotificationActions() {
        
        //Requires UIUserNotificationTypes... so maybe port this to appDelegate?
        
        //Samples:
        var acceptAction = UIMutableUserNotificationAction()
        acceptAction.title = "Accept"
        acceptAction.identifier = "ACCEPT_ID"
        acceptAction.activationMode = UIUserNotificationActivationMode.Background
        
        var trashAction = UIMutableUserNotificationAction()
        trashAction.title = "Trash"
        trashAction.identifier = "TRASH_ID"
        trashAction.activationMode = UIUserNotificationActivationMode.Background
        
        var replyAction = UIMutableUserNotificationAction()
        replyAction.title = "Reply"
        replyAction.identifier = "REPLY_ID"
        replyAction.activationMode = UIUserNotificationActivationMode.Foreground
        
        var registeredActions = UIMutableUserNotificationCategory()
        registeredActions.identifier = "Invite_Category"
        registeredActions.setActions([acceptAction, trashAction, replyAction], forContext: UIUserNotificationActionContext.Default)
        registeredActions.setActions([acceptAction, replyAction], forContext: UIUserNotificationActionContext.Minimal)
        
        
        //
        var types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        //
        
        var categories = NSSet(objects: registeredActions)
        
        var settings = UIUserNotificationSettings(forTypes: types, categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        //Template to use a registered type of notification:
        var notification = UILocalNotification()
        notification.category = "Invite_Category"
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        /*
        Handle with:
            optional func application(_ application: UIApplication,
            handleActionWithIdentifier identifier: String?,
            forLocalNotification notification: UILocalNotification,
            completionHandler completionHandler: () -> Void)
        
            Within this we will need to use : [self handleAcceptActionWithNotification:notification];
        
        */
        
        
    }
}

