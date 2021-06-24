//
//  FlightsViewController.swift
//  Aircraft
//
//  Created by Christian Monge on 22/6/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import MapKit

class FlightsViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var flightsTableView: UITableView!
    let locationManager = CLLocationManager()
    let annontation = MKPointAnnotation()
    var arrayFligth = [Flight]()
    var array = [String]()
    let url = "https://aviation-edge.com/v2/public/flights?key=9a4206-8c088d&limit=5"
    let urlRatio = "https://aviation-edge.com/v2/public/flights?key=9a4206-8c088d%20&lat=9.935007&lng=-84.103011&distance=200"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callFlights()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinoAll = segue.destination as? FlightMapViewController
        destinoAll?.arrayFlights = arrayFligth
        destinoAll?.allSelected = true
        if let index = self.flightsTableView.indexPathForSelectedRow {
            let destino = segue.destination as? FlightMapViewController
            destino?.itemSelected = arrayFligth[index.row]
            destino?.allSelected = false
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            annontation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            //print(annontation.coordinate)
        }
    }

    func callFlights (){
        Session.default.request(urlRatio).responseJSON { [self] response in
            switch response.result {
            case .success(let data):
                if let flights = data as? [[String: Any]] {
                    for flight in flights {
                        let aircraft = flight["flight"] as? [String:Any]
                        let geography = flight["geography"] as? [String:Any]
                        let arrival = flight["arrival"] as? [String:Any]
                        let departure = flight["departure"] as? [String:Any]
                        let aux = Flight(
                            iataNumber:aircraft!["iataNumber"] as! String,
                            icaoNumber: aircraft!["icaoNumber"] as! String,
                            number: aircraft!["number"] as! String,
                            altitude: Float(truncating:geography!["altitude"] as! NSNumber ),
                            latitude: Float(truncating: geography!["latitude"] as! NSNumber ),
                            longitude: Float(truncating: geography!["longitude"] as! NSNumber ),
                            arrivalCode: arrival!["iataCode"] as! String,
                            departureCode: departure!["iataCode"] as! String
                        )
                        arrayFligth.append(aux)
                        print(arrayFligth.count)
                    }
                }
            case .failure(let error):
                print("Something went wrong: \(error)")
            }
            self.flightsTableView.reloadData()
        }
    }
    /*
    func callAir (){
        AF.request(url).responseJSON { response in
            switch response.result {
            case .success(let value):
             if let flights = data as? [[String: Any]] {
            let object = flights[0]
            let aircraft = object["flight"] as? [String:Any]
            let geografy = object["geography"] as? [String:Any]
            print(object)
            let aux = Flight(iataNumber:
            aircraft!["iataNumber"] as! String, icaoNumber: aircraft!["icaoNumber"] as! String, number: aircraft!["number"] as! String)
            arrayFligth.append(aux)
            case .failure(let error):
                print(error)
            }
        }
    }
     */
}

extension FlightsViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayFligth.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        cell.textLabel?.text = "Flight #" + arrayFligth[indexPath.row].iataNumber + " - Departure: " + arrayFligth[indexPath.row].departureCode + " - Arrival: " + arrayFligth[indexPath.row].arrivalCode
        return cell
    }
}
