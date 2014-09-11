//
//  NotificationController.swift
//  DrunkardsWalk
//
//  Created by Leonardo Lee on 9/9/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

/*
    Bit of a misnomer, this is a controller to help set up how notifications register, actions work as well as schedule notification to be seen.
*/

import UIKit
import MapKit

//We still need to do the logic for Uber. Finesse a bit of logic to help the use not spend money on getting to a loction that they can easily walk to. We'll have to figure out a good place to get that working.

class NotificationController {
    
    init(){
        self.setupNotificationActions()
    }
    
    
    //MARK: - Scheduling a Notification
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
                self.scheduleNotificationWithRegion(region)
            }
        }
    }
    
    func scheduleNotificationWithRegion(region : CLRegion) {
        
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
        //notification.region
        //notification.regionTriggersOnce = true
        
        //Send the notification to
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        //Notes on what objects we will be dealing with.
        //An array of location of MKMapItems -> CLLocation
        //These CLLocations are going to be used to set the regions that we will be using.
        
    }
    
    //MARK: - Notification Actions
    func setupNotificationActions() {
        //Notification Actions:
        let checkAction = UIMutableUserNotificationAction()
        checkAction.title = "\u{e606}"
        checkAction.identifier = kNotification.Action.Check.toRaw()
        checkAction.activationMode = UIUserNotificationActivationMode.Background
        
        let cancelAction = UIMutableUserNotificationAction()
        cancelAction.title = "\u{e604}"
        cancelAction.identifier = kNotification.Action.Cancel.toRaw()
        cancelAction.destructive = true
        cancelAction.activationMode = UIUserNotificationActivationMode.Background
        
        let rateUp = UIMutableUserNotificationAction()
        rateUp.title = "\u{e602}"
        rateUp.identifier = kNotification.Action.RateUp.toRaw()
        rateUp.activationMode = UIUserNotificationActivationMode.Background
        
        let rateDown = UIMutableUserNotificationAction()
        rateDown.title = "\u{e603}"
        rateDown.identifier = kNotification.Action.RateDown.toRaw()
        rateDown.activationMode = UIUserNotificationActivationMode.Background
        
        let callAction = UIMutableUserNotificationAction()
        callAction.title = "\u{600} Uber"
        callAction.identifier = kNotification.Action.CallUber.toRaw()
        callAction.activationMode = UIUserNotificationActivationMode.Background
        
        //The two notification categories used by the app.
        let pubCrawlCategory = UIMutableUserNotificationCategory()
        pubCrawlCategory.identifier = kNotification.Category.PubCrawl.toRaw()
        pubCrawlCategory.setActions([checkAction, cancelAction], forContext: UIUserNotificationActionContext.Minimal)
        pubCrawlCategory.setActions([checkAction, rateUp, rateDown, cancelAction], forContext: UIUserNotificationActionContext.Default)
        
        let uberNotification = UIMutableUserNotificationCategory()
        uberNotification.identifier = kNotification.Category.Uber.toRaw()
        uberNotification.setActions([callAction, cancelAction], forContext: UIUserNotificationActionContext.Default)
        uberNotification.setActions([callAction, cancelAction], forContext: UIUserNotificationActionContext.Minimal)
        
        //Takes defined category types and registers them within the application.
        var types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        var categories = NSSet(objects: pubCrawlCategory, uberNotification)
        
        var settings = UIUserNotificationSettings(forTypes: types, categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
    }
    
    //I'm keeping this here is people are interested in finding their custom font names later in their own projects.
    func lookAtFontFamilies() {
        for fontFamily in UIFont.familyNames() {
            if let family = fontFamily as? String {
                println("Family: \(family)")
                for fontName in UIFont.fontNamesForFamilyName(family) {
                    if let name = fontName as? String {
                        println("\tNamed: \(name)")
                    }
                }
            }
        }
    }
    
}
