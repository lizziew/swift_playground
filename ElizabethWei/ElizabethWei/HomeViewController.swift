//
//  HomeViewController.swift
//  ElizabethWei
//
//  Created by Elizabeth Wei on 4/22/16.
//  Copyright © 2016 Elizabeth Wei. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CloudKit

class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var pins = [CKRecord]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //fix bounds of map
        var bounds = self.view.bounds
        bounds.size.height -= self.tabBarController!.tabBar.frame.height
        self.map.frame = bounds

        //set up location manager
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.map.showsUserLocation = true
        
        self.map.delegate = self
        
        //load pins
        loadPins()
        
        //icloud
        iCloudUserIDAsync() {
            recordID, error in
            if let userID = recordID?.recordName {
                print("received iCloudID \(userID)")
            } else {
                print("Fetched iCloudID was nil")
                let alert = UIAlertController(title: "Welcome", message: "Please sign into iCloud", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        loadPins()
        
        iCloudUserIDAsync() {
            recordID, error in
            if let userID = recordID?.recordName {
                print("received iCloudID \(userID)")
            } else {
                print("Fetched iCloudID was nil")
                let alert = UIAlertController(title: "Welcome", message: "Please sign into iCloud", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func iCloudUserIDAsync(complete: (instance: CKRecordID?, error: NSError?) -> ()) {
        let container = CKContainer.defaultContainer()
        container.fetchUserRecordIDWithCompletionHandler() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
                complete(instance: nil, error: error)
            } else {
                print("fetched ID \(recordID?.recordName)")
                complete(instance: recordID, error: nil)
            }
        }
    }
    
    //location delegate methods 
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        
        self.map.setRegion(region, animated: true)
        
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    func loadPins() {
        let publicData = CKContainer.defaultContainer().publicCloudDatabase
        let query = CKQuery(recordType: "Pin", predicate: NSPredicate(format: "TRUEPREDICATE", argumentArray: nil))
        
        map.removeAnnotations(map.annotations)
        
        publicData.performQuery(query, inZoneWithID: nil) { (results: [CKRecord]?, error: NSError?) in
            if let cloudPins = results {
                self.pins = cloudPins
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    for p in cloudPins {
                        let displayPin = MKPointAnnotation()
                        displayPin.coordinate = (p["location"] as? CLLocation)!.coordinate
                        displayPin.title = (p["name"] as? String)!
                        self.map.addAnnotation(displayPin)
                    }
                })
            }
        }
    }
}
