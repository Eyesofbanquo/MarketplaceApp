//
//  BookDetailViewController.swift
//  Marketplace
//
//  Created by Markim Shaw on 8/1/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import UIKit
import MapKit

class BookDetailViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var _bookImage: UIImageView!
    
    //
    var selectedBook:Book!
    var bookTitle:String!
    var locationManager:CLLocationManager!
    var location:CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Use the user's current location for the initial location for mapkit
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        self.navigationController?.topViewController!.title = self.bookTitle
        
        let searchResultsView = (self.navigationController?.viewControllers[1] as? SearchResultsTableViewController)
        guard let searchResultsSize = searchResultsView?.searchResults.count else { return }
        for i in 0..<searchResultsSize {
            if searchResultsView?.searchResults[i]._title == bookTitle {
                self.selectedBook = searchResultsView?.searchResults[i]
            }
        }
        
        self._bookImage.image = self.selectedBook.Image()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
                    self.location = pm.location!
                }
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
    }
}
