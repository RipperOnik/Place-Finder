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
    
    
    
    
    var place: PlaceData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // receive data from Main 
        if let placeData = place {
            cityName.text = placeData.name
            weatherType.text = placeData.weatherDescription
            temperature.text = "\(placeData.temperature) °"
            humidity.text = "\(placeData.humidity)%"
            wind.text = "\(round(placeData.windSpeed * 100) / 100) km/h"
            
            
            
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

