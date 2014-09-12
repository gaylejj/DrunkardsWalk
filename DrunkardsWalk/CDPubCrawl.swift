//
//  CDPubCrawl.swift
//  DrunkardsWalk
//
//  Created by Kirby Shabaga on 9/12/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import CoreData
import Foundation
import MapKit
import UIKit

class CDPubCrawl {
    
    var moc : NSManagedObjectContext!
    
    init() {
        // set managed object context
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.moc = appDelegate.managedObjectContext
    }
    
    
    // ------------------------------------------------------------------------------
    // Create Drunkards Walk Pub Crawl entry
    // ------------------------------------------------------------------------------
    // A default entry will be created in Core Data representing this pub crawl
    // it will be updated with calls to func updatePubCrawl()
    
    func createPubCrawl(mapItems : [MKMapItem]) {
        
        var error : NSError?
        var pubCrawl = NSEntityDescription.insertNewObjectForEntityForName("PubCrawl", inManagedObjectContext: self.moc) as PubCrawl
        
        // Default property values
        pubCrawl.name = UIDevice.currentDevice().name
        pubCrawl.startDate = NSDate()
        pubCrawl.currentPub = 0
        pubCrawl.pubCount = mapItems.count
        
        // create the Pub entries
        var pubs = [Pub]()
        for index in 0..<mapItems.count {
            var pub = NSEntityDescription.insertNewObjectForEntityForName("Pub", inManagedObjectContext: self.moc) as Pub
            
            pub.name = mapItems[index].name
            pub.lat = mapItems[index].placemark.coordinate.latitude
            pub.long = mapItems[index].placemark.coordinate.longitude
            
            pubs.append(pub)
        }
        
        // add the array of pubs to "pubs"
        var pubsCrawled = pubCrawl.mutableOrderedSetValueForKey("pubs")
        pubsCrawled.addObjectsFromArray(pubs)
        
        self.moc.save(&error)

        if error != nil {
            // TODO: Exception handling
            println("\(error?.localizedDescription)")
        }
    }
    
    // ------------------------------------------------------------------------------
    // Load previous Drunkards Walk Pub Crawl entries
    // ------------------------------------------------------------------------------
    
    func loadPubCrawls() -> [PubCrawl] {
        
        var request = NSFetchRequest(entityName: "PubCrawl")
        let sort = NSSortDescriptor(key: "startDate", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
        
        var error : NSError?
        
        var pubCrawls = self.moc.executeFetchRequest(request, error: &error) as [PubCrawl]
        
        return pubCrawls
    }
    
}