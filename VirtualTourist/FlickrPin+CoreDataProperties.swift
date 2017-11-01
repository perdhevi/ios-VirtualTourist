//
//  FlickrPin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by raditya perdhevi on 7/8/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import Foundation
import CoreData


extension FlickrPin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlickrPin> {
        return NSFetchRequest<FlickrPin>(entityName: "FlickrPin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var pin2pic: NSSet?

}

// MARK: Generated accessors for pin2pic
extension FlickrPin {

    @objc(addPin2picObject:)
    @NSManaged public func addToPin2pic(_ value: FlickrPhoto)

    @objc(removePin2picObject:)
    @NSManaged public func removeFromPin2pic(_ value: FlickrPhoto)

    @objc(addPin2pic:)
    @NSManaged public func addToPin2pic(_ values: NSSet)

    @objc(removePin2pic:)
    @NSManaged public func removeFromPin2pic(_ values: NSSet)

}
