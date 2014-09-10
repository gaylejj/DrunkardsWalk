//
//  Uber.swift
//  DW
//
//  Created by Kirby Shabaga on 9/9/14.
//  Copyright (c) 2014 Worxly. All rights reserved.
//
// Ref: https://developer.uber.com/v1/deep-linking/
//

import CoreLocation
import Foundation
import UIKit

class Uber {
    
    // required property
    var pickupLocation : CLLocationCoordinate2D!
    
    // optional properties
    var pickupNickname : String?
    var pickupFormattedAddress : String?
    
    var dropoffLocation : CLLocationCoordinate2D?
    var dropoffNickname : String?
    var dropoffFormattedAddress : String?
    
    // -------------------------------------------------------------------
    // init with required property
    // -------------------------------------------------------------------
    init(pickupLocation : CLLocationCoordinate2D) {
        self.pickupLocation = pickupLocation
    }
    
    // -------------------------------------------------------------------
    // perform a deep link to the Uber App if installed
    // check all optional properties while construcing the URL
    // -------------------------------------------------------------------
    func deepLink() {
        if let uberURL = self.constructURL() {
            var sharedApp = UIApplication.sharedApplication()
            println(uberURL)
            sharedApp.openURL(uberURL)
        }
    }
    
    private func constructURL() -> NSURL? {
        
        let uberProtocol = "uber://"
        let httpsProtocol = "https://m.uber.com/"
        
        var uberString = Uber.isUberAppInstalled() ? uberProtocol : httpsProtocol
        uberString += "?action=setPickup"
        uberString += "&pickup[latitude]=\(self.pickupLocation.latitude)"
        uberString += "&pickup[longitude]=\(self.pickupLocation.longitude)"
        
        // uber://?action=setPickup&pickup[latitude]=37.775818&pickup[longitude]=-122.418028&pickup[nickname]=UberHQ&pickup[formatted_address]=1455%20Market%20St%2C%20San%20Francisco%2C%20CA%2094103&dropoff[latitude]=37.802374&dropoff[longitude]=-122.405818&dropoff[nickname]=Coit%20Tower&dropoff[formatted_address]=1%20Telegraph%20Hill%20Blvd%2C%20San%20Francisco%2C%20CA%2094133&product_id=a1111c8c-c720-46c3-8534-2fcdd730040d
        
        uberString += self.pickupNickname == nil ? "" :
        "&pickup[nickname]=\(self.pickupNickname!)"
        
        uberString += self.pickupFormattedAddress == nil ? "" :
        "&pickup[formatted_address]=\(self.pickupFormattedAddress!)"
        
        if self.dropoffLocation != nil {
            uberString += "&dropoff[latitude]=\(self.dropoffLocation!.latitude)"
            uberString += "&dropoff[longitude]=\(self.dropoffLocation!.longitude)"
        }
        
        uberString += self.dropoffNickname == nil ? "" :
        "&dropoff[nickname]=\(self.dropoffNickname!)"
        
        uberString += self.dropoffFormattedAddress == nil ? "" :
        "&dropoff[formatted_address]=\(self.dropoffFormattedAddress!)"
        
        if let urlEncodedString = uberString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            return NSURL(string: urlEncodedString)
        } else {
            return nil
        }
    }
    
    // -------------------------------------------------------------------
    // check if the Uber App is installed on the device
    // -------------------------------------------------------------------
    class func isUberAppInstalled() -> Bool {
        var sharedApp = UIApplication.sharedApplication()
        let uberProtocol = NSURL(string: "uber://")
        
        return sharedApp.canOpenURL(uberProtocol)
    }

}
