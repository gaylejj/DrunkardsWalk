//
//  RandomWalk.swift
//  DrunkardsWalk
//
//  Created by CCA on 9/8/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class RandomWalk {
    
    let maxWalk = 10000
    
    let walkBin = 0.002 // 222m @ equator; 86m at 67 degrees north.  This is the width of one bin on the map grid and is also multiplied by a gaussian distribution to yield the random differences
    var mapBinX = 0.002 // changes to make integer units of bins. Should be very close to walkBin
    var mapBinY = 0.002
    
    func walkOverLocations(pubCount : Int, startingLocation : MKMapItem, locations : [MKMapItem], upperLeft: CLLocationCoordinate2D, lowerRight: CLLocationCoordinate2D) -> WalkMapItem? {
        
        var walkList : WalkMapItem
        if let l = self.loadWalkList(locations)? {
            walkList = l
        } else {
            return nil
        }
        var grid_Y_X = createGrid(upperLeft, lowerRight: lowerRight, walkListItem: walkList)
        
        var count = 0
        
        var startingLocation = WalkMapItem(mapItem: startingLocation)
        var currentLocation = startingLocation

        var lastCoord = currentLocation.getCurrentRouteLocation()
        while(count < pubCount && currentLocation.walkRoute.count < self.maxWalk) {
            var newCoord = newCoordinate(lastCoord)
            
            //TODO: below, is reused code, which is present in the createGrid method
            // get the map bin that the location would exist in
            var X = Int(floor(newCoord.longitude / self.mapBinX))
            var Y = Int(floor(newCoord.latitude / self.mapBinY))
            
            // we find a pub at the grid point and add to linked list
            if let walkItem = grid_Y_X[Y][X] {
                currentLocation.next = walkItem
                grid_Y_X[Y][X] = walkItem.next
                currentLocation = walkItem
                count++
            } else {
                currentLocation.walkRoute.append(newCoord)
            }
        }
        return startingLocation
    }

    // takes locations array and builds a linked list of LocationObjects
    func loadWalkList(locations : [MKMapItem]) -> WalkMapItem? {
        var previousLocation : WalkMapItem?
        for i in 0..<locations.count {
            var loc = WalkMapItem(mapItem: locations[i])
            if let pLoc = previousLocation? {
                loc.next = pLoc
                previousLocation = loc
            }
        }
        return previousLocation
    }

    
    func newCoordinate(oldCoordinate : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let (g1, g2) = self.newGaussian()
        let newLat = oldCoordinate.latitude + (g1 * self.mapBinY)
        let newLon = oldCoordinate.longitude + (g2 * self.mapBinX)
        return CLLocationCoordinate2DMake(newLat, newLon)
    }
    
    func createGrid(upperleft: CLLocationCoordinate2D, lowerRight: CLLocationCoordinate2D, walkListItem : WalkMapItem) -> Array<Array<WalkMapItem?>> {
        let width = abs(lowerRight.longitude - upperleft.longitude)
        let height = abs(upperleft.latitude - lowerRight.latitude)
        // discritizing map into bins
        let numberOfBinsWide = Int(round(width / walkBin))
        let numberOfBinsHigh = Int(round(height / walkBin))

        // new hop width
        self.mapBinX = width / Double(numberOfBinsWide)
        self.mapBinY = height / Double(numberOfBinsHigh)
        
        // create 2D array
        var arrayX = [WalkMapItem?](count: numberOfBinsWide, repeatedValue: nil)
        var grid = Array<Array<WalkMapItem?>>()
        for i in 0..<numberOfBinsHigh {
            grid.append(arrayX)
        }
        
        var walkItem = walkListItem
        while(true) {
            var loc = walkItem.mapItem.placemark.location.coordinate
            var X = Int(floor(loc.longitude / self.mapBinX))
            var Y = Int(floor(loc.latitude / self.mapBinY))
            
            if let otherWalkItem = grid[Y][X]? {
                otherWalkItem.next = walkItem
            } else {
                grid[Y][X] = walkItem
            }
            if let next = walkItem.next {
                walkItem = next
            } else {
                break
            }
        }
        return grid
    }
    
    
    //TODO: re-write using a polar gaussian function to correct for low diagonal probability
    func newGaussian() -> (g1 : Double, g2 : Double) {
        let u1 = Double(arc4random()) / Double(UINT32_MAX); // uniform distribution
        let u2 = Double(arc4random()) / Double(UINT32_MAX); // uniform distribution
        let f1 = sqrt(-2 * log(u1));
        let f2 = 2 * M_PI * u2;
        let g1 = f1 * cos(f2); // gaussian distribution
        let g2 = f1 * sin(f2); // gaussian distribution
        return (g1, g2)
    }
}
