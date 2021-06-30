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
//    let urlRatio = "https://aviation-edge.com/v2/public/flights?key=9a4206-8c088d%20&lat=9.935007&lng=-84.103011&distance=200"
    let urlRatio = "https://aviation-edge.com/v2/public/flights?key=9a4206-8c088d"

    var client: Client?
    let session = URLSession.shared
    let defaults = UserDefaults.standard

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presentLoginView()
        flightsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //callFlights()
        client = Client (session: session)
        client?.getUsers(type: UserList.self,  complete: {result in

            switch result {
            case .success(let users):
                print(users)
            case .failure(let error):
                print(error)
                self.defaults.removeObject(forKey: appConstants.loginTokenKey)
                self.defaults.synchronize()
                self.presentLoginView()
            }
        })
        
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
        destinoAll?.location = locationManager.location!
        if let index = self.flightsTableView.indexPathForSelectedRow {
            if (segue.identifier == "ShowMapSegue"){
                let destino = segue.destination as? FlightMapViewController
                destino?.itemSelected = arrayFligth[index.row]
                destino?.allSelected = false
                destino?.location = locationManager.location!
            } else if (segue.identifier == "ShowFligthDetailSegue"){
                let destino = segue.destination as? FlightDetailsViewController
                destino?.itemSelected = arrayFligth[index.row]
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            annontation.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            callFlights(location: location)
            //print(annontation.coordinate)
        }
    }

    @IBAction func refreshList(_ sender: Any) {
        callFlights(location: locationManager.location!)
    }
    
    func callFlights (location: CLLocation){
        let child = SpinnerViewController()
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        arrayFligth.removeAll()
        Session.default.request(urlRatio+"&lat=\(location.coordinate.latitude)&lng=\(location.coordinate.longitude)&distance=200").responseJSON { [self] response in
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
                            altitude: Float(truncating: geography!["altitude"] as! NSNumber ),
                            latitude: Float(truncating: geography!["latitude"] as! NSNumber ),
                            longitude: Float(truncating: geography!["longitude"] as! NSNumber ),
                            arrivalCode: arrival!["iataCode"] as! String,
                            departureCode: departure!["iataCode"] as! String,
                            direction: Float(truncating: geography!["direction"] as! NSNumber),
                            status: flight["status"] as! String
                        )
                        arrayFligth.append(aux)
                    }
                    self.navigationController?.tabBarItem.badgeColor = .systemGreen
                    self.navigationController?.tabBarItem.badgeValue = "\(arrayFligth.count)"
                }
            case .failure(let error):
                print("Something went wrong: \(error)")
            }
            self.flightsTableView.reloadData()
            
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
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
        cell.textLabel?.text = "Flight #" + arrayFligth[indexPath.row].iataNumber
        cell.detailTextLabel?.text = "(\(arrayFligth[indexPath.row].status))\t🛫 " + arrayFligth[indexPath.row].departureCode + "\t🛬 " + arrayFligth[indexPath.row].arrivalCode
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Real Time Flights"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        // 2
        let mapAction = UIAlertAction(title: "Show in Map", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "ShowMapSegue", sender: self)
        })
        let detailAction = UIAlertAction(title: "View Details", style: .default,  handler: {_ in
            self.performSegue(withIdentifier: "ShowFligthDetailSegue", sender: self)
        })
            
        // 3
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel,  handler: {_ in
            self.flightsTableView.reloadData()
        })
            
        // 4
        optionMenu.addAction(mapAction)
        optionMenu.addAction(detailAction)
        optionMenu.addAction(cancelAction)
            
        // 5
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func presentLoginView()  {
        guard let _ = defaults.object(forKey: appConstants.loginTokenKey) else {
            let loginVc = self.storyboard?.instantiateViewController(identifier: "login") as? LoginViewController
            loginVc?.modalPresentationStyle = .fullScreen
            self.present(loginVc!, animated: true, completion: nil)
            return
        }
        
    }
}
