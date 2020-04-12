//
//  Spot.swift
//  Snacktacular
//
//  Created by RJ Smithers on 4/11/20.
//  Copyright © 2020 John Gallaugher. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

class Spot {
    var name: String
    var address: String
    var coordinate: CLLocationCoordinate2D
    var averageRating: Double
    var numberOfReviews: Int
    var postingUserID: String
    var documentID: String
    
    // Not static (recomputes each time called)
    var longitude: CLLocationDegrees {
        return coordinate.longitude
    }
    
    var latitude: CLLocationDegrees {
        return coordinate.latitude
    }
    
    var dictionary: [String: Any] {
        return ["name": name, "address": address, "longitude": longitude, "latitude": latitude, "averageRating": averageRating, "numberOfReviews": numberOfReviews, "postingUserID": postingUserID]
    }
    
    init(name: String, address: String, coordinate: CLLocationCoordinate2D, averageRating: Double, numberOfReviews: Int, postingUserID: String, documentID: String) {
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.averageRating = averageRating
        self.numberOfReviews = numberOfReviews
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    convenience init() {
        self.init(name: "", address: "", coordinate: CLLocationCoordinate2D(), averageRating: 0.0, numberOfReviews: 0, postingUserID: "", documentID: "")
    }
    
    func saveData(completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        // Grab userID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Couldn't save data because we don't have a valid postingUserID")
            return completed(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave = self.dictionary
        // if already has saved record, we'll have a doc ID
        if self.documentID != "" {
            let ref = db.collection("spots").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: Updating doc \(self.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Doc updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil // Let firestore create new doc ID
            
            // Saves the dictionary of info
            ref = db.collection("spots").addDocument(data: dataToSave)  { error in
                if let error = error {
                    print("*** ERROR: Creating new document \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ New document created with ref ID \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
            }
            
        }
    }
}
