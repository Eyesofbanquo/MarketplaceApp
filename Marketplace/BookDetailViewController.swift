//
//  BookDetailViewController.swift
//  Marketplace
//
//  Created by Markim Shaw on 8/1/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class BookDetailViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var _bookImage: UIImageView!
    @IBOutlet weak var _mapView: MKMapView!
    //
    var selectedBook:Book!
    var bookTitle:String!
    var bookLocation:String!
    
    //Location properties
    var locationManager:CLLocationManager!
    var region:CLRegion!
    var locationString:String!
    var location:CLLocation!
    
    let geocoder:CLGeocoder = CLGeocoder()
    let regionRadius:CLLocationDistance = 1000
    var currentLocationSet:Bool = false
    var bookLocationSet:Bool = false
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Use the user's current location for the initial location for mapkit
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self._mapView.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        if self.bookLocation == "HPB Flagship" {
            self.bookLocation = "Northwest Hwy, Dallas, TX"
        }
        
        self.navigationController?.topViewController!.title = self.bookTitle
        
        
        
        //Load the previous view controller on the navigation stack to get the initial search information. Then use those images to populate the images on this view controller
        let searchResultsView = (self.navigationController?.viewControllers[1] as? SearchResultsTableViewController)
        guard let searchResultsSize = searchResultsView?.searchResults.count else { return }
        for i in 0..<searchResultsSize {
            if searchResultsView?.searchResults[i]._title == bookTitle {
                self.selectedBook = searchResultsView?.searchResults[i]
            }
        }
        
        
        
        self._bookImage.image = self.selectedBook.image
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.locationManager.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addToFavorites(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Book")
        let predicate = NSPredicate(format: "title = %@", self.selectedBook._title!)
        fetchRequest.predicate = predicate
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            if results.isEmpty {
                let entity = NSEntityDescription.entityForName("Book", inManagedObjectContext: managedContext)
                let book = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
                book.setValue(self.selectedBook._title!, forKey: "title")
                book.setValue(self.selectedBook._link!, forKey: "link")
                book.setValue(self.selectedBook._img!, forKey: "img")
                try managedContext.save()
                NSNotificationCenter.defaultCenter().postNotificationName("reloadTable", object: nil)
            } else {
                
            }
            //self.books = results as! [NSManagedObject]
        } catch {
            print(error)
        }
        
        
        
        
        
        /*do {
            try managedContext.save()
            NSNotificationCenter.defaultCenter().postNotificationName("reloadTable", object: nil)
        } catch {
            print(error)
        }*/
    }

}

extension BookDetailViewController: CLLocationManagerDelegate {
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
            placemarks, error in
            if (error != nil) {
                print(error)
            } else {
                guard let pmarks = placemarks else { return }
                
                if pmarks.count > 0 {
                    let pm = pmarks[0] as CLPlacemark
                    self.region = pm.region!
                    
                    self.location = pm.location!
                    //self.centerMapOnLocation(self.location)

                
                    if self.currentLocationSet == false {
                        
                        self.currentLocationSet = true
                        self.centerMapOnLocation(self.location)
                        
                        //Use MKLocalSearchRequest to find the location information from the provided location string for a given book
                        let request = MKLocalSearchRequest()
                        request.naturalLanguageQuery = "Half price books"
                        request.region = MKCoordinateRegion(center: self.location.coordinate, span: MKCoordinateSpan(latitudeDelta: self.regionRadius * 2.0, longitudeDelta: self.regionRadius * 2.0))
                        let search = MKLocalSearch(request: request)
                        
                        //Create a new marker for each item in the mapItems
                        search.startWithCompletionHandler({response,_ in
                            guard let response = response else { return }
                            for r in response.mapItems {
                                let marker = Marker(title: r.name!, subtitle: r.placemark.title!, phoneNumber: r.phoneNumber!, coordinate: r.placemark.coordinate)
                                self._mapView.addAnnotation(marker)
                            }
                        })
                    }
                    
                    
                }
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
    
    func centerMapOnLocation(location:CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, self.regionRadius * 2.0, self.regionRadius * 2.0)
        self._mapView.setRegion(coordinateRegion, animated: true)
    }
}

extension BookDetailViewController:MKMapViewDelegate{
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Marker {
            let identifier = "pin"
            var view:MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView{
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
                
            }
            var i = self.bookLocation.characters.startIndex
            i = i.advancedBy(3)
            if annotation.subtitle!.containsString(self.bookLocation.substringFromIndex(i)) {
                view.pinColor = MKPinAnnotationColor.Purple
            }
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let marker = view.annotation as! Marker
        let placename = marker.title!
        
        let ac = UIAlertController(title: placename, message: "Call to Reserve Book", preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "Call", style: .Default, handler: {
            action in
            var editedNumber = ""
            for (_,value) in marker.phoneNumber.characters.enumerate(){
                switch value {
                case "0","1","2","3","4","5","6","7","8","9":
                    editedNumber.append(value)
                    break
                default:
                    break
                }
            }
            
            if let url = NSURL(string: "tel://\(editedNumber)") {
                UIApplication.sharedApplication().openURL(url)
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
}
