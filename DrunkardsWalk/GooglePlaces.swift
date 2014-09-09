//
//  GooglePlaces.swift
//  DW
//
//  Created by Kirby Shabaga on 9/8/14.
//  Copyright (c) 2014 Worxly. All rights reserved.
//

// ------------------------------------------------------------------------------------------
// Ref: https://developers.google.com/places/documentation/search#PlaceSearchRequests
//
// Example search
//
// https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=500&types=food&name=cruise&key=AddYourOwnKeyHere
//
// required parameters: key, location, radius
// ------------------------------------------------------------------------------------------

import CoreLocation
import Foundation
import MapKit

protocol GooglePlacesDelegate {
    
    func googlePlacesSearchResult([MKMapItem])
    
}

class GooglePlaces {
    
    let URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
    let LOCATION = "location="
    let RADIUS = "radius="
    var KEY = "key="
    
    var delegate : GooglePlacesDelegate? = nil
    
    // ------------------------------------------------------------------------------------------
    // init requires google.plist with key "places-key"
    // ------------------------------------------------------------------------------------------

    init() {
        var path = NSBundle.mainBundle().pathForResource("google", ofType: "plist")
        var google = NSDictionary(contentsOfFile: path!)
        if let apiKey = google["places-key"] as? String {
            self.KEY = "\(self.KEY)\(apiKey)"
        } else {
            // TODO: Exception handling
            println("Exception: places-key is not set in google.plist")
        }
    }
    
    // ------------------------------------------------------------------------------------------
    // Google Places search with callback
    // ------------------------------------------------------------------------------------------

    func search(
        location : CLLocationCoordinate2D,
        radius : Int,
        query : String,
        callback : (items : [MKMapItem]?, errorDescription : String?) -> Void) {
        
        var urlEncodedQuery = query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var urlString = "\(URL)\(LOCATION)\(location.latitude),\(location.longitude)&\(RADIUS)\(radius)&\(KEY)&name=\(urlEncodedQuery!)"
            
        var url = NSURL(string: urlString)
        var session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        session.dataTaskWithURL(url, completionHandler: { (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void in
            
            if error != nil {
                callback(items: nil, errorDescription: error.localizedDescription)
            }
            
            if let statusCode = response as? NSHTTPURLResponse {
                if statusCode.statusCode != 200 {
                    callback(items: nil, errorDescription: "Could not continue.  HTTP Status Code was \(statusCode)")
                }
            }
            
            callback(items: GooglePlaces.parseFromData(data), errorDescription: nil)
            
        }).resume()
        
    }
    
    
    // ------------------------------------------------------------------------------------------
    // Google Places search with delegate
    // ------------------------------------------------------------------------------------------
    
    func searchWithDelegate(
        location : CLLocationCoordinate2D,
        radius : Int,
        query : String) {
            
            self.search(location, radius: radius, query: query) { (items, errorDescription) -> Void in
                if self.delegate != nil {
                    self.delegate!.googlePlacesSearchResult(items!)
                }
            }
            
    }
    
    // ------------------------------------------------------------------------------------------
    // Parse JSON into array of MKMapItem
    // ------------------------------------------------------------------------------------------

    class func parseFromData(data : NSData) -> [MKMapItem] {
        var mapItems = [MKMapItem]()
        
        var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        var results = json["results"] as? Array<NSDictionary>
        println("results = \(results!.count)")

        for result in results! {

            var name = result["name"] as String
            
            var coordinate : CLLocationCoordinate2D!
            
            if let geometry = result["geometry"] as? NSDictionary {
                if let location = geometry["location"] as? NSDictionary {
                    var lat = location["lat"] as CLLocationDegrees
                    var long = location["lng"] as CLLocationDegrees
                    coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    var placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
                    var mapItem = MKMapItem(placemark: placemark)
                    mapItem.name = name
                    mapItems.append(mapItem)
                }
            }
        }
        
        return mapItems
    }
    
}