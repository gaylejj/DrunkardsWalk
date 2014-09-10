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

class NotificationController {
    
    init(){}
    
    //MARK: Scheduling a Notification
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
        //        notification.region
        //notification.regionTriggersOnce = true
        
        //Send the notification to
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
        //Notes on what objects we will be dealing with.
        //An array of location of MKMapItems -> CLLocation
        //These CLLocations are going to be used to set the regions that we will be using.
        
    }
    
    //MARK: - Notification Actions
    func setupNotificationActions() {
        //Sample notification:
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
        registeredActions.identifier = "INVITE_Category"
        registeredActions.setActions([acceptAction, trashAction, replyAction], forContext: UIUserNotificationActionContext.Default)
        registeredActions.setActions([acceptAction, replyAction], forContext: UIUserNotificationActionContext.Minimal)
        
        
        //Unicode scalars - I need to see if they are of the icomoon font pack.
        
        
        //Base notification:
        let checkAction = UIMutableUserNotificationAction()
        checkAction.title = "\u{e606}"
        checkAction.identifier = "FINISH_ID"
        checkAction.activationMode = UIUserNotificationActivationMode.Background
        
        let cancelAction = UIMutableUserNotificationAction()
        cancelAction.title = "\u{e604}"
        cancelAction.identifier = "CANCEL_ID"
        cancelAction.destructive = true
        cancelAction.activationMode = UIUserNotificationActivationMode.Background
        
        let happyAction = UIMutableUserNotificationAction()
        happyAction.title = "\u{e602}"
        happyAction.identifier = "HAPPY_ID"
        happyAction.activationMode = UIUserNotificationActivationMode.Background
        
        let madAction = UIMutableUserNotificationAction()
        madAction.title = "\u{e603}"
        madAction.identifier = "MAD_ID"
        madAction.activationMode = UIUserNotificationActivationMode.Background
        
        var pubCrawlCategory = UIMutableUserNotificationCategory()
        pubCrawlCategory.identifier = "PUB_Category"
        pubCrawlCategory.setActions([checkAction, cancelAction], forContext: UIUserNotificationActionContext.Minimal)
        pubCrawlCategory.setActions([checkAction, happyAction, madAction, cancelAction], forContext: UIUserNotificationActionContext.Default)
        
        
        //Uber notification:
        var callAction = UIMutableUserNotificationAction()
        callAction.title = "\u{600} Uber"
        callAction.identifier = "UBER_CALL_ID"
        callAction.activationMode = UIUserNotificationActivationMode.Background
        
        
        var finalDestinationNotification = UIMutableUserNotificationCategory()
        finalDestinationNotification.identifier = "UBER_Category"
        finalDestinationNotification.setActions([callAction, cancelAction], forContext: UIUserNotificationActionContext.Default)
        finalDestinationNotification.setActions([callAction, cancelAction], forContext: UIUserNotificationActionContext.Minimal)
        
        
        //Finesse a bit of logic to help the use not spend money on getting to a loction that they can easily walk to. We'll have to figure out a good place to get that working.
        
        
        //This should be the same no matter what:
        
        //
        var types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        //
        
        //TODO: Stick UBER and the normal one in here. The registered sample one is perfect for prelim testing.
        var categories = NSSet(objects: registeredActions)
        
        var settings = UIUserNotificationSettings(forTypes: types, categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        
        /*
        Handle with:
        optional func application(_ application: UIApplication,
        handleActionWithIdentifier identifier: String?,
        forLocalNotification notification: UILocalNotification,
        completionHandler completionHandler: () -> Void)
        
        Within this we will need to use : [self handleAcceptActionWithNotification:notification];
        
        */
        
        
    }
    
    //I'm keeping this here is people are interested in finding their custom font names later on. In their projects.
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
