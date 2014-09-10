//
//  WalkMapItem.swift
//  DrunkardsWalk
//
//  Created by CCA on 9/10/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class WalkMapItem {
    var next : WalkMapItem?
    var mapItem : MKMapItem
    var walkRoute = [CLLocationCoordinate2D]()
    
    init(mapItem : MKMapItem) {
        self.mapItem = mapItem
    }
}