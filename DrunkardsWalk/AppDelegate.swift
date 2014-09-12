//
//  AppDelegate.swift
//  DrunkardsWalk
//
//  Created by CCA on 9/5/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?
    var notificationController = NotificationController()
    var alert : UIAlertController?

//MARK: -
    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.
        
        
        //This is to check is the application opened in the background.
        let state = application.applicationState
        if state == UIApplicationState.Background {
            
        }
        
        
        //This looks at the current settings and compares them to what we want. If they are not the same, this'll register the settings and ask to notifications for the app.
        
        //https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/IPhoneOSClientImp.html#//apple_ref/doc/uid/TP40008194-CH103-SW13
        //Listin 2-4
        if let notificationLaunch = launchOptions.objectForKey(UIApplicationLaunchOptionsLocalNotificationKey) as? UILocalNotification {
            if let item = notificationLaunch.userInfo as? [String:AnyObject] {
                //This key needs to be customized.
                //if let itemNamed = item["Key"] as? String {}
            }
        }
        
        let currentSettings = application.currentUserNotificationSettings()
        let types = UIUserNotificationType.Sound | UIUserNotificationType.Alert
        var settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        
        if currentSettings != settings {
            application.registerUserNotificationSettings(settings)

        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    //MARK: - URL
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        //This will be used to open up a pub crawl from a NSURL string (we can use this to our advantage by hashing states to persist them or something.
        return true
    }
    
    //MARK: - Notifications
    
    //This checks changes to the settings, including the denial, this'll then prompt with an action to allow settings desired.
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
        let types = UIUserNotificationType.Sound | UIUserNotificationType.Alert
        let desiredSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        
        if notificationSettings != desiredSettings {
            let askChange = UIAlertController(title: "Settings Changed", message: "The settings you have selected do not match the reccomended settings, are you sure you want to do that?", preferredStyle: UIAlertControllerStyle.Alert)

            /*
            It might be better to use this to open it to settings?
            NOTE: As of iOS8 Use this to open up settings: NSURL(string: UIApplicationOpenSettingsURLString)
            UIApplicationOpenSettingsURLString
            */
            
            let change = UIAlertAction(title: "Reccomended", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                application.registerUserNotificationSettings(desiredSettings)
            })
            let okay = UIAlertAction(title: "Ignore", style: UIAlertActionStyle.Default, handler: nil)
            
            askChange.addAction(change)
            askChange.addAction(okay)
            
            self.window?.rootViewController?.presentViewController(askChange, animated: true, completion: nil)
        }
    }
    
    //This is the functionality for the notification when the app is open.
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        println("Received")
        
        if application.applicationState == UIApplicationState.Active {
            if alert == nil {
                self.alert = UIAlertController(title: "Hey!", message: "\(notification.alertBody)", preferredStyle: UIAlertControllerStyle.Alert)
                
                var okay = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
                self.alert?.addAction(okay)
            }
            self.window?.rootViewController?.presentViewController(self.alert!, animated: true, completion: nil)
        }
    }
    
    //This is intended for notifications that are local, but the app is not open.
    //TODO: Handling notification actions.
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        
        //I'd want to do the enum and switch statement, but that apparently does not work with enums. I'll work on it later. For now, constants and if-else will work.
        
        if let actionNamed = identifier {
            if let action = kNotification.Action.fromRaw(identifier!) {
                switch action {
                case .Check:
                    println()
                case .Cancel:
                    application.cancelLocalNotification(notification)
                case .RateUp:
                    println()
                case .RateDown:
                    println()
                case .CallUber:
                    println()
                }
            }
        }
        
        completionHandler()
    }

    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.collinatherton.DrunkardsWalk" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("DrunkardsWalk", withExtension: "momd")
        return NSManagedObjectModel(contentsOfURL: modelURL!)
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("DrunkardsWalk.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError.errorWithDomain("YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

