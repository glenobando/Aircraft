//
//  FlightDetailsViewController.swift
//  Aircraft
//
//  Created by Glen Obando on 28/6/21.
//

import UIKit
import Alamofire
import SwiftyJSON

class AirportDetailsViewController: UITableViewController {
 
    @IBOutlet var airportDetailsTableView: UITableView!
    
    let urlTimeTable = "https://aviation-edge.com/v2/public/timetable?key=9a4206-8c088d"
    var arrayDetails: [FlightDetail]? {
        didSet {
            self.airportDetailsTableView.reloadData()
        }
    }

    var itemSelected:Airport?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = itemSelected?.codeIataAirport
        self.getFlightDetails()
        // Do any additional setup after loading the view.
    }
    
    func getFlightDetails() {
        var array = [FlightDetail]()
        
        Session.default.request(urlTimeTable+"&iataCode=\(itemSelected?.codeIataAirport ?? "")").responseJSON { [self] response in
            switch response.result {
            case .success(let data):
                if let details = data as? [[String: Any]] {
                    for detail in details {
                        let arrival = detail["arrival"] as? [String:Any]
                        let departure = detail["departure"] as? [String:Any]
                        let status = detail["status"] as? String
                        let flight = detail["flight"] as? [String:Any]
                        let arr = FlightDetail(
                            airportIataCode: arrival!["iataCode"] as? String ?? "",
                            terminal: arrival!["terminal"] as? String ?? "",
                            gate: arrival!["gate"] as? String ?? "",
                            scheduledTime: arrival!["scheduledTime"] as? String ?? "",
                            actualTime: arrival!["actualTime"] as? String ?? "",
                            estimatedTime: arrival!["estimatedTime"] as? String ?? "",
                            delay: arrival!["delay"] as? String ?? "",
                            iataNumber: flight!["iataNumber"] as? String ?? "",
                            status: ""
                        )
                        let dep = FlightDetail(
                            airportIataCode: departure!["iataCode"] as? String ?? "",
                            terminal: departure!["terminal"] as? String ?? "",
                            gate: departure!["gate"] as? String ?? "",
                            scheduledTime: departure!["scheduledTime"] as? String ?? "",
                            actualTime: departure!["actualTime"] as? String ?? "",
                            estimatedTime: departure!["estimatedTime"] as? String ?? "",
                            delay: departure!["delay"] as? String ?? "",
                            iataNumber: flight!["iataNumber"] as? String ?? "",
                            status: status ?? ""
                        )
                        
                        if !array.contains(where: {$0.scheduledTime == dep.scheduledTime}){
                            array.append(dep)
                            array.append(arr)
                        }
                    }
                    self.arrayDetails = array
                }
            case .failure(let error):
                print("Something went wrong: \(error)")
            }
       }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AirportDetailsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let array = self.arrayDetails else {
            return 0
        }
        return array.count/2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let array = self.arrayDetails else {
            return 0
        }
        return 2//array.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : AirportDetailsCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AirportDetailsCell
        let i = indexPath.section * 2
        
        if let array = self.arrayDetails{
            cell.airportLabel.text = ((indexPath.row % 2) == 0 ? "🛫 From: " : "🛬 To: ") + array[indexPath.row+i].airportIataCode!
            cell.terminalLabel.text = "Terminal: " + array[indexPath.row+i].terminal!
            cell.gateLabel.text = "Gate: " + array[indexPath.row+i].gate!
            cell.scheduledLabel.text = "Scheduled: " + array[indexPath.row+i].scheduledTime!.dropLast(7)
            cell.actualLabel.text = "Actual: " + array[indexPath.row+i].actualTime!.dropLast(7)
            cell.estimatedLabel.text = "Estimated: " + array[indexPath.row+i].estimatedTime!.dropLast(7)
            cell.delayStatusLabel.text = "⏱ " + array[indexPath.row+i].delaystatus()
            if cell.delayStatusLabel.text == "⏱ delayed" {
                cell.delayStatusLabel.textColor = UIColor.systemRed
            } else {
                cell.delayStatusLabel.textColor = UIColor.systemGreen
            }
            cell.statusLabel.text = array[indexPath.row+i].status
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let array = self.arrayDetails{
            return "Flight #\(array[section*2].iataNumber ?? "")"
        }
        return ""
    }

    
}

class AirportDetailsCell: UITableViewCell {
    
    @IBOutlet weak var airportLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var terminalLabel: UILabel!
    @IBOutlet weak var gateLabel: UILabel!
    @IBOutlet weak var scheduledLabel: UILabel!
    @IBOutlet weak var estimatedLabel: UILabel!
    @IBOutlet weak var actualLabel: UILabel!
    @IBOutlet weak var delayStatusLabel: UILabel!
}
