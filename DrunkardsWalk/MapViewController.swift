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
        
        var nf = NSNumberFormatter()
        
        self.pubLabel.text = "\(nf.stringFromNumber(value)) Pubs"
        
    }
    
    @IBAction func crawlButtonPressed(sender: AnyObject) {
        println("\(self.mapView.region.center.latitude), \(self.mapView.region.center.longitude)")
        println("\(self.mapView.userLocation.coordinate.latitude), \(self.mapView.userLocation.coordinate.longitude)")
        
        //TODO: Checks for results and expands region radius if necessary
        self.googlePlaces.searchWithDelegate(self.mapView.region.center, radius: 1000, query: "bar")
        self.activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.activity!.startAnimating()
        self.activity!.center = self.mapView.center
        self.mapView.addSubview(self.activity!)
    }
    
    //MARK: GooglePlacesDelegate
    
    func googlePlacesSearchResult(items: [MKMapItem]) {
        
        //TODO: Send info to Random Walk Engine
        self.activity!.stopAnimating()
        self.activity!.removeFromSuperview()
        
//        for i in 0..<items.count {
//            println(items[i].name)
//        }
        
        var points = self.convertMapItemToCLLocation(items)
        
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.setUpOverlayView()
            self.animationEngine.points = points
            self.animationEngine.animatePathBetweenTwoPoints(points[0], destination: points[1])
        }


        
    }
    
    func setUpOverlayView() {
        var overlay = UIView(frame: CGRectMake(self.mapView.frame.origin.x, self.mapView.frame.origin.y, self.mapView.frame.width, self.mapView.frame.height))
        overlay.bounds = CGRect(x: self.mapView.frame.origin.x, y: self.mapView.frame.origin.y, width: self.mapView.frame.width, height: self.mapView.frame.height)
        overlay.clipsToBounds = true
        
        self.animationEngine = AnimationEngine(view: overlay)
        
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
        return self.mapView.convertCoordinate(coordinate, toPointToView: self.view)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

