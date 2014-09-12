//
//  ViewController.swift
//  DrunkardsWalk
//
//  Created by CCA on 9/5/14.
//  Copyright (c) 2014 CCA. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GooglePlacesDelegate {
                            
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pubLabel: UILabel!
    
    var googlePlaces = GooglePlaces()
    var locationManager : CLLocationManager!
    var activity : UIActivityIndicatorView?
    
    var animationEngine : AnimationEngine!
    
    var difference : CGFloat = 0.0
    
    var pubCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 5.0
        
        switch CLLocationManager.authorizationStatus() as CLAuthorizationStatus {
        case .Authorized:
            println("Authorized")
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true

        case .AuthorizedWhenInUse:
            println("Authorized when in use")
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true

        case .NotDetermined:
            println("Not determined")
            self.locationManager.requestAlwaysAuthorization()
        case .Restricted:
            println("Location services are restricted")
        case .Denied:
            println("Location services have been denied. Please go to settings to change this")
        }
        
        
        self.googlePlaces.delegate = self
        
        self.difference = self.view.frame.origin.y - self.mapView.frame.origin.y

        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .Authorized:
            println("User has authorized")
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        case .Denied:
            println("User has denied access")
        case .AuthorizedWhenInUse:
            println("Authorized when in use Changed")
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        default:
            println("Auth has changed")
        }
    }
    
    func setCurrentLocation() {
        if self.mapView.userLocation.location == nil { return }
        
        let lat = self.mapView.userLocation.location.coordinate.latitude
        let long = self.mapView.userLocation.location.coordinate.longitude
        self.flyToLocation(lat, long: long)
    }
    
    func flyToLocation(lat: Double, long: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let eyeCoordinate = CLLocationCoordinate2D(latitude: lat - 0.001, longitude: long)
        let camera = MKMapCamera(lookingAtCenterCoordinate: coordinate, fromEyeCoordinate: eyeCoordinate, eyeAltitude: 2000)
        self.mapView.setCamera(camera, animated: true)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let userLocation = locations[0] as CLLocation
        
        let lat = userLocation.coordinate.latitude
        let long = userLocation.coordinate.longitude
        
        let latDelta = 0.01
        let longDelta = 0.01
        let span = MKCoordinateSpanMake(latDelta, longDelta)
        
        let location = CLLocationCoordinate2DMake(lat, long)
        let region = MKCoordinateRegionMake(location, span)
        
        self.mapView.setRegion(region, animated: true)
    }

    @IBAction func stepperValueChanged(sender: UIStepper) {
        
        var value = sender.value
        self.pubCount = Int(value)
        var nf = NSNumberFormatter()
        
        self.pubLabel.text = "\(nf.stringFromNumber(value)) Pubs"
        
    }
    
    @IBAction func crawlButtonPressed(sender: AnyObject) {
        println("\(self.mapView.region.center.latitude), \(self.mapView.region.center.longitude)")
        println("\(self.mapView.userLocation.coordinate.latitude), \(self.mapView.userLocation.coordinate.longitude)")
        
        self.setRegion { () -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.googlePlaces.searchWithDelegate(self.mapView.region.center, radius: 1000, query: "bar")
                self.activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                self.activity!.startAnimating()
                self.activity!.center = self.mapView.center
                self.mapView.addSubview(self.activity!)

            })
            
        }
        
        //TODO: Checks for results and expands region radius if necessary
    }
    
    //MARK: GooglePlacesDelegate
    
    func googlePlacesSearchResult(items: [MKMapItem]) {
        var minToMaxLats = self.setLatBoundsForWalk(items)
        var minToMaxLongs = self.setLongBoundsForWalk(items)
        var distances = self.determineFurthestFromCenter(self.mapView.userLocation.coordinate, lats: minToMaxLats, longs: minToMaxLongs)
        
        //TODO: Send info to Random Walk Engine
        self.activity!.stopAnimating()
        self.activity!.removeFromSuperview()
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            var points = self.convertMapItemToCLLocation(items)
            let currentLocation = self.mapView.userLocation
            let currentCoord = currentLocation.coordinate
            let currentPoint = self.convertCLLocationCoordinate(currentCoord)
            points.insert(currentPoint, atIndex: 0)
            self.setUpOverlayView(points)
            self.animationEngine.animatePathBetweenTwoPoints(points[0], destination: points[1])
        }   
    }
    
    func setUpOverlayView(points: [CGPoint]) {
        var overlay = UIView(frame: CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.width, self.mapView.frame.height))
        overlay.bounds = CGRect(x: self.mapView.frame.origin.x, y: self.mapView.frame.origin.y, width: self.mapView.frame.width, height: self.mapView.frame.height)
        overlay.clipsToBounds = true
        
        self.animationEngine = AnimationEngine(view: overlay, points: points, difference: self.difference)
        
        self.view.addSubview(self.animationEngine.view)
    }
    
    func convertMapItemToCLLocation(mapItems: [MKMapItem]) -> [CGPoint] {
        var cgPoints = [CGPoint]()
        for i in 0..<mapItems.count {
            var item = mapItems[i] as MKMapItem
            var coord = item.placemark.coordinate
            var point = self.convertCLLocationCoordinate(coord)
            cgPoints.append(point)
        }
        return cgPoints
    }
        
    func convertCLLocationCoordinate(coordinate: CLLocationCoordinate2D) -> CGPoint {
        var point = self.mapView.convertCoordinate(coordinate, toPointToView: self.view)
        var yDiff = point.y + self.difference
        let newPoint = CGPointMake(point.x, yDiff)
        return newPoint
    }
    
    func setRegion(completion: () -> Void) {
        let lat = self.mapView.userLocation.coordinate.latitude
        let long = self.mapView.userLocation.coordinate.longitude
        
        let latDelta = 0.03
        let longDelta = 0.03
        let span = MKCoordinateSpanMake(latDelta, longDelta)
        
        let location = CLLocationCoordinate2DMake(lat, long)
        let region = MKCoordinateRegionMake(location, span)
        
        self.mapView.setRegion(region, animated: true)
        completion()
    }
    
    func setLatBoundsForWalk(mapItems: [MKMapItem]) -> ([MKMapItem]) {
        let lat  = self.mapView.userLocation.coordinate.latitude
        let long = self.mapView.userLocation.coordinate.longitude
        
        var items = mapItems
        
        for i in 0..<items.count {
        //sort and get min/max lat
            items.sort{$1.placemark.coordinate.latitude > $0.placemark.coordinate.latitude}
        }
        return [items.first!, items.last!]
    }
    
    func setLongBoundsForWalk(mapItems: [MKMapItem]) -> ([MKMapItem]) {
        let lat  = self.mapView.userLocation.coordinate.latitude
        let long = self.mapView.userLocation.coordinate.longitude
        
        var items = mapItems
        
        for i in 0..<items.count {
            //sort and get min/max lat
            items.sort{$1.placemark.coordinate.longitude > $0.placemark.coordinate.longitude}
        }

        return [items.first!, items.last!]
    }
    
    func determineFurthestFromCenter(center: CLLocationCoordinate2D, lats: [MKMapItem], longs: [MKMapItem]) {
        
        let distanceLatMin = abs(center.latitude - lats.first!.placemark.coordinate.latitude)
        let distanceLatMax = abs(center.latitude - lats.last!.placemark.coordinate.latitude)
        
        let distanceLongMin = abs(center.longitude - longs.first!.placemark.coordinate.longitude)
        let distanceLongMax = abs(center.longitude - longs.last!.placemark.coordinate.longitude)
        println("\(distanceLongMin)")
        println("\(distanceLongMax)")


        var finalLat = MKMapItem()
        var finalLong = MKMapItem()
        
        if distanceLatMin > distanceLatMax {
            finalLat = lats.first!
        } else {
            finalLat = lats.last!
        }
        
        if distanceLongMin > distanceLongMax {
            finalLong = longs.first!
        } else {
            finalLong = longs.last!
        }
        println("\(center.latitude), \(center.longitude)")
        println("\(lats.first?.placemark.coordinate.latitude), \(lats.first?.placemark.coordinate.longitude)")
        println("\(longs.first?.placemark.coordinate.latitude), \(longs.first?.placemark.coordinate.longitude)")
        println("\(lats.last?.placemark.coordinate.latitude), \(lats.last?.placemark.coordinate.longitude)")
        println("\(longs.last?.placemark.coordinate.latitude), \(longs.last?.placemark.coordinate.longitude)")
        println("\(finalLat.placemark.coordinate.latitude), \(finalLong.placemark.coordinate.longitude)")

        self.compareDistances(center, lat: finalLat, long: finalLong)
        
    }
    
    func compareDistances(center: CLLocationCoordinate2D, lat: MKMapItem, long: MKMapItem) -> (maxMax: CLLocationCoordinate2D, minMin: CLLocationCoordinate2D) {
        
        let distanceLat = abs(center.latitude - lat.placemark.coordinate.latitude)
        let distanceLong = abs(center.longitude - long.placemark.coordinate.longitude)
        
        let minLat = center.latitude - distanceLat
        let maxLat = center.latitude + distanceLat
        
        let minLong = center.longitude - distanceLong
        let maxLong = center.longitude + distanceLong
        
        let minCoord = CLLocationCoordinate2D(latitude: minLat, longitude: minLong)
        let maxCoord = CLLocationCoordinate2D(latitude: maxLat, longitude: maxLong)
        println("\(center.latitude), \(center.longitude)")
        println("\(minCoord.latitude), \(minCoord.longitude)")
        println("\(maxCoord.latitude), \(maxCoord.longitude)")

        
        return (minCoord, maxCoord)
    
        //Make square based on max dist from center
        //Add dist to lat/long and sub dist from center
        //take max lat/max long, min lat/min long
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

