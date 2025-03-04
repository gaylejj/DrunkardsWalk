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
    var maxMax : CLLocationCoordinate2D!
    var minMin : CLLocationCoordinate2D!
    
    init(maxMax: CLLocationCoordinate2D, minMin: CLLocationCoordinate2D) {
        self.maxMax = maxMax
        self.minMin = minMin
    }
    
    func walkOverLocations(pubCount : Int, startingLocation : MKMapItem, locations : [MKMapItem]) -> WalkMapItem? {
        
        var walkList : WalkMapItem
        if let l = self.loadWalkList(locations)? {
            walkList = l
        } else {
            return nil
        }
        var grid_Y_X = createGrid(walkList)
        
        var count = 0
        var walkCount = 0
        var startingLocation = WalkMapItem(mapItem: startingLocation)
        var currentLocation = startingLocation
        
        while((count < pubCount) && (walkCount < self.maxWalk)) {
            var newCoord = newCoordinate(currentLocation.getCurrentRouteLocation())
            
            // get the map bin that the location would exist in
            var (X, Y) = self.getXYBin(newCoord)
            
            // we find a pub at the grid point and add to linked list
            if let walkItem = grid_Y_X[Y][X] {
                // append new found pub to previous
                currentLocation.next = walkItem
                // tell grid to point to next pub (if any)
                grid_Y_X[Y][X] = walkItem.next
                currentLocation = walkItem
                currentLocation.next = nil
                count++
            } else {
                currentLocation.walkRoute.append(newCoord)
                walkCount++
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
            }
            previousLocation = loc
        }
        return previousLocation
    }

    
    func newCoordinate(oldCoordinate : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let (g1, g2) = self.newGaussian()
        var newLat = oldCoordinate.latitude + (g1 * self.mapBinY)
        if newLat > self.maxMax.latitude {
            var diff = newLat - self.maxMax.latitude
            newLat = newLat - 2 * diff
        }
        if newLat < self.minMin.latitude {
            var diff = self.minMin.latitude - newLat
            newLat = newLat + 2 * diff
        }
        
        var newLon = oldCoordinate.longitude + (g2 * self.mapBinX)
        if newLon > self.maxMax.longitude {
            var diff = newLon - self.maxMax.longitude
            newLon = newLon - 2 * diff
        }
        if newLon < self.minMin.longitude {
            var diff = self.minMin.longitude - newLon
            newLon = newLon + 2 * diff
        }
        
        return CLLocationCoordinate2DMake(newLat, newLon)
    }
    
    private func getXYBin(location : CLLocationCoordinate2D) -> (Int, Int) {
        var lonDiff = location.longitude - self.minMin.longitude
        var X = Int(floor( lonDiff / self.mapBinX))
        var latDiff = (location.latitude - self.minMin.latitude)
        var Y = Int(floor( latDiff / self.mapBinY))
        return (X,Y)
    }
    
    func createGrid(walkListItem : WalkMapItem) -> Array<Array<WalkMapItem?>> {
        
        var width = abs(Double(self.minMin.longitude) - Double(self.maxMax.longitude))
        var height = abs(self.maxMax.latitude - self.minMin.latitude)
        
        // discretizing map into bins
        var numberOfBinsWide = Int(round(width / walkBin))
        var numberOfBinsHigh = Int(round(height / walkBin))

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
            var (X, Y) = self.getXYBin(loc)
            
            if let otherWalkItem = grid[Y][X]? {
                otherWalkItem.next = walkItem
            } else {
                grid[Y][X] = walkItem
            }
            if let next = walkItem.next {
                walkItem.next = nil
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
