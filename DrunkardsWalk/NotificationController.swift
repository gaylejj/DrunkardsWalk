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
        
        //Requires UIUserNotificationTypes... so maybe port this to appDelegate?
        
        //Sample
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
        
        
        
        //Uber notification:
        var callAction = UIMutableUserNotificationAction()
        callAction.title = "Call Uber"
        callAction.identifier = "UBER_CALL_ID"
        callAction.activationMode = UIUserNotificationActivationMode.Background
        
        
        var finalDestinationNotification = UIMutableUserNotificationCategory()
        finalDestinationNotification.identifier = "Uber_Category"
        finalDestinationNotification.setActions([callAction, trashAction], forContext: UIUserNotificationActionContext.Default)
        finalDestinationNotification.setActions([], forContext: UIUserNotificationActionContext.Minimal)
        
        
        
        //This should be the same no matter what:

        //
        var types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        //
        
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
    
}
