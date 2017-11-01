//
//  DetailMapVC.swift
//  VirtualTourist
//
//  Created by raditya perdhevi on 31/7/17.
//  Copyright © 2017 raditya perdhevi. All rights reserved.
//

import UIKit
import MapKit
import CoreData

private let reuseIdentifier = "Cell"

class DetailMapVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,
NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var buttonReload: UIButton!
    
    var selectedIndex : [IndexPath] = [IndexPath]()
    
    var loaded : Bool = false
    var flickrPin : FlickrPin? = nil
    var location : CLLocationCoordinate2D? = nil
    let flickrClient : FlickrClient = FlickrClient.sharedInstance()
    
    var deletedIndexPath : [IndexPath]!
    var updatedIndexPath : [IndexPath]!
    var insertedIndexPath : [IndexPath]!
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
        didSet {
            fetchedResultsController?.delegate = self
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = false
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(flickrPin != nil){
            let annotation = MKPointAnnotation()
            location = CLLocationCoordinate2D(latitude: (flickrPin?.latitude)!, longitude: (flickrPin?.longitude)!)
            
            
            annotation.coordinate = location!
            annotation.title = "Pin"
            
            map.addAnnotation(annotation)
            
            map.centerCoordinate = location!
            let region : MKCoordinateRegion = self.map.regionThatFits(MKCoordinateRegionMakeWithDistance(location!, 500,500))
            map.setRegion(region, animated: true)
            loadImages()
            
        }

    }
    
    @IBAction func reloadData(_ sender: Any) {
        if(selectedIndex.count == 0){
            print("reloading")
            clearSavedImage()
            print("images count \(String(describing: fetchedResultsController?.fetchedObjects?.count))")
            loadFromFlick()
        }else{
            var objectToDelete  = [FlickrPhoto]()
            for indexPath in selectedIndex {
               objectToDelete.append(fetchedResultsController?.object(at: indexPath) as! FlickrPhoto)
                
            }
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack

            for photo in objectToDelete {
                stack.context.delete(photo)
            }
            
            selectedIndex = [IndexPath]()
        }
        buttonReload.setTitle( "New Collection", for: .normal)
        
    }
    
    func loadFromFlick(){
        
        flickrClient.getImages(pin: flickrPin!, withPageNumber:  -1,
            completionHandler: {(result, error) in
                performOnMainQueue {
                    self.loadImages()
                    self.self.loaded = true
                    self.collectionView.reloadData()
                    self.indicator.stopAnimating()
                    
                }
            })
        
    }
    
    func clearSavedImage(){
        print("clear image")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        
        for photo in fetchedResultsController?.fetchedObjects as! [FlickrPhoto]{
            stack.context.delete(photo)
        }
        stack.save()
        
    }
    
    
    func loadImages(){
        print("load image")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack

        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "FlickrPhoto")
        let pred = NSPredicate(format: "pic2pin = %@", flickrPin!)
        fr.predicate = pred
        let sd = NSSortDescriptor(key: "text", ascending: true)
        fr.sortDescriptors = [sd]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        if let fc = fetchedResultsController{
        do{
            
            try fc.performFetch()
            if(((fc.sections?.count)! > 0)&&((fc.sections?[0].numberOfObjects)! > 0)) {
            
            //if(frResult.count > 0 ){
                print("Pict found : \(String(describing: fc.sections?.count))")
                //flickrClient.container = frResult as! [FlickrPhoto]
                indicator.stopAnimating()
            }else{
                print("Pick not Found")
                loadFromFlick()
            }
        }catch{
            print("error on retrieving")
        }
        }
        
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController {
            return (fc.sections?.count)!
        }else {
            return 0
        }
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        }else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fp = fetchedResultsController!.object(at: indexPath) as! FlickrPhoto
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PictureViewCell
        cell.flickPhoto = fp
        // Configure the cell
        if(fp.picture != nil){
            cell.imageIndicator.stopAnimating()
            let img = UIImage(data: fp.picture! as Data)
            cell.pict.image = img
            cell.pict.isHidden = false
        } else {
            cell.pict.isHidden = true
            cell.imageIndicator.startAnimating()
        }
        return cell
    }
    
    // MARK : NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() in
            for indexPath in self.insertedIndexPath {
                self.collectionView.insertItems(at: [indexPath])
                print("inserting at \(indexPath)")
            }
            for indexPath in self.deletedIndexPath {
                self.collectionView.deleteItems(at: [indexPath])
                //print("deleting at \(indexPath)")
            }
            for indexPath in self.updatedIndexPath {
                self.collectionView.reloadItems(at: [indexPath])
                //print("reloading at \(indexPath)")
            }
            
        }, completion: {(done) in
            
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let stack = delegate.stack
            
            stack.save()
            
        })
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPath = [IndexPath]()
        deletedIndexPath = [IndexPath]()
        updatedIndexPath = [IndexPath]()
    }
    
    func setSelected(cell : PictureViewCell, selected : Bool){
        if(selected){
            cell.pict.alpha = 0.5
        }else{
            cell.pict.alpha = 1
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {

        switch type {
            
        case .insert:
            print("inserting \(String(describing: newIndexPath))")
            insertedIndexPath.append(newIndexPath!)
            break
        case .update:
            updatedIndexPath.append(indexPath!)
            break
        case .delete:
            deletedIndexPath.append(indexPath!)
            break
        default:
            break
        }

    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if(selectedIndex.contains(indexPath)){
            let i = selectedIndex.index(of: indexPath)
            selectedIndex.remove(at: i!)
            setSelected(cell: collectionView.cellForItem(at: indexPath) as! PictureViewCell, selected: false)
        }else{
            selectedIndex.append(indexPath)
            setSelected(cell: collectionView.cellForItem(at: indexPath) as! PictureViewCell, selected: true)
        }
        if(selectedIndex.count > 0){
            buttonReload.setTitle( "Delete Items", for: .normal)
            
        }else{
            buttonReload.setTitle( "New Collection", for: .normal)
            
        }
        
        return true
    }
    
}
