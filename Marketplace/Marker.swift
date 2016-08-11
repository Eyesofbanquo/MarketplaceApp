//
//  Marker.swift
//  Marketplace
//
//  Created by Markim Shaw on 8/5/16.
//  Copyright © 2016 Markim Shaw. All rights reserved.
//

import Foundation
import MapKit

class Marker:NSObject, MKAnnotation {
    
    let title:String?
    let subtitle:String?
    let phoneNumber:String
    let coordinate: CLLocationCoordinate2D
    
    init(title:String, subtitle:String, phoneNumber:String, coordinate:CLLocationCoordinate2D){
        self.title = title
        self.subtitle = subtitle
        self.phoneNumber = phoneNumber
        self.coordinate = coordinate
        
        super.init()
    }
    
    
    
    
}