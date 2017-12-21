//
//  Pin.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 18/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Pin: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let type: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, type: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.type = type
        self.coordinate = coordinate
        
        super.init()
    }
    
    init?(json: [Any]) {
        self.title = json[0] as? String ?? "No Title"
        self.locationName = json[1] as! String
        self.type = json[2] as! String
        if let latitude = Double(json[3] as! String),
            let longitude = Double(json[4] as! String) {
            self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            self.coordinate = CLLocationCoordinate2D()
        }
    }
    
    var subtitle: String? {
        return locationName
    }
    
    // color of the pin in function of type
    var markerTintColor: UIColor  {
        switch type {
        case "restaurant":
            return .red
        case "coiffeur":
            return .cyan
        case "magasin":
            return .blue
        case "cafe":
            return .purple
        default:
            return .green
        }
    }
    
    // Annotation right callout accessory opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}
