//
//  City+CoreDataProperties.swift
//  Andrey_Kan_FE_8828400
//
//  Created by Andrey Kan on 05.08.2023.
//
//

import Foundation
import CoreData


extension City {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<City> {
        return NSFetchRequest<City>(entityName: "City")
    }

    @NSManaged public var name: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var weatherDescription: String?
    @NSManaged public var temperature: Double
    @NSManaged public var humidity: Double
    @NSManaged public var windSpeed: Double
    @NSManaged public var weatherIconUrl: String?
    @NSManaged public var photoUrl: String?
    @NSManaged public var id: UUID?

}

extension City : Identifiable {

}
