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
    
    func getCurrentRouteLocation() -> CLLocationCoordinate2D {
        if self.walkRoute.count > 0 {
            return self.walkRoute.last!
        } else {
            return self.mapItem.placemark.location.coordinate
        }
    }
    
    // function to unpack the linked list
    // 1) source (mapItem) or startingLocation
    func getMapItems() -> [MKMapItem] {
        var items = [MKMapItem]()
        items.append(self.mapItem)
        if let n = self.next {
            items += n.getMapItems()
        }
        return items
    }
}