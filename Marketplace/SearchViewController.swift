//
//  SearchViewController.swift
//  Marketplace
//
//  Created by Markim Shaw on 7/25/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

/* Notes of importance:
 
 1) When the search button is pressed the only action called in this file is to begin the segue to the SearchResultsTableViewController. That controller hanldes the API calls. This controller is specifically for getting the text information from _searchTextField
 */

import UIKit
import CoreLocation

class SearchViewController: UIViewController, CLLocationManagerDelegate {
    
    //MARK: - UI Elements prefaced with _
    @IBOutlet weak var _searchTextField: UITextField!
    
    @IBOutlet weak var _bottomConstraint: NSLayoutConstraint!
    
    //MARK: - Class Elements in camelCase
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Marketplace"
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //locationManager.requestWhenInUseAuthorization()
        //locationManager.startUpdatingLocation()
    
        // Do any additional setup after loading the view.
        
        /*NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)*/
    }
    
    /*func keyboardWillShow(notification: NSNotification) {
        //To retrieve keyboard size, uncomment following line
        //let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        self._bottomConstraint.constant = 260
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        //To retrieve keyboard size, uncomment following line
        //let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue()
        self._bottomConstraint.constant = 175
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
        }
    }*/
    
    
    func dismissKeyboard(){
        self._searchTextField.endEditing(true)

    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        self.navigationController?.navigationBar.barTintColor = UIColor(red: 225.0/255.0, green: 33.0/255.0, blue: 55.0/255.0, alpha: 1.0)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {placemarks,errors in
            if placemarks!.count > 0 {
                let pm = placemarks![0] as CLPlacemark
                self.getLocationInformation(pm)
            }
        })
    }
    
    func getLocationInformation(placemark: CLPlacemark?){
        if placemark != nil {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            //print(placemark!.locality!)
            //print(placemark!.postalCode!)
            print(placemark!.administrativeArea!) // State information
            //print(placemark!.country!)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error while updating location " + error.localizedDescription)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to_SearchResultsTableViewController" {
            if let searchText = self._searchTextField.text {
                let destinationViewController = segue.destinationViewController as! SearchResultsTableViewController
                destinationViewController.searchText = searchText
            }
        }
    }
    
    @IBAction func unwindFromSearchView(segue:UIStoryboardSegue){
        self._searchTextField.text = ""
    }
    

}
