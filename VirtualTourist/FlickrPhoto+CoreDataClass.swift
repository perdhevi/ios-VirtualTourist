//
//  FlickrPhoto+CoreDataClass.swift
//  VirtualTourist
//
//  Created by raditya perdhevi on 7/8/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import Foundation
import CoreData

@objc(FlickrPhoto)
public class FlickrPhoto: NSManagedObject {
    convenience init(data : NSData?, text : String, url: String, pin:FlickrPin, context: NSManagedObjectContext) {
        if let en = NSEntityDescription.entity(forEntityName: "FlickrPhoto", in: context){
            self.init(entity: en, insertInto: context)
            self.picture = data
            self.text = text
            self.url = url
            self.pic2pin = pin
        } else {
            fatalError("unable to find Entity Name")
        }
        
        
    }
}
