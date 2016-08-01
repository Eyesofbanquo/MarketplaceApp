//
//  BookDetailViewController.swift
//  Marketplace
//
//  Created by Markim Shaw on 8/1/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import UIKit

class BookDetailViewController: UIViewController {
    
    //var searchResultsView:SearchResultsTableViewController!
    var selectedBook:Book!
    var bookTitle:String!
    //var selectedBook:Book!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchResultsView = (self.navigationController?.viewControllers[1] as? SearchResultsTableViewController)
        guard let searchResultsSize = searchResultsView?.searchResults.count else { return }
        for i in 0..<searchResultsSize {
            if searchResultsView?.searchResults[i]._title == bookTitle {
                self.selectedBook = searchResultsView?.searchResults[i]
            }
        }
        /*if let searchResultsSize = searchResultsView?.searchResults.count {
            for i in 0..<searchResultsSize {
                if searchResultsView?.searchResults[i]._title == bookTitle {
                    self.selectedBook = searchResultsView?.searchResults[i]
                }
            }
        }*/

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
