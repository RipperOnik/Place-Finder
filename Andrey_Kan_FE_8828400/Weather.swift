//
//  Weather.swift
//  Andrey_Kan_FE_8828400
//
//  Created by Andrey Kan on 05.08.2023.
//

import UIKit

class Weather: UIViewController {
    
    @IBOutlet weak var cityName: UILabel!
    
    @IBOutlet weak var weatherType: UILabel!
    
    @IBOutlet weak var weatherIcon: UIImageView!
    
    @IBOutlet weak var temperature: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var wind: UILabel!
    
    @IBOutlet weak var locationTextView: UITextView!
    
    
    var place: PlaceData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // receive data from Main 
        if let placeData = place {
            cityName.text = placeData.name
            weatherType.text = placeData.weatherDescription
            temperature.text = "\(placeData.temperature) °"
            humidity.text = "Humidity: \(placeData.humidity)%"
            wind.text = "Wind: \(round(placeData.windSpeed * 100) / 100) km/h"
            
            let cityLabel = "City: \(placeData.name ?? "cityName")"
            let latitude = "Latitude: \(placeData.latitude)"
            let longitude = "Longitude: \(placeData.longitude)"
            
            locationTextView.text! = cityLabel + "\n" + longitude + "\n" + latitude
            
            
            let iconUrl = URL(string: placeData.weatherIconUrl!)
            if let iconUrl = iconUrl {
                self.weatherIcon.load(url: iconUrl)
            }
        }

        
    }
    
}

extension UIImageView {
    func load(url: URL) {
        let dataTask = URLSession.shared.dataTask(with: url) {data, response, error in
            if let data = data {
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
        dataTask.resume()
    }
}

