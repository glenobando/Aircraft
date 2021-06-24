//
//  FlightMapViewController.swift
//  Aircraft
//
//  Created by Christian Monge on 23/6/21.
//

import UIKit
import MapKit
import CoreLocation

class FlightMapViewController: UIViewController {
    
    @IBOutlet weak var flightViewMap: MKMapView!
    
    var itemSelected:Flight?
    var arrayFlights = [Flight]()
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
        for flight in arrayFlights{
            let annontation = MKPointAnnotation()
            annontation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(flight.latitude), longitude: CLLocationDegrees(flight.longitude))
            annontation.title = "Altitud: " + flight.altitude.description + " - Flight: " + flight.icaoNumber
            annontation.subtitle = "Departure: " + flight.departureCode + " - Arrival: " + flight.arrivalCode
            flightViewMap.addAnnotation(annontation)
        }
        userPin()
        
    }
    func userPin () {
        let userAnnontation = MKPointAnnotation()
        userAnnontation.coordinate = CLLocationCoordinate2D(latitude: 9.935007, longitude: -84.103011)
        userAnnontation.title = "Usted está aquí."
        userAnnontation.accessibilityElementIsFocused()
        flightViewMap.addAnnotation(userAnnontation)
        let region = MKCoordinateRegion(center: userAnnontation.coordinate, latitudinalMeters: 300000, longitudinalMeters: 300000)
        flightViewMap.setRegion(region, animated: true)
    }
    func putPin () {
        let annontation = MKPointAnnotation()
        annontation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(itemSelected!.latitude), longitude: CLLocationDegrees(itemSelected!.longitude))
        annontation.title = "Altitud: " + itemSelected!.altitude.description + " - Flight: " + itemSelected!.icaoNumber
        annontation.subtitle = "Departure: " + itemSelected!.departureCode + " - Arrival: " + itemSelected!.arrivalCode
        flightViewMap.addAnnotation(annontation)
        
        userPin()
    }
}
