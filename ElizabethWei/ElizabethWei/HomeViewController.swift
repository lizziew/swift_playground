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
import MessageUI

class HomeViewController: UIViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var pins = [CKRecord]()
    
    var givenName: String? = nil
    
    var familyName: String? = nil
    
    var phoneNumber: String? = nil 
    
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
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            print("message canceled")
            
        case MessageComposeResultFailed.rawValue :
            print("message failed")
            
        case MessageComposeResultSent.rawValue :
            print("message sent")
            
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //location delegate methods
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
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
        
        let privateData = CKContainer.defaultContainer().privateCloudDatabase
        
        publicData.performQuery(query, inZoneWithID: nil) { (results: [CKRecord]?, error: NSError?) in
            if let publicCloudPins = results {
                self.pins = publicCloudPins
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    //LOOP THROUGH PUBLIC PINS
                    for publicPin in publicCloudPins {
                        //LOOP THROUGH PRIVATE PINS
                        privateData.performQuery(query, inZoneWithID: nil) { (results: [CKRecord]?, error: NSError?) in
                            if let privateCloudPins = results {
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    for privatePin in privateCloudPins {
                                        var distresult = false
                                        var date1result = false
                                        var date2result = false
                                        
                                        //check if pins are within 50 miles
                                        let privatePinLocation = (privatePin["location"] as? CLLocation)!
                                        let publicPinLocation = (publicPin["location"] as? CLLocation)!
                                        let distance = privatePinLocation.distanceFromLocation(publicPinLocation)
                                        if distance < 80000 {
                                            distresult = true
                                        }
                                        
                                        //check date range
                                        let publicPinStartDate = (publicPin["startDate"] as? NSDate)!
                                        let publicPinEndDate = (publicPin["endDate"] as? NSDate)!
                                        
                                        let privatePinStartDate = (privatePin["startDate"] as? NSDate)!
                                        let privatePinEndDate = (privatePin["endDate"] as? NSDate)!
                                        
                                        //check if private pin start date <= public pin start date <= private pin end date
                                        if (privatePinStartDate.compare(publicPinStartDate) == NSComparisonResult.OrderedAscending || privatePinStartDate.compare(publicPinStartDate) == NSComparisonResult.OrderedSame) &&
                                            (publicPinStartDate.compare(privatePinEndDate) == NSComparisonResult.OrderedAscending || publicPinStartDate.compare(privatePinEndDate) == NSComparisonResult.OrderedSame) {
                                            date1result = true
                                        }
                                        
                                        //check if public pin start date <= private pin start date <= public pin end date
                                        if (publicPinStartDate.compare(privatePinStartDate) == NSComparisonResult.OrderedAscending || publicPinStartDate.compare(privatePinStartDate) == NSComparisonResult.OrderedSame) &&
                                            (privatePinStartDate.compare(publicPinEndDate) == NSComparisonResult.OrderedAscending || privatePinStartDate.compare(publicPinEndDate) == NSComparisonResult.OrderedSame){
                                            date2result = true
                                        }
                                        
                                        if distresult && (date1result || date2result) && (publicPin["givenName"] as? String)! != self.givenName! && (publicPin["familyName"] as? String)! != self.familyName!  {
                                            let displayPin = CustomPin(title: (publicPin["givenName"] as? String)! + " " + (publicPin["familyName"] as? String)!, name: (publicPin["name"] as? String)!, phoneNumber: self.phoneNumber!, coordinate: (publicPin["location"] as? CLLocation)!.coordinate)
                                            self.map.addAnnotation(displayPin)
                                        }
                                    }
                                })
                            }
                        }
                    }
                })
            }
        }
    }
}

extension HomeViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? CustomPin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alert = UIAlertController(title: "Send a text message!", message: "Ask " + view.annotation!.title!! + " to meet up!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Send SMS", style: UIAlertActionStyle.Default) { (action) in
            let messageVC = MFMessageComposeViewController()
            
            messageVC.body = "Hi I heard you were also going to be in " + view.annotation!.subtitle!! + " - let's meet up!"
            messageVC.recipients = [self.phoneNumber!]
            messageVC.messageComposeDelegate = self
            
            self.presentViewController(messageVC, animated: false, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
