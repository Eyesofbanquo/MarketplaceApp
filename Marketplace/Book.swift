//
//  Book.swift
//  Marketplace
//
//  Created by Markim Shaw on 7/26/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import Foundation
import UIKit


class Book {
    var _link:String?
    var _title:String?
    var _img:String?
    var _price:String?
    var _condition:String?
    var _location:String?
    var _seller:String?
    
    var image:UIImage?
    
    init(title:String, link:String, img:String){
        self._title = title
        self._link = link
        self._img = img
    }
    
    
    //This init is for the BookResultsView
    init(seller:String, price:String, location:String){
        self._seller = seller
        self._price = price
        self._location = location
    }
    
}