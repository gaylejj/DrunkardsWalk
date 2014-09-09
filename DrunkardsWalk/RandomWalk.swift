//
//  RandomWalk.swift
//  DrunkardsWalk
//
//  Created by CCA on 9/8/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


class LocationObject {
    var name : String?
    var location : CLLocationCoordinate2D
    var next : LocationObject?
    var intermediateWalks : [CLLocationCoordinate2D]?
    
    init(location : CLLocationCoordinate2D) {
        self.location = location
    }
    
}

class RandomWalk {
    
    let maxWalk = 10000
    
    let walkBin = 0.002 // 222m @ equator; 86m at 67 degrees north.  This is the width of one bin on the map grid and is also multiplied by a gaussian distribution to yield the random differences
    var mapBinX = 0.002 // changes to make integer units of bins. Should be very close to walkBin
    var mapBinY = 0.002
    
    func walkOverLocations(pubCount : Int, startingLocation : CLLocationCoordinate2D, locations : [CLLocationCoordinate2D], upperLeft: CLLocationCoordinate2D, lowerRight: CLLocationCoordinate2D) -> ([LocationObject]?, [CLLocationCoordinate2D]?){
        
        var locList : LocationObject
        if let l = createLocationList(locations)? {
            locList = l
        } else {
            return (nil, nil)
        }
        var grid_Y_X = createGrid(upperLeft, lowerRight: lowerRight, locationList: locList)
        
        var count = 0
        
        var walkRoute = [CLLocationCoordinate2D]()
        var locationRoute = [LocationObject]()
        
        walkRoute.append(startingLocation)
        var lastCoord = startingLocation
        while(count < pubCount && walkRoute.count < self.maxWalk) {
            var newCoord = newCoordinate(lastCoord)
            //TODO: below, is reused code, which is present in the createGrid method
            // get the map bin that the location would exist in
            var X = Int(floor(newCoord.longitude / self.mapBinX))
            var Y = Int(floor(newCoord.latitude / self.mapBinY))
            if let loc = grid_Y_X[Y][X] {
                locationRoute.append(loc)
                walkRoute.append(loc.location)
                lastCoord = loc.location
                grid_Y_X[Y][X] = loc.next
                count++
                
            } else {
                walkRoute.append(newCoord)
                lastCoord = newCoord
            }
        }
        return (locationRoute, walkRoute)
    }

    
    func createLocationList(locations : [CLLocationCoordinate2D]) -> LocationObject? {
        var previousLocation : LocationObject?
        for i in 0..<locations.count {
            var loc = LocationObject(location: locations[i])
            if let pLoc = previousLocation?{
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
    
    func createGrid(upperleft: CLLocationCoordinate2D, lowerRight: CLLocationCoordinate2D, locationList : LocationObject) -> Array<Array<LocationObject?>> {
        let width = abs(lowerRight.longitude - upperleft.longitude)
        let height = abs(upperleft.latitude - lowerRight.latitude)
        // discritizing map into bins
        let numberOfBinsWide = Int(round(width / walkBin))
        let numberOfBinsHigh = Int(round(height / walkBin))

        // new hop width
        self.mapBinX = width / Double(numberOfBinsWide)
        self.mapBinY = height / Double(numberOfBinsHigh)
        
        var arrayX = [LocationObject?](count: numberOfBinsWide, repeatedValue: nil)
        var grid = Array<Array<LocationObject?>>()
        for i in 0..<numberOfBinsHigh {
            grid.append(arrayX)
        }
        
        var loc = locationList
        while(true) {
            // get the map bin that the location would exist in
            var X = Int(floor(loc.location.longitude / self.mapBinX))
            var Y = Int(floor(loc.location.latitude / self.mapBinY))
            if let otherLoc = grid[Y][X]? {
                otherLoc.next = loc
            } else {
                grid[Y][X] = loc
            }
            if let next = loc.next {
                loc = next
            } else {
                break
            }
        }
        return grid
    }
    
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
