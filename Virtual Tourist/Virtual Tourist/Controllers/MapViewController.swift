//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Nouf Abdullah on 5/14/19.
//  Copyright © 2019 Nouf Abdullah. All rights reserved.

import UIKit
import MapKit
import CoreData
class MapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var editBarBtn: UIBarButtonItem!
    @IBOutlet weak var deletePinsView: UIView!
    var mapViewPins:[Pin] = []
    var dataControllers:DataControllers!
    var pinCustomImageName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPins()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    }
    
    // Load saved pins in database
    func fetchPins() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        do {
            let result = try dataControllers.viewContext.fetch(fetchRequest)
            self.mapViewPins = result
            print("There are \(result.count) locations")
            loadPins()
        } catch {
            HelperClass().showAlert(message: "Could Not Load Save Data!", self)
        }
    }
    // Add the saved pins on the map
    func loadPins() {
        for pins in self.mapViewPins {
            let pinsCoordinate = MKPointAnnotation()
            pinsCoordinate.coordinate = CLLocationCoordinate2D(latitude: pins.latitude, longitude: pins.longitude)
            mapView.addAnnotation(pinsCoordinate)
        }
    }
    
    // Add new pin to the map and save it to DB
    func addNewPin(location:CGPoint) {
        let addPin = Pin(context: dataControllers!.viewContext)
        let LocationCoordinate = mapView.convert(location, toCoordinateFrom: mapView)
        let pin = MKPointAnnotation()
        pin.coordinate = LocationCoordinate
        addPin.latitude = LocationCoordinate.latitude
        addPin.longitude = LocationCoordinate.longitude
        mapViewPins.insert(addPin, at: 0)
        mapView.addAnnotation(pin)
        saveData()
    }
    
    // Save the new add pin to DB
    func saveData() {
        do {
            try dataControllers!.viewContext.save()
        } catch {
            HelperClass().showAlert(message: "Could Not Save New Pin", self)
        }
    }
    
    // Delete pin if user click on edit buton or navigate to photo album VC
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let coordinate = view.annotation?.coordinate
        for pin in mapViewPins as [Pin] {
            if pin.latitude == coordinate!.latitude || pin.longitude == coordinate!.longitude {
                let selectedPin = pin
                print("Found pin info.")
                if deletePinsView.isHidden {
                    openPhotoAlbumViewController(selectedPin: selectedPin)
                } else {
                    deletePins(selectedPin: selectedPin, view)
                }
            }
        }
    }
    
    // Add custom image for map pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        }
        annotationView?.image = #imageLiteral(resourceName: "2190994-48-2")
        annotationView?.canShowCallout = false
        return annotationView
    }
    
    // Delete selected pin from map view  and DB
    func deletePins(selectedPin: Pin,_ view: MKAnnotationView) {
        dataControllers.viewContext.delete(selectedPin)
        saveData()
        self.mapView.removeAnnotation(view.annotation!)
        print("Pin deleted")
    }
    
    // Navigate to photo album VC
    func openPhotoAlbumViewController(selectedPin: Pin) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        vc.dataControllers = self.dataControllers
        vc.selectedPin = selectedPin
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func addPin(location:CGPoint) {
        if deletePinsView.isHidden {
            let location = location
            addNewPin(location:location)
            print("Pin have been added")
        }
    }
    
    // Detect user long press gesture to add new pins
    @IBAction func addNewPinAfterGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let location = sender.location(in: self.mapView)
            addPin(location:location)
        }
    }
    
    // Detect user tap gesture to add new pins
    @IBAction func tapToAddNewPin(_ sender: UITapGestureRecognizer) {
//        let location = sender.location(in: self.mapView)
//        addPin(location: location)
    }
    
    // Enable edit option for pin deletion
    @IBAction func enablePinsDeletion(_ sender: UIBarButtonItem) {
        if deletePinsView.isHidden {
            deletePinsView.isHidden = false
            //mapView.frame.origin.y -= 65
            view.frame.origin.y -= 65
            editBarBtn.title = "Done"
        } else {
            deletePinsView.isHidden = true
            //mapView.frame.origin.y = 65
            view.frame.origin.y = 0
            editBarBtn.title = "Edit"
        }
    }
}

