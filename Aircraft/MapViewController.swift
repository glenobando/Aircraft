//
//  MapViewController.swift
//  Aircraft
//
//  Created by Christian Monge on 23/6/21.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var itemSelected:Airport?
    var arrayAirports = [Airport]()
    var allSelected = false
    //var userAnnontation = MKPointAnnotation()
    //var delegate:PostDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        //putPin()
        //
        if allSelected{
            createPins()
        }else{
            putPin()
        }
        
    }

    func createPins () {
        for airport in arrayAirports{
            let annontation = MKPointAnnotation()
            annontation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(airport.latitudeAirport), longitude: CLLocationDegrees(airport.longitudeAirport))
            annontation.title = airport.nameAirport + ", " + airport.codeIataAirport
            annontation.subtitle = airport.nameCountry + ", " + airport.codeIataCity
            mapView.addAnnotation(annontation)
        }
        userPin()
        
    }
    func userPin () {
        let userAnnontation = MKPointAnnotation()
        userAnnontation.coordinate = CLLocationCoordinate2D(latitude: 9.935007, longitude: -84.103011)
        userAnnontation.title = "Usted está aquí."
        userAnnontation.accessibilityElementIsFocused()
        mapView.addAnnotation(userAnnontation)
        let region = MKCoordinateRegion(center: userAnnontation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
            mapView.setRegion(region, animated: true)
    }
    func putPin () {
        let annontation = MKPointAnnotation()
        annontation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(itemSelected!.latitudeAirport), longitude: CLLocationDegrees(itemSelected!.longitudeAirport))
        annontation.title = itemSelected!.nameAirport + ", " + itemSelected!.codeIataAirport
        annontation.subtitle = itemSelected!.nameCountry + ", " + itemSelected!.codeIataCity
        mapView.addAnnotation(annontation)
        
        userPin()
    }

}
