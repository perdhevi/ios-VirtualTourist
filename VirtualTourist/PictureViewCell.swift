//
//  PictureViewCell.swift
//  VirtualTourist
//
//  Created by raditya perdhevi on 31/7/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import UIKit

class PictureViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pict: UIImageView!
    var flickPhoto : FlickrPhoto?
}
