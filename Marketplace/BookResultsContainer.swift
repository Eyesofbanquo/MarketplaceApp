//
//  BookResultsContainer.swift
//  Marketplace
//
//  Created by Markim Shaw on 7/28/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import UIKit

class BookResultsContainer: UIViewController {
    @IBOutlet weak var _unavailableView: UIView!

    @IBOutlet weak var _bookTypeSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var _loadingView: UIView!
    @IBOutlet weak var _unavailableText: UILabel!
    var bookLink:String!
    var bookTitle:String!
    var bookType:String = "hardcover"
    var bookResultsTableViewController:BookResultsTableViewController!
    var indicator:UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.bookTitle
        
        self.indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.indicator.center = self.view.center
        self.indicator.hidesWhenStopped = true
        self.view.addSubview(self.indicator)
        self.indicator.startAnimating()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        /*if self.bookResultsTableViewController != nil {
            self.bookResultsTableViewController.tableView.reloadData()
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "to_BookResultsTableViewController"{
            self.bookResultsTableViewController = segue.destinationViewController as! BookResultsTableViewController
            self.bookResultsTableViewController.bookLink = self.bookLink
            self.bookResultsTableViewController.bookTitle = self.bookTitle
            
            let app_delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            self.bookResultsTableViewController.device_token = app_delegate.deviceToken!
            
            self.bookResultsTableViewController.postSearchData("hardcover", currentPage: 0)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.checkAvailability), name: "availability", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.stopAnimatingIndicatorView), name: "stopAnimatingIndicatorView", object: nil)
            
            self.bookResultsTableViewController._bookTypeSegmentedControl = self._bookTypeSegmentedControl  
            }
    }
    
    func stopAnimatingIndicatorView(){
        self.indicator.stopAnimating()
    }
    
    func checkAvailability(){
        if self.bookResultsTableViewController.unavailable == true {
            self._unavailableView.hidden = false
            self._loadingView.hidden = true
            self._unavailableText.text = "\(self.bookResultsTableViewController.bookType) unavailable"
        }else {
            self._unavailableView.hidden = true
        }
    }

}

extension BookResultsContainer {
    
    @IBAction func refreshTable(sender: AnyObject) {
        self.bookResultsTableViewController._hpbSelectSwitch.on = false

        switch (sender as! UISegmentedControl).selectedSegmentIndex {
        case 0:
            if self.bookResultsTableViewController.hardcoverSearchResults.count == 0 {
                //self._loadingView.hidden = false
                self.bookResultsTableViewController.bookType = "hardcover"
                if self.bookResultsTableViewController.searching == false {
                    self.indicator.startAnimating()
                    self.bookResultsTableViewController.searching = true
                    self.bookResultsTableViewController.postSearchData("hardcover", currentPage: self.bookResultsTableViewController.currentPageHardcover)
                }
                
                self.bookResultsTableViewController.tableView.reloadData()

                
            } else {
                self._unavailableView.hidden = true
            }
            self.bookResultsTableViewController.tableView.reloadData()
            break
        case 1:
            if self.bookResultsTableViewController.paperbackSearchResults.count == 0 {
                //self.bookResultsTableViewController.searching = false
                self.bookResultsTableViewController.bookType = "paperback"
                if self.bookResultsTableViewController.searching == false {
                    self.indicator.startAnimating()
                    self.bookResultsTableViewController.searching = true
                    self.bookResultsTableViewController.postSearchData("paperback", currentPage: 0)
                }
                
                self.bookResultsTableViewController.tableView.reloadData()

            } else {
                self._unavailableView.hidden = true
            }
            self.bookResultsTableViewController.tableView.reloadData()
            break
        default:
            break
        }
    }
    
}
