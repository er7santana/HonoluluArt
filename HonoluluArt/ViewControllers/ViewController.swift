//
//  ViewController.swift
//  HonoluluArt
//
//  Created by Rodrigo Sant Ana on 01/08/19.
//  Copyright © 2019 Shaft Corporation. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    var artworks: [Artwork] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
//        // set initial location in Honolulu
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        centerMapOnLocation(location: initialLocation)
        
//        // show artwork on map
//        let artwork = Artwork(title: "King David Kalakaua",
//                              locationName: "Waikiki Gateway Park",
//                              discipline: "Sculpture",
//                              coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
//        mapView.addAnnotation(artwork)
//
        
        //// Option 1 - With Markers
//        mapView.register(ArtworkMarkerView.self,
//                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)

        // Option 2 - With Images
        mapView.register(ArtworkView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        loadInitialData()
        mapView.addAnnotations(artworks)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
        
        
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    func loadInitialData() {
        // You read the PublicArt.json file into a Data object
        guard let fileName = Bundle.main.path(forResource: "PublicArt", ofType: "json")
            else { return }
        let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        
        guard
            let data = optionalData,
            // You use JSONSerialization to obtain a JSON object
            let json = try? JSONSerialization.jsonObject(with: data),
            // You check that the JSON object is a dictionary with String keys and Any values
            let dictionary = json as? [String: Any],
            // You’re only interested in the JSON object whose key is "data"
            let works = dictionary["data"] as? [[Any]]
            else { return }
        // You flatmap this array of arrays, using the failable initializer that you just added to the Artwork class, and append the resulting validWorks to the artworks array
        let validWorks = works.compactMap { Artwork(json: $0) }
        artworks.append(contentsOf: validWorks)
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
//            centerMapOnLocation(location: mapView.userLocation.location)
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

extension ViewController: MKMapViewDelegate {
    
//    //gets called for every annotation you add to the map (just like tableView(_:cellForRowAt:) when working with table views), to return the view for each annotation.
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        
//        // Your app might use other annotations, like user location, so check that this annotation is an Artwork object. If it isn’t, return nil to let the map view use its default annotation view
//        guard let annotation = annotation as? Artwork else { return nil }
//        
//        // To make markers appear, you create each view as an MKMarkerAnnotationView
//        let identifier = "marker"
//        var view: MKMarkerAnnotationView
//        
//        // Also similarly to tableView(_:cellForRowAt:), a map view reuses annotation views that are no longer visible. So you check to see if a reusable annotation view is available before creating a new one
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            
//            // Here you create a new MKMarkerAnnotationView object, if an annotation view could not be dequeued. It uses the title and subtitle properties of your Artwork class to determine what to show in the callout
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//        return view
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
}

