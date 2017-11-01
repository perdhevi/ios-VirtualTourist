//
//  BasicNetwork.swift
//  OnTheMap
//
//  Created by raditya perdhevi on 18/7/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import Foundation


public class BasicNetworkClient : NSObject {
    var session = URLSession.shared
    

    
    func taskForGETMethod(_ method: String, parameters: [String:AnyObject], skipByteResult : Int, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        let parametersWithApiKey = parameters
        
        
        /* 2/3. Build the URL, Configure the request */
        let request = generateRequest(method: method, parameters: parametersWithApiKey)
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let noError = self.checkError(data: data as NSData?, response: response as URLResponse?, error: error as NSError?, completionHandler: completionHandlerForGET)
            if(!noError){
                return
            }
            
            let range = Range(skipByteResult..<(data?.count)!)
            let newData = data?.subdata(in: range) /* subset response data! */
            
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    public func checkError(data: NSData?, response :URLResponse?, error : NSError?, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> Bool{
        func sendError(_ error : NSError?) {
            completionHandler(nil, error)//NSError(domain: "taskForPostMethod", code: code, userInfo: userInfo))
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            sendError(error)//(error! as NSError).code ,error)//(error! as NSError).localizedDescription)
            return false
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            let resp = (response as? HTTPURLResponse)
            sendError(NSError(domain: "webservice", code: (resp?.statusCode)!, userInfo: [NSLocalizedDescriptionKey :resp?.description ?? "No Response from website" ]))
            return false
        }
        
        /* GUARD: Was there any data returned? */
        guard data != nil else {
            sendError(NSError(domain: "data", code: -1, userInfo: [NSLocalizedDescriptionKey : "No Data Returned"]))
            return false
        }
        
        return true
    }
    
    public func generateRequest(method: String,parameters: [String:AnyObject]) -> NSMutableURLRequest{
        return NSMutableURLRequest(url: URLFromParameters(parameters, withPathExtension: method))
    }
    
    public func URLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath + (withPathExtension ?? "")
        if(parameters.count > 0 ){
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }

    public func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    
    
}
