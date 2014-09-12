//
//  Pub.swift
//  DrunkardsWalk
//
//  Created by Kirby Shabaga on 9/12/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import Foundation
import CoreData

class Pub: NSManagedObject {

    @NSManaged var lat: NSNumber
    @NSManaged var long: NSNumber
    @NSManaged var name: String
    @NSManaged var pubCrawl: NSManagedObject

}
