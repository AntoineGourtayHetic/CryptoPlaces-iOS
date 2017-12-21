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
import SwiftyJSON

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelCurrentBalance: UILabel!
    
    var pins: [Pin] = []
    let locationManager = CLLocationManager()
    let keychain = KeychainSwift()
    
    // load json
    func loadInitialData() {
        guard let fileName = Bundle.main.path(forResource: "pins", ofType: "json")
            else { return }
        let optionalData = try? Data(contentsOf: URL(fileURLWithPath: fileName))
        
        guard
            let data = optionalData,
            let json = try? JSONSerialization.jsonObject(with: data),
            let dictionary = json as? [String: Any],
            let works = dictionary["data"] as? [[Any]]
            else { return }
        let validWorks = works.flatMap { Pin(json: $0) }
        pins.append(contentsOf: validWorks)
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
        getBalance()
        // TODO: get current location


        
        // set initial location at HETIC
        let initialLocation = CLLocation(latitude: 48.850762, longitude: 2.420606)
        centerMapOnLocation(location: initialLocation)
        
        mapView.delegate = self
        
        // show pins on map
        mapView.register(PinMarkerView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        loadInitialData()
        mapView.addAnnotations(pins)
    }
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
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
    
    // OUVRIR LA CARD EN BAS
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let location = view.annotation as! Pin
//    }
//
//    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
//        let location = view.annotation as! Pin
//    }
    
    func getBalance() {
        if let pubKey = keychain.get("pubKey"){
            Alamofire.request("https://blockexplorer.com/api/addr/\(pubKey)/balance").responseJSON { response in
                if let data = response.result.value {
                    let currentBalance = 0.00000001 * (data as! Double)
                    self.labelCurrentBalance.text = "\(currentBalance) ₿"
                }
            }
        }
    }
}
