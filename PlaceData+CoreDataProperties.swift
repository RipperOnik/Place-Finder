//
//  PlaceData+CoreDataProperties.swift
//  Andrey_Kan_FE_8828400
//
//  Created by Andrey Kan on 05.08.2023.
//
//

import Foundation
import CoreData
import UIKit


extension PlaceData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlaceData> {
        return NSFetchRequest<PlaceData>(entityName: "PlaceData")
    }
    
    @nonobjc public class func fetchChronologicalRequest() -> NSFetchRequest<PlaceData> {
        let request = NSFetchRequest<PlaceData>(entityName: "PlaceData")
        
        // Create a sort descriptor for the createdAt attribute in reverse order
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        // Add the sort descriptor to the fetch request
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
    // Function to delete all rows from the PlaceData entity
    static func deleteAllData() {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let managedContext = appDelegate.persistentContainer.viewContext

            // Fetch all data using the fetch request
            let fetchRequest: NSFetchRequest<PlaceData> = PlaceData.fetchRequest()

            do {
                let placeData = try managedContext.fetch(fetchRequest)

                // Loop through the fetched data and delete each object
                for data in placeData {
                    managedContext.delete(data)
                }

                // Save the context to commit the deletions
                try managedContext.save()
                print("All rows deleted successfully.")
            } catch {
                print("Error deleting data: \(error)")
            }
    }
    
    static func getCount() -> Int{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let managedContext = appDelegate.persistentContainer.viewContext

        // Check if data is already prepopulated
        let fetchRequest: NSFetchRequest<PlaceData> = PlaceData.fetchRequest()
        do {
            let count = try managedContext.count(for: fetchRequest)
            return count
        } catch {
            print("Error checking prepopulated data: \(error)")
        }
        return 0
    }
    
    static func insertInitialData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        // Data for 5 places
        let placeDataArray: [(name: String, latitude: Double, longitude: Double, temperature: Double, humidity: Double, weatherDescription: String, weatherIconUrl: String, windSpeed: Double, photoUrl: String, createdAt: Date)] = [
            ("Kitchener", 43.4254, -80.5112, 13.08, 94, "Mist", "https://openweathermap.org/img/wn/50n@2x.png", 5.544, "https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=AUacShgfL_iPbXIxWx0RFxchjLLDOC0SczTyW2eIS0Sd2zUEodXQRFQAuJWXl0CQuTrCNwIxLaqAR_4goDqgyOfPZHouKdA8fi6QFoE2SiXIoUVJwRu_BzPeRCbnLyKiSjTk4_rIJLMZPgzg5IJpfcKXomgNO1dhaD-y051OMEPCuepA5ltW&key=AIzaSyALbZzYBBII4dB8eXwSTqHj9TstnV4o4A0", Date()),
            ("Calgary", 51.0501, -114.0853, 16.03, 67, "Clouds", "https://openweathermap.org/img/wn/02n@2x.png", 9.252, "https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=AUacShg5ROOdFrCzKiA6MI8VR_6psdKQqW1-ApNZLZrRRdNr3RBwwDu0_qtvKUyZPMRViiJLYsYMgX42i9YeaMtyBT87wtqIZtp8rOv_ciRe2vkrYWW7qDUzdhQEVzMAYjUlOHgf1cH1D5QaDdNcSsnnYdVUnMVpqR83Fmof92Hp0Tg2ZPVP&key=AIzaSyALbZzYBBII4dB8eXwSTqHj9TstnV4o4A0", Date()),
            ("Vancouver", 49.2497, -123.1193, 19.95, 75, "Clouds", "https://openweathermap.org/img/wn/04n@2x.png", 16.092, "https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=AUacShhiicOFKYYAQcW8qsZ_St1GAotHYjuDbbKyK9mzuay1eR3Y8cF52PJSsAEDiKpoYjOQIAVvtKkbizxoLWAQgkx0I3CnU-XByXF52DzXD8-ecQDpM7y8_wnXDeqzZ1Dgi5rUA_oAyIYiskMckeg5LXJxBr1mlBp4A6xFjQjdpxBVQNI&key=AIzaSyALbZzYBBII4dB8eXwSTqHj9TstnV4o4A0", Date()),
            ("Toronto", 43.7001, -79.4163, 16.38, 81, "Clear", "https://openweathermap.org/img/wn/01n@2x.png", 12.96, "https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=AUacShgxkxJ6sGzSWJhTt7oDvZZSYQ9APx5VvizDkx6LiPafWFwWVLgA30tGQb2gz9O_Z4C4l_oX4VGznkBDrfqekHqtvcgRPtNd0ZNYALpgHKDn_Eq8YJofzMbkBCFc4yR8odnzMMiAirJfPVBL8bguYIjMgknixBwrBcNa2FzDQKW5KKV7&key=AIzaSyALbZzYBBII4dB8eXwSTqHj9TstnV4o4A0", Date()),
            ("Waterloo", 43.4668, -80.5164, 12.73, 100, "Mist", "https://openweathermap.org/img/wn/50n@2x.png", 3.708, "https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=AUacShgTa_df1B9A_eodEsEDdr7HTjQgOYwUSEQzL2eUxnMZgL0htJsC3Gl1-Vroqic-FF3NmRjvA-Sv98dRgkaO2OJwTBTsqpdnEN711HDQHRzmKhXhI6C5hMi0TZk4xarAphvqYs7rTWtV1BjcrQsZezQCH1zgvXY1vb4eXQioCPfF29Hu&key=AIzaSyALbZzYBBII4dB8eXwSTqHj9TstnV4o4A0", Date())
        ]

        // Insert the data into the Core Data database
        for placeData in placeDataArray {
            let newPlaceData = PlaceData(context: managedContext)
            newPlaceData.id = UUID()
            newPlaceData.name = placeData.name
            newPlaceData.latitude = placeData.latitude
            newPlaceData.longitude = placeData.longitude
            newPlaceData.temperature = placeData.temperature
            newPlaceData.humidity = placeData.humidity
            newPlaceData.weatherDescription = placeData.weatherDescription
            newPlaceData.weatherIconUrl = placeData.weatherIconUrl
            newPlaceData.windSpeed = placeData.windSpeed
            newPlaceData.photoUrl = placeData.photoUrl
            newPlaceData.createdAt = placeData.createdAt
        }

        // Save the context to persist the data
        do {
            try managedContext.save()
            print("Data inserted successfully.")
        } catch {
            print("Error inserting data: \(error)")
        }
    }
    

    @NSManaged public var humidity: Double
    @NSManaged public var id: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var photoUrl: String?
    @NSManaged public var temperature: Double
    @NSManaged public var weatherDescription: String?
    @NSManaged public var weatherIconUrl: String?
    @NSManaged public var windSpeed: Double
    @NSManaged public var createdAt: Date?

}

extension PlaceData : Identifiable {

}
