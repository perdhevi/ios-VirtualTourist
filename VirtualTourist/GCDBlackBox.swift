//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by raditya perdhevi on 15/8/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import Foundation


func performOnMainQueue(update : @escaping () -> Void){
    DispatchQueue.main.async {
        update()
    }
}
