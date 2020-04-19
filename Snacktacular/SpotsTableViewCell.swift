//
//  SpotsListTableViewCell.swift
//  Snacktacular
//
//  Created by John Gallaugher on 3/23/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import CoreLocation

class SpotsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    var currentLocation: CLLocation!
    var spot: Spot!
    
    func configureCell(spot: Spot) {
        nameLabel.text = spot.name
        // calc distance
        guard let currentLocation = currentLocation else {
            return
        }
        var distanceString = ""
        let distanceInmeters = currentLocation.distance(from: spot.location)
        distanceString = "Distance \((distanceInmeters * 0.00062137).roundTo(places: 2)) miles"
        distanceLabel.text = distanceString
    }

}
