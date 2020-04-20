//
//  Review.swift
//  Snacktacular
//
//  Created by RJ Smithers on 4/19/20.
//  Copyright © 2020 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        print("^^^ dictionary: Date comes out as \(Date())")
        return ["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": date, "documentID": documentID]
    }
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        print("^^^ Date initialized as \(self.date)")
        self.documentID = documentID
    }
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        print("^^^ convenience init1: Date comes out as \(Date())")
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["reviewerUserID"] as! String
        print("Title: \(title)")
        print("convenience init2: Date = \(dictionary["date"]!)")
//        Date? or Date() is not the same type as what comes out of dictionary (FIRTimestamp)
        let fbDate = dictionary["date"] as! Timestamp? ?? Timestamp()
        let date = fbDate.dateValue()
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, date: date, documentID: "")
    }
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
 
        // Create the dictionary representing data we want to save
        let dataToSave = self.dictionary
        
        // if already has saved record, we'll have a doc ID
        if self.documentID != "" {
            // Making a new collection inside of the document corresponding to the spot we want to review
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("*** ERROR: Updating doc \(self.documentID) in spot \(spot.documentID) \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ Doc updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        } else {
            var ref: DocumentReference? = nil // Let firestore create new doc ID
            
            // Saves the dictionary of info
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave)  { error in
                if let error = error {
                    print("*** ERROR: Creating new document in spot \(spot.documentID) for new review documentID \(error.localizedDescription)")
                    completed(false)
                } else {
                    print("^^^ New document created with ref ID \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
            }
            
        }
    }
}
