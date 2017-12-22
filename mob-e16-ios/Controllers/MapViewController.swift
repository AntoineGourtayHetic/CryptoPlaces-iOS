//
//  MapViewController.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 18/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import UIKit
import MapKit
import KeychainSwift
import Alamofire
import AlamofireImage
import SwiftyJSON
import Firebase

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelCurrentBalance: UILabel!
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var cardLabelName: UILabel!
    @IBOutlet weak var cardLabelType: UILabel!
    @IBOutlet weak var cardLabelAdress: UILabel!
    @IBOutlet weak var cardLabelNumber: UILabel!
    @IBOutlet weak var cardLabelDescription: UILabel!
    @IBOutlet weak var cardImageFirst: UIImageView!
    @IBOutlet weak var cardImageSecond: UIImageView!
    @IBOutlet weak var cardImageThird: UIImageView!
    @IBOutlet weak var cardButtonDirections: UIButton!
    @IBOutlet weak var cardButtonClose: UIButton!
    @IBOutlet weak var labelCurrentLatitude: UILabel!
    @IBOutlet weak var labelCurrentLongitude: UILabel!
    
    
    
    var pins: [Pin] = []
    var pinList = [NewPin]()
    let locationManager = CLLocationManager()
    let keychain = KeychainSwift()
    
    // load json
    func loadInitialData() {
        Alamofire.request("https://api.myjson.com/bins/1d7qb3").responseJSON { response in
            if let data = response.result.value {
                let json = JSON(data)
                for (_,subJson):(String, JSON) in json["results"] {
                    let name = subJson["name"]
                    let type = subJson["category"]
                    let latitude = subJson["position"]["latitude"]
                    let longitude = subJson["position"]["longitude"]
                    let adress = subJson["address"]
                    let number = subJson["telephone"]
                    let details = subJson["details"]
                    let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude.floatValue), longitude: CLLocationDegrees(longitude.floatValue))
                    
                    let pin = NewPin(name: "\(name)", type: "\(type)", latitude: latitude.floatValue, longitude: longitude.floatValue, adress: "\(adress)", number: "\(number)", details: "\(details)", coordinate: coordinate)
                    self.pinList.append(pin)
                    self.mapView.addAnnotation(pin)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let onboardingPassed = keychain.getBool("onboardingPassed"){
            if onboardingPassed != true {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "OnboardingViewController") as! UIPageViewController
                self.present(nextViewController, animated:false, completion:nil)
            }
        }else{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "OnboardingViewController") as! UIPageViewController
            self.present(nextViewController, animated:false, completion:nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardView.isHidden = true
        self.labelCurrentLatitude.isHidden = true
        self.labelCurrentLongitude.isHidden = true
        self.cardButtonDirections.layer.cornerRadius = 7
        Analytics.setUserProperty("1", forName: "key_count") // ONLY ONE KEY ATM
        getBalance()
        
        // set initial location at HETIC
        let initialLocation = CLLocation(latitude: 48.850762, longitude: 2.420606)
        centerMapOnLocation(location: initialLocation)
        
        mapView.delegate = self
        
        // show pins on map
        mapView.register(PinMarkerView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        loadInitialData()
        mapView.addAnnotations(pinList)
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @IBAction func buttonCardClosePressed(_ sender: Any) {
        var frame = self.cardView.frame
        frame.origin.y = self.view.frame.size.height + (frame.size.height)
        UIView.animate(withDuration: 0.5, animations: {
            self.cardView.frame = frame
        })
    }
    
    @IBAction func buttonDirectionPressed(_ sender: Any) {
        let latitude = self.labelCurrentLatitude.text as! String
        let longitude = self.labelCurrentLongitude.text as! String
        let name = self.cardLabelName.text
        
        Analytics.logEvent("click_routes", parameters: [
            "shop_name": "\(name)",
            "position_long_shop": "\(longitude)",
            "position_lat_shop": "\(latitude)"
            ])
        
        UIApplication.shared.openURL(NSURL(string: "http://maps.apple.com/?q=\(latitude),\(longitude)")! as URL)
    }

    func getBalance() {
        if let pubKey = keychain.get("pubKey"){
            Alamofire.request("https://blockexplorer.com/api/addr/\(pubKey)/balance").responseJSON { response in
                if let data = response.result.value {
                    let currentBalance = 0.00000001 * (data as! Double)
                    self.labelCurrentBalance.text = "\(currentBalance) ₿"
                    Analytics.setUserProperty("\(currentBalance)", forName: "btc_count")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? Pin else { return nil }
        let identifier = "marker"
        var view: MKMarkerAnnotationView

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    // click on the right "i" to launch Maps Directions
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Pin
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
    
    // open the card
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let location = view.annotation as! NewPin
        self.cardLabelName.text = location.name
        self.cardLabelType.text = location.type
        self.cardLabelAdress.text = "📍 \(location.adress)"
        self.cardLabelNumber.text = "✆ \(location.number)"
        self.cardLabelDescription.text = location.details
        self.labelCurrentLatitude.text = location.latitude.description
        self.labelCurrentLongitude.text = location.longitude.description
        
        Alamofire.request("http://www.sofsbar.fr/images/sofs-bar-06-sofs-bar-01-u1891.png").responseImage { response in
            if let image = response.result.value {
                self.cardImageFirst.image = image
                self.cardImageSecond.image = image
                self.cardImageThird.image = image
            }
        }
        
//        let imageView = UIImageView(frame: frame)
//        let url = URL(string: "https://httpbin.org/image/png")!
//        
//        imageView.af_setImage(withURL: url)
        
        Analytics.logEvent("shop_tap", parameters: [
            "position_long_shop": "\(location.longitude)",
            "position_lat_shop": "\(location.latitude)",
            "shop_name": "\(location.name)",
            "shop_currencies" : "BTC", // TODO
            "shop_type" : "\(location.type)"
            ])
        
        self.cardView.isHidden = false
        var frame = self.cardView.frame
        frame.origin.y = self.view.frame.size.height - (frame.size.height)
        UIView.animate(withDuration: 0.5, animations: {
            self.cardView.frame = frame
        })
    }
}
