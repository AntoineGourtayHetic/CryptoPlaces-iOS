//
//  NewPin.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 21/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class NewPin: NSObject, MKAnnotation {
    let name: String
    let type: String
    let latitude: Float
    let longitude: Float
    let adress: String
    let number: String
    let details: String
    let coordinate: CLLocationCoordinate2D
    
    init(name newName: String, type newType: String, latitude newLatitude: Float, longitude newLongitude: Float, adress newAdress: String, number newNumber: String, details newDetails: String, coordinate newCoordinate: CLLocationCoordinate2D) {
        self.name = newName
        self.type = newType
        self.latitude = newLatitude
        self.longitude = newLongitude
        self.adress = newAdress
        self.number = newNumber
        self.details = newDetails
        self.coordinate = newCoordinate
    }
}

