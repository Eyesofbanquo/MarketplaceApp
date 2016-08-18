//
//  FavoritesTableViewController.swift
//  Marketplace
//
//  Created by Markim Shaw on 8/6/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {
    
    var books = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        //create fetch request
        let fetchRequest = NSFetchRequest(entityName: "Book")
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            self.books = results as! [NSManagedObject]
            self.tableView.reloadData()
        } catch {
            print(error)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.reloadTable), name: "reloadTable", object: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 225.0/255.0, green: 33.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        
    }
    
    func reloadTable(){
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated:Bool){
        super.viewWillAppear(animated)
        
        //Retrieve managedContext from appdelegate
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.books.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.reloadData()
    }

    /*
        Tags:
        1 = Title UILabel
        2 = ImageView
        3 = Button
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("favorites", forIndexPath: indexPath)
        
        let title = cell.viewWithTag(1) as! UILabel
        let image = cell.viewWithTag(2) as! UIImageView
        let removeButton = cell.viewWithTag(3) as! UIButton
        let book = self.books[indexPath.row]
        
        title.text = book.valueForKey("title") as? String
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let imageData = NSData(contentsOfURL: NSURL(string: book.valueForKey("img")! as! String)!)
            dispatch_async(dispatch_get_main_queue(), {
                image.image = UIImage(data: imageData!)
            })
            
        })
        
        removeButton.addTarget(self, action: #selector(self.removeEntry(_:)), forControlEvents: UIControlEvents.TouchUpInside)        
        
        return cell
    }
    
    func removeEntry(sender:AnyObject){
        let button = sender as! UIButton
        let cell = button.superview?.superview as! UITableViewCell
        let indexPath = self.tableView.indexPathForCell(cell)
        let book = self.books[indexPath!.row]
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        managedContext.deleteObject(book)
        self.books.removeAtIndex(indexPath!.row)
        do {
            try managedContext.save()
            self.tableView.reloadData()
        } catch {
            print(error)
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
