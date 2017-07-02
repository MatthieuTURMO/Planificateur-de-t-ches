//
//  Taches.swift
//  TaskPlan
//
//  Created by Matthieu Turmo on 25/01/2017.
//  Copyright © 2017 Matthieu Turmo. All rights reserved.
//

import UIKit
import os.log

//Model class
class Taches: NSObject, NSCoding{
    
    //MARK: Properties
    var titre:String
    var date:Date
    var lieu:String
    var rating:Int
    var descriptionT:String
    var alerteLevee:Int
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("taches")
    
    //MARK: Types
    
    struct PropertyKey {
        static let titre = "titre"
        static let date = "date"
        static let rating = "rating"
        static let descriptionT = "descriptionT"
    }

    
    init?(titre: String, date: Date, rating: Int, lieu:String, descriptionT:String) {
        
        guard !titre.isEmpty else{
            return nil
        }
        guard (rating>=0) && (rating<=3) else {
            return nil
        }
        
        //if let lolxd ?? "" {}//si description est NIL
        
        self.descriptionT=descriptionT
        self.titre = titre
        self.date = date
        self.rating = rating
        self.lieu=lieu
        self.alerteLevee = 0
    }
    
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(titre, forKey: PropertyKey.titre)
        aCoder.encode(rating, forKey: PropertyKey.rating)
        aCoder.encode(descriptionT, forKey: PropertyKey.descriptionT)
        aCoder.encode(date, forKey: PropertyKey.date)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let titre = aDecoder.decodeObject(forKey: PropertyKey.titre) as? String else {
            os_log("Unable to decode the titre for a Task object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let descriptionT = aDecoder.decodeObject(forKey: PropertyKey.descriptionT) as? String else {
            os_log("Unable to decode the descriptionT for a Task object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because photo is an optional property of Meal, just use conditional cast.
        let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? Date
        
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
        
        // Must call designated initializer.
        self.init(titre: titre, date: date!, rating: rating, lieu: "nonFait", descriptionT:descriptionT)
        
    }
    
}
