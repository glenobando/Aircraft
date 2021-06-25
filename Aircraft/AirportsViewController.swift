//
//  AirportsViewController.swift
//  Aircraft
//
//  Created by Christian Monge on 22/6/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import MapKit


class AirportsViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var airportTableView: UITableView!
    let locationManager = CLLocationManager()
    let annontation = MKPointAnnotation()
    var arrayAirport = [Airport]()
    var array = [String]()
    let urlRatio = "https://aviation-edge.com/v2/public/nearby?key=9a4206-8c088d"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //callAirports()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinoAll = segue.destination as? MapViewController
        destinoAll?.arrayAirports = arrayAirport
        destinoAll?.allSelected = true
        destinoAll?.location = locationManager.location!
        if let index = self.airportTableView.indexPathForSelectedRow {
            let destino = segue.destination as? MapViewController
            destino?.itemSelected = arrayAirport[index.row]
            destino?.allSelected = false
            destino?.location = locationManager.location!
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            annontation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            callAirports(location: location)
        }
    }

    func callAirports (location: CLLocation){
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)

        Session.default.request(urlRatio+"&lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)&distance=100").responseJSON { [self] response in
            switch response.result {
            case .success(let data):
                if let airports = data as? [[String: Any]] {
                    for airport in airports {
                        let aux = Airport(
                            codeIataAirport: airport["codeIataAirport"] as! String,
                            codeIataCity: airport["codeIataCity"] as? String ?? "",
                            latitudeAirport: Float(truncating: airport["latitudeAirport"] as? NSNumber ?? 0),
                            longitudeAirport: Float(truncating: airport["longitudeAirport"] as? NSNumber ?? 0),
                            nameAirport: airport["nameAirport"] as? String ?? "",
                            nameCountry: airport["nameCountry"] as? String ?? "")
                        arrayAirport.append(aux)
                        
                    }
                    self.navigationController?.tabBarItem.badgeColor = .systemGreen
                    self.navigationController?.tabBarItem.badgeValue = "\(arrayAirport.count)"
                }
            case .failure(let error):
                print("Something went wrong: \(error)")
            }
            self.airportTableView.reloadData()
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
       }
        
    }
}

extension AirportsViewController:UITableViewDelegate, UITableViewDataSource {
    override func viewWillAppear(_ animated: Bool) {
        airportTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayAirport.count
    }
  
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        let name = arrayAirport[indexPath.row].nameAirport
        let country = arrayAirport[indexPath.row].nameCountry
        cell.textLabel?.text = name + ", " + country
        cell.detailTextLabel?.text = arrayAirport[indexPath.row].codeIataAirport
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby Airports"
    }
}
