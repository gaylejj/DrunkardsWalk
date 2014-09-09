//
//  MapSearchEngine.swift
//  DrunkardsWalk
//
//  Created by Kirby Shabaga on 9/8/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import CoreData
import Foundation
import MapKit

protocol MapSearchEngineDelegate {
    
    func searchResults(items : [MKMapItem])
    func walkingPathPolyLine(polyline : MKPolyline)
    func walkingPathCoordinates(coords : [CLLocationCoordinate2D])
    
}

class MapSearchEngine {
    
    var moc : NSManagedObjectContext!
    
    var delegate : MapSearchEngineDelegate!
    var request : MKLocalSearchRequest!
    
    var userLocation : MKMapItem!
    
    init() {
        self.request = MKLocalSearchRequest()
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.moc = appDelegate.managedObjectContext
    }
    
    // -------------------------------------------------------------------------
    
    func search(userLocation : MKMapItem, region : MKCoordinateRegion, query: String) {
        
        self.userLocation = userLocation
        self.request.region = region
        self.request.naturalLanguageQuery = query
        
        var search = MKLocalSearch(request: self.request)
        search.startWithCompletionHandler { (response, error) -> Void in
            // NOTE: Always on the main thread
            if error != nil {
                println("TODO: \(error.localizedDescription)")
            } else if response.mapItems.count == 0 {
                println("E0 - no items found :-(")
            } else if let items = response.mapItems as? [MKMapItem] {
                if self.delegate != nil {
                    self.delegate.searchResults(items)
                }
            }
        }
    }
    
    func search(userLocation : MKMapItem, region : MKCoordinateRegion, query: String, callback : (items : [MKMapItem]) -> Void) {
        
        println("query = \(query)")
        
        self.userLocation = userLocation
        self.request.region = region
        self.request.naturalLanguageQuery = query
        
        var search = MKLocalSearch(request: self.request)
        search.startWithCompletionHandler { (response, error) -> Void in
            // NOTE: Always on the main thread
            if error != nil {
                println("TODO: \(error.localizedDescription)")
            } else if response.mapItems.count == 0 {
                println("E0 - no items found :-(")
            } else if let items = response.mapItems as? [MKMapItem] {
//                for item in items {
//                    self.calculateDistanceToItem(item, callback: { (distance : CLLocationDistance) -> Void in
//                        println("Distance to \(item.name) is \(distance)")
//                    } )
//                }
                callback(items: items)
            }
        }
    }
    
    func search2(userLocation : MKMapItem, region : MKCoordinateRegion) {
        // First Search: Bar
        self.search(userLocation, region: region, query: "Bar")
    }
    
    func calculateWalkingPath(source : MKMapItem, destination : MKMapItem) {
        var walkingRouteRequest = MKDirectionsRequest()
        walkingRouteRequest.transportType = MKDirectionsTransportType.Walking
        walkingRouteRequest.setSource(source)
        walkingRouteRequest.setDestination(destination)
        
        var walkingRouteDirections = MKDirections(request: walkingRouteRequest)
        walkingRouteDirections.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if error != nil {
                println("TODO: \(error.localizedDescription)")
            } else if let routes = response.routes as? [MKRoute] {
                var firstRoute = routes[0]
                var coords = MapSearchEngine.getWalkingPointsFromPolyLine(firstRoute.polyline)
                //                for i in 0..<coords.count {
                //                    println("\(coords[i].latitude) \(coords[i].longitude)")
                //                }
                self.delegate.walkingPathPolyLine(firstRoute.polyline)
            }
        }
    }
    
    // Calculate walking distance from current location to map item
    func calculateDistanceToItem(item : MKMapItem, callback : (distance: CLLocationDistance) -> Void) {
        
        var walkingRouteRequest = MKDirectionsRequest()
        walkingRouteRequest.transportType = MKDirectionsTransportType.Walking
        walkingRouteRequest.setSource(MKMapItem.mapItemForCurrentLocation())
        walkingRouteRequest.setDestination(item)
        
        var walkingRouteDirections = MKDirections(request: walkingRouteRequest)
        walkingRouteDirections.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if error != nil {
                println("TODO: \(error.localizedDescription)")
            } else if let routes = response.routes as? [MKRoute] {
                // We should only have one route since we didn't ask for alternate routes?
                //                println(routes.count)
                //                for route in routes {
                //                    println("Distance to \(item.name) is \(route.distance)")
                //                }
                var firstRoute = routes[0]
                var coords = MapSearchEngine.getWalkingPointsFromPolyLine(firstRoute.polyline)
                for i in 0..<coords.count {
                    println("\(coords[i].latitude) \(coords[i].longitude)")
                }
                callback(distance: firstRoute.distance)
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // Class functions
    // -------------------------------------------------------------------------
    
    class func getWalkingPointsFromPolyLine(polyline : MKPolyline) -> [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D]()
        
        var pointCount = polyline.pointCount
        var routeCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(pointCount * sizeof(CLLocationCoordinate2D))
        polyline.getCoordinates(routeCoordinates, range: NSMakeRange(0, pointCount))
        
        for i in 0..<pointCount {
            coords.append(routeCoordinates[i])
        }
        
        //TODO: free?
        return coords
    }
    
    class func calculateWalkingDistanceBetween(source : MKMapItem, destination : MKMapItem, callback : (distance: CLLocationDistance) -> Void) {
        var walkingRouteRequest = MKDirectionsRequest()
        walkingRouteRequest.transportType = MKDirectionsTransportType.Walking
        walkingRouteRequest.setSource(source)
        walkingRouteRequest.setDestination(destination)
        
        var walkingRouteDirections = MKDirections(request: walkingRouteRequest)
        walkingRouteDirections.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            if error != nil {
                println("TODO: \(error.localizedDescription)")
            } else if let routes = response.routes as? [MKRoute] {
                // We should only have one route since we didn't ask for alternate routes?
                var firstRoute = routes[0]
                var polyLine = firstRoute.polyline
                
                callback(distance: firstRoute.distance)
            }
        }
    }
}