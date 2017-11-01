//
//  FlickrPin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by raditya perdhevi on 7/8/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import Foundation
import CoreData

@objc(FlickrPin)
public class FlickrPin: NSManagedObject {

    convenience init(latitude : Double, longitude : Double, context: NSManagedObjectContext) {
        if let en = NSEntityDescription.entity(forEntityName: "FlickrPin", in: context){
            self.init(entity: en, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("unable to find Entity Name")
        }
        
        
    }

}
