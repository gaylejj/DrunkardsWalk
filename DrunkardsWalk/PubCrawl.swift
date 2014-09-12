//
//  PubCrawl.swift
//  DrunkardsWalk
//
//  Created by Kirby Shabaga on 9/12/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import Foundation
import CoreData

class PubCrawl: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var startDate: NSDate
    @NSManaged var endDate: NSDate
    @NSManaged var currentPub: NSNumber
    @NSManaged var pubCount: NSNumber
    @NSManaged var pubs: NSOrderedSet

}
