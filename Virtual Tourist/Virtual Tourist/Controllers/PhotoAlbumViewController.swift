//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Nouf Abdullah on 5/16/19.
//  Copyright © 2019 Nouf Abdullah. All rights reserved.
//

import UIKit
import MapKit
import SVProgressHUD
import CoreData

class PhotoAlbumViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,MKMapViewDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noDataFound: UILabel!
    @IBOutlet weak var newCollectionBtn: UIButton!
    
    var photoURLList: [PhotoEntity] = []
    var photosList: [Photos] = []
    var selectedPin:Pin?
    var nextPage = 1
    var dataControllers:DataControllers!
    let spacing: CGFloat = 5
    let numberOfItemsInRow: CGFloat = 3
    var photosToDelete = [IndexPath]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewLayout()
        loadData()
    }
    
    // Set the map view the selected pin
    func viewLayout() {
        if let selectedPin = selectedPin {
            let coordinate = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
            let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8))
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.setRegion(region, animated: false)
            mapView.addAnnotation(annotation)
        }
    }
    
    // Add custom image for map pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        }
        annotationView?.image = #imageLiteral(resourceName: "2190994-48-2")
        return annotationView
    }
    
    // Load any saved images for the selected pin or dowlonad new ones if none found
    func loadData() {
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "photos == %@", selectedPin!)
        let sortDescriptors = NSSortDescriptor(key: "imageData", ascending: false)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptors]
        do {
            let result = try dataControllers.viewContext.fetch(fetchRequest)
            print("result : \(result.count) found")
            if result.count > 0 {
                photosList = result
                self.collectionView.reloadData()
            } else {
                searchForImages()
            }
        } catch {
            HelperClass().showAlert(message: "Could Not Load Save Data!", self)

        }
    }
    
    // Call flickr search API to get list of images url for the selected location
    func searchForImages() {
        SVProgressHUD.show()
        if let selectedPin = selectedPin {
            WebserviceManager().searchForPhotos(latitude: selectedPin.latitude, longitude: selectedPin.longitude, page: nextPage) { (success, photoData) in
                if success && photoData!.photos!.photo!.count > 0 {
                    self.photoURLList = photoData!.photos!.photo!
                    print("There are \(self.photoURLList.count) photos founds")
                    self.saveImages()
                } else {
                    self.updateUI()
                    print("no images found for selected location ")
                }
            }
        }
    }
    
    // save the list of images to DB
    func saveImages() {
        for photo in photoURLList {
            WebserviceManager().loadImage(imageUrl:photo.url_m!) { success, images in
                if success {
                    let photos = Photos(context: self.dataControllers.viewContext)
                    photos.imageURL = photo.url_m!
                    photos.imageData = images!.pngData()
                    photos.photos = self.selectedPin
                    self.saveImagesToDB()
                    self.photosList.insert(photos, at: 0)
                    //self.photosList.append(photos)
                    self.collectionView.reloadData()
                    self.updateUI()
                } else {
                    self.updateUI()
                    HelperClass().showAlert(message: "Images Could Not Dowloand!", self)
                }
            }
        }
    }
    // Save image to DB
    func saveImagesToDB() {
        do {
            try self.dataControllers.viewContext.save()
        } catch {
            HelperClass().showAlert(message: "Images Could Not Save!", self)
        }
    }
    
    // Update the UI to notify the user if no image was found
    func updateUI() {
        SVProgressHUD.dismiss()
        noDataFound.isHidden = photosList.count > 0 ? true:false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photosList.count > 0 {
            
            return photosList.count
        } else {
            return 0
        }
    }
    
    // Show collection of images
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PhotoAlbumCollectionCell
        if photoURLList.count > 0 {
            
            if photosToDelete.count > 0  && photosToDelete.contains(indexPath){
                cell.blurView.isHidden = false
            } else {
                cell.blurView.isHidden = true
            }
            cell.activityIndicator.startAnimating()
            WebserviceManager().loadImage(imageUrl: photoURLList[indexPath.row].url_m!) { (success, imageData) in
                cell.imageView.image = imageData
                cell.activityIndicator.stopAnimating()
            }
        } else {
            cell.imageView.image = UIImage(data: photosList[indexPath.row].imageData!)
        }
        
        // Add blur effect on the selected image to be deleted
        
        
        return cell
    }
 
    // Set the left and right spacing of a cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
    // Set the collection view to have three cell per row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        let widthWithoutMargins = width - ((numberOfItemsInRow + 1) * spacing)
        let itemWidth = widthWithoutMargins / numberOfItemsInRow
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    // Set minimum line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    // Set minimum lnteritem spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    // add/remove the index of the cell user select/deselect to be deleted
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if photosToDelete.contains(indexPath) {
            photosToDelete = photosToDelete.filter { $0 != indexPath}
        } else {
            photosToDelete.append(indexPath)
        }
        let title = photosToDelete.count > 0 ? "Remove Selected Pictures":"New Collection"
        newCollectionBtn.setTitle(title, for: .normal)
        collectionView.reloadData()
    }
    
    // delete the seletect image and update the DB and the collection view
    func deleteImages() {
        for index in photosToDelete {
            dataControllers.viewContext.delete(photosList[index.row])
            saveImagesToDB()
            photosList.remove(at: index.row)
            collectionView.reloadData()
            photosToDelete = photosToDelete.filter { $0 != index}
            newCollectionBtn.setTitle("New Collection", for: .normal)
        }
    }
    
    func getNewImageCollection() {
        for photos in photosList {
            dataControllers.viewContext.delete(photos)
            photosList.removeAll()
            collectionView.reloadData()
            saveImagesToDB()
        }
        nextPage += 1
        searchForImages()
    }
    
    // load new collection of images or delete images from the collection view
    @IBAction func addDeleteImageCollection(_ sender: Any) {
        if newCollectionBtn.currentTitle == "Remove Selected Pictures" {
            deleteImages()
        } else {
           getNewImageCollection()
        }
    }
}

