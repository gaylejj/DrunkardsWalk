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
class VisitNotifications: NSObject, CLLocationManagerDelegate {
    var runName : String
    var locations : [CLLocation]?
    
    var fakeRegionManager : CLLocationManager
    
    init(name runCalled: String){
        self.runName = runCalled
        self.fakeRegionManager = CLLocationManager()

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
    class func generateNotifications(searchResult: [MKMapItem]) {
        
        for mapItem in searchResult {
            if mapItem.name != "Current Location" {
                var coordinate = mapItem.placemark.coordinate
                var region = CLCircularRegion(circularRegionWithCenter: coordinate, radius: 25, identifier: "PubRegions")
                
                //This should present a notification to changes to the CLCircularRegion on exit.
                region.notifyOnEntry = true //As of right now lets let this stay on.
                region.notifyOnExit = true
                
                //Monitor regions from here.
                //self.fakeRegionManager.startMonitoringRegions(region)
            }
        }
        
        /*
        Use the new Location notification objects rather than the mapItems, but grab the CL objects!
        Move the notification code up into the mapItem loop to develop the regions.
        */
        
        
        //This notification stuff is going to be manipulated and changed about for a while.
        //This will probably set to a notification that is based not on the region, but rather just called.
        var notification = UILocalNotification()
        notification.soundName = UILocalNotificationDefaultSoundName
        //notification.applicationIconBadgeNumber
        notification.timeZone = NSTimeZone.defaultTimeZone()
        
        //Testing with the time property and alertss
        //var dateTime = NSDate.date()
        var dateComponents = NSDateComponents()
        dateComponents.second = 10
        var dateTime = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: NSDate.date(), options: nil)
        notification.fireDate = dateTime
        
        //Way to store data.
        //notification.userInfo = [String:String]()
        //notification.alertLaunchImage
        notification.alertAction = "Alert!"
        notification.alertBody = "Fired at \(dateTime)"
        
        //Regions related code
//        notification.region
        //notification.regionTriggersOnce = true
        
        //Send the notification to
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        //Notes on what objects we will be dealing with.
        //An array of location of MKMapItems -> CLLocation
        //These CLLocations are going to be used to set the regions that we will be using.
        
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

