//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by raditya perdhevi on 1/8/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient : BasicNetworkClient {
    
    //
    //var totalPage = -1
    //var withPageNumber = 1
    func taskForImage(URL url:URL, completionHandler: @escaping (_ result : AnyObject?, _ error :NSError?) -> Void){
        let request = NSMutableURLRequest(url:url)
        
        let task = session.dataTask(with: request as URLRequest) { ( data, response, error) in
            let noError = self.checkError(data: data as NSData?, response: response as URLResponse?, error: error as NSError?, completionHandler: completionHandler)
            if(!noError){
                return
            }
            if let ImageData = data {
                completionHandler(ImageData as AnyObject, nil)
            }
        }
        
        
        task.resume()
    }
    
    public func getImages(pin:FlickrPin, withPageNumber : Int,
        completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void
        
        ){
        func bboxString(latitude : Double , longitude : Double) -> String {
            let latCenter = latitude
            let minLat = max(latCenter - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maxLat = min(latCenter + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            let lonCenter = longitude
            let minLon = max(lonCenter - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let maxLon = min(lonCenter + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLonRange.1)
            
            
            return String(minLon) + "," + String(minLat) + "," + String(maxLon) + "," + String(maxLat)
        }
        
        let methodParameters: [String: AnyObject] = [
            Constants.FlickrParameterKeys.SafeSearch:Constants.FlickrParameterValues.UseSafeSearch as AnyObject,
            Constants.FlickrParameterKeys.Extras:Constants.FlickrParameterValues.MediumURL as AnyObject,
            Constants.FlickrParameterKeys.BoundingBox:bboxString(latitude: pin.latitude, longitude: pin.longitude) as AnyObject,
            Constants.FlickrParameterKeys.APIKey:Constants.FlickrParameterValues.APIKey as AnyObject,
            Constants.FlickrParameterKeys.Method:Constants.FlickrParameterValues.SearchMethod as AnyObject,
            Constants.FlickrParameterKeys.Format:Constants.FlickrParameterValues.ResponseFormat as AnyObject,
            Constants.FlickrParameterKeys.NoJSONCallback:Constants.FlickrParameterValues.DisableJSONCallback as AnyObject,
            Constants.FlickrParameterKeys.perPage:Constants.FlickrParameterValues.perPage as AnyObject
        ]
        
        var methodParamWithPageNumber = methodParameters
        if(withPageNumber != -1){
            
            methodParamWithPageNumber[Constants.FlickrParameterKeys.Page] = withPageNumber as AnyObject?
        }
        
        let url = URLFromParameters(methodParamWithPageNumber)
        let request = URLRequest(url:url)
        print("\(url)")
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if(error == nil){
                
                func displayError(message:String){
                    print(message)
                }
                
                if let data = data {
                    let parsedResult : [String:AnyObject]
                    do {
                        parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                    }catch{
                        return
                    }
                    //print("\(parsedResult)")
                    guard let photoDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                        displayError(message: "error getting photos")
                        return
                    }
                    if(withPageNumber == -1){
                        let totalPage = min(photoDictionary[Constants.FlickrResponseKeys.Pages] as! Int,267)
                        
                        let pageNum = Int(arc4random_uniform(UInt32(totalPage)))
                        print("getting page \(pageNum)")
                        performOnMainQueue{
                            self.getImages(pin: pin, withPageNumber: pageNum ,
                                           completionHandler: completionHandler)
                        }
                        
                        return
                        
                    }
                    
                    var container : [FlickrPhoto] = [FlickrPhoto]()
                    
                    if let photoArray = photoDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {
                        print("photoArray : \(photoArray)")
                        //var photoURLs = [String]()
                        for photo in photoArray {
                            let photoDict = photo as [String:AnyObject]
                            
                            if let imageURLString = photoDict[Constants.FlickrResponseKeys.MediumURL] as? String,let photoTitle = photoDict[Constants.FlickrResponseKeys.Title] as? String {
                                //print("imageURLString : \(imageURLString)")
                                
                                
                                performOnMainQueue {
                                    let delegate = UIApplication.shared.delegate as! AppDelegate
                                    let stack = delegate.stack
                                    let flick : FlickrPhoto = FlickrPhoto(data: nil , text: photoTitle, url:imageURLString, pin: pin, context: stack.context)
                                    //stack.save()
                                    container.append(flick)
                                    let photoURL = URL(string:flick.url!)
                                    //print("flick saved : \(String(describing: photoURL?.absoluteString))")
                                    self.taskForImage(URL: photoURL!, completionHandler: {(data , error) in
                                        performOnMainQueue {
                                            if(data != nil) {
                                                let delegate = UIApplication.shared.delegate as! AppDelegate
                                                let stack = delegate.stack
                                                flick.picture = data as? NSData
                                                stack.save()
                                                //print("photo saved : \(String(describing: photoURL?.absoluteString))")
                                            }
                                        }
                                    })
                                }
                            }
                        }
                        completionHandler(container as AnyObject, nil)
                    }
                    
                    
                }
            }
        }
            
        )
        task.resume()
        
        
    }
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        
        return Singleton.sharedInstance
    }

}
