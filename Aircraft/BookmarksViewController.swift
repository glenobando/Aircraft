//
//  BookmarksViewController.swift
//  Aircraft
//
//  Created by Glen Obando on 29/6/21.
//

import UIKit
import RealmSwift

class BookmarksViewController: UITableViewController {

    @IBOutlet var FlightsTableView: UITableView!
    var arrayFlight: [Flight]?{
        didSet{
            FlightsTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.arrayFlight = self.getBookmarks()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.arrayFlight = self.getBookmarks()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let array = arrayFlight {
            return array.count
        }
        return 0
    }

    
    func getBookmarks() -> [Flight] {
        let realm = try! Realm()
        let flights = realm.objects(FlightObject.self)
        var flightList = [Flight]()

        for f in flights {
            flightList.append(Flight(iataNumber: f.iataNumber, icaoNumber: f.icaoNumber, number: f.number, altitude: f.altitude, latitude: f.latitude, longitude: f.longitude, arrivalCode: f.arrivalCode, departureCode: f.departureCode, direction: f.direction, status: f.status))
        }

        return flightList
    }
    
    func deleteBookmark(itemSelected: Flight?){
        let realm = try! Realm()

        let f = realm.objects(FlightObject.self).filter("iataNumber == '\(itemSelected!.iataNumber)'")

        if f.count > 0 {
            try! realm.write({
                realm.delete(f[0])
            })
        }
        let alert = UIAlertController(title: "Bookmarks", message: "Flight \(itemSelected!.iataNumber) deleted from Bookmarks", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    @IBAction func deleteAll(_ sender: Any) {
        let alert = UIAlertController(title: "Bookmarks", message: "Delete All Bookmarks?", preferredStyle: .alert)

        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            let realm = try! Realm()
            try! realm.write {
                realm.deleteAll()
            }
            self.arrayFlight?.removeAll()
        }

        let noAction = UIAlertAction(title: "No", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if let array = arrayFlight{
            cell.textLabel?.text = "Flight #\(array[indexPath.row].iataNumber)"
            cell.detailTextLabel?.text = "\t🛫 " + array[indexPath.row].departureCode + "\t🛬 " + array[indexPath.row].arrivalCode
       }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Bookmarked Flights"
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            self.deleteBookmark(itemSelected: arrayFlight![indexPath.row])
            arrayFlight?.remove(at: indexPath.row)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let index = self.FlightsTableView.indexPathForSelectedRow {
            let destino = segue.destination as? FlightDetailsViewController
            destino?.itemSelected = arrayFlight?[index.row]
        }
    }

}
