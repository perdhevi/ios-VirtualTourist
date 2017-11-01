//
//  MapViewVC.swift
//  VirtualTourist
//
//  Created by raditya perdhevi on 31/7/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var lpgGesture: UILongPressGestureRecognizer!
    @IBOutlet weak var btnEdit: UIBarButtonItem!
    var selected : CLLocationCoordinate2D? = nil
    var deleteMode = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.addGestureRecognizer(lpgGesture)
        loadPin()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadPin(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "FlickrPin")
        do{
            let frResult = try stack.context.fetch(fr)
            for pin in frResult  {
                
                let loc = CLLocationCoordinate2D(latitude: (pin as! FlickrPin).latitude, longitude: (pin as! FlickrPin).longitude)
                addPin(pin: pin as! FlickrPin, loc: loc)
            }
        }catch{
            
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: false)
        
            if(view.annotation is FlickAnnotation) {
                let pin = (view.annotation as! FlickAnnotation).flickPin
                if(!deleteMode){
                    let controller = storyboard?.instantiateViewController(withIdentifier: "DetailMapVC") as! DetailMapVC
                    
                    controller.flickrPin = pin
                    
                    navigationController?.pushViewController(controller, animated: true)
                }else{
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    let stack = delegate.stack
                    
                    stack.context.delete(pin!)
                    stack.save()
                    
                    
                    mapView.removeAnnotation(view.annotation!)
                }
            }

    }
    

    
    @IBAction func btnDeleteMode(_ sender: Any) {
        deleteMode = !deleteMode
        if(deleteMode){
            title = "Deleting"
            btnEdit.title = "Done"
        }else{
            title = "Virtual Tourist"
            btnEdit.title = "Edit"
        }
    }
    
    
    func addPin(pin:FlickrPin, loc: CLLocationCoordinate2D){
        let annotation = FlickAnnotation()
        annotation.coordinate = loc
        annotation.title = "Pin"
        annotation.flickPin = pin
        print( "added \(loc)")
        mapView.addAnnotation(annotation)
        
        
    }
    
    @IBAction func actDropPin(_ sender: Any) {
        guard let gestureRecognizer = sender as? UILongPressGestureRecognizer else {
            return 
            
        }
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)

        
        if gestureRecognizer.state == .ended {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack

            
            var exists = false
            for annotate in mapView.annotations {
                if((newCoordinates.latitude == annotate.coordinate.latitude )&&(newCoordinates.longitude == annotate.coordinate.longitude )) {
                    exists = true
                }
            }
            if exists {
                print("already added")

                return
            }
            
            let pin = FlickrPin(latitude: (newCoordinates.latitude), longitude: (newCoordinates.longitude), context: stack.context)
                addPin(pin: pin, loc: newCoordinates)
            stack.save()
            let flickrClient = FlickrClient.sharedInstance()
            flickrClient.getImages(pin: pin,withPageNumber: -1,
                completionHandler: {(result, error) in
                
                })
            
        }
    }
    
/*
 // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        let detail = segue.destination as? DetailMapVC
        // Pass the selected object to the new view controller.
        if(detail != nil){
            //detail?.Lat = 0
            //detail?.Lon = 0
        }
    }
 */

}
