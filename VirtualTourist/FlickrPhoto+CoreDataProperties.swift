//
//  FlickrPhoto+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by raditya perdhevi on 14/8/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import Foundation
import CoreData


extension FlickrPhoto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlickrPhoto> {
        return NSFetchRequest<FlickrPhoto>(entityName: "FlickrPhoto")
    }

    @NSManaged public var picture: NSData?
    @NSManaged public var text: String?
    @NSManaged public var url: String?
    @NSManaged public var pic2pin: FlickrPin?

}
