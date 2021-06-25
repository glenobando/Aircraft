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
    var location = CLLocation()
    //var userAnnontation = MKPointAnnotation()
    //var delegate:PostDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        //putPin()
        //
        print(location)
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
            annontation.title = "Altitude: " + flight.altitude.description + " - Flight: " + flight.icaoNumber
            annontation.subtitle = "\(flight.direction)\t🛫 " + flight.departureCode + "\t🛬 " + flight.arrivalCode
            flightViewMap.addAnnotation(annontation)
        }
        userPin()
        
    }
    func userPin () {
        let userAnnontation = MKPointAnnotation()
        userAnnontation.coordinate = CLLocationCoordinate2D(latitude: self.location.coordinate.latitude, longitude: self.location.coordinate.longitude)//(latitude: 9.935007, longitude: -84.103011)
        userAnnontation.title = "Usted está aquí."
        userAnnontation.accessibilityElementIsFocused()
        flightViewMap.addAnnotation(userAnnontation)
        let region = MKCoordinateRegion(center: userAnnontation.coordinate, latitudinalMeters: 300000, longitudinalMeters: 300000)
        flightViewMap.setRegion(region, animated: true)
    }
    func putPin () {
        let annontation = MKPointAnnotation()
        annontation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(itemSelected!.latitude), longitude: CLLocationDegrees(itemSelected!.longitude))
        annontation.title = "Altitude: " + itemSelected!.altitude.description + " - Flight: " + itemSelected!.icaoNumber
        annontation.subtitle = "\(itemSelected!.direction)\t🛫 " + itemSelected!.departureCode + "\t🛬 " + itemSelected!.arrivalCode
        flightViewMap.addAnnotation(annontation)
        
        userPin()
    }
}

extension FlightMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

            if annotation.title == "Usted está aquí." {
                annotationView?.image = "📍".image()
            } else {
                let sub = annotation.subtitle!! as String
                let direction = sub.prefix(upTo: sub.firstIndex(of: "\t")!)
                annotationView?.image = "✈️".image()?.rotate(degrees: Float(direction)!-45)
            }

        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }
}


extension String {
    func image() -> UIImage? {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: 20) // you can change your font size here
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
}

extension UIImage{
    func rotate(degrees: Float)  -> UIImage? {
        let radians = degrees * Float.pi / 180
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    
}
