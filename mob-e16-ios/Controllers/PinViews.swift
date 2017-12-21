//
//  PinViews.swift
//  mob-e16-ios
//
//  Created by Arnaud Duboust on 19/12/2017.
//  Copyright © 2017 Antoine Gourtay. All rights reserved.
//

import Foundation
import MapKit

class PinMarkerView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            guard let pin = newValue as? Pin else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            markerTintColor = pin.markerTintColor
            glyphText = String(pin.type.first!)
        }
    }
}
