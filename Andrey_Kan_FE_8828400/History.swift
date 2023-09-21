//
//  History.swift
//  Andrey_Kan_FE_8828400
//
//  Created by Andrey Kan on 05.08.2023.
//

import UIKit
import CoreData

class History: UITableViewController {
    
    
    
    @IBOutlet var placeTableView: UITableView!
    
    var places: [PlaceData]?
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var chosenPlace: PlaceData?
    
    let WEATHER_API_KEY = "f1414c275309b59308bf1b11c2d64963"
    let GOOGLE_API_KEY = "AIzaSyALbZzYBBII4dB8eXwSTqHj9TstnV4o4A0"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeTableView.delegate = self
        placeTableView.dataSource = self
        

        
  
        // add notification listener to fetch data from DB when new search is performed in the Main view controller
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: .onAddNewSearchNotify, object: nil)

        // fetch all places from DB
        fetchPlaces()
        
    }
    
    
    
    func fetchPlaces(){
        do {
            self.places = try content.fetch(PlaceData.fetchChronologicalRequest())
            DispatchQueue.main.async {
                self.placeTableView.reloadData()
            }
        }catch{
            print("No Data")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return places?.count ?? 0
    }
    
    // set row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200.0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
        
        if places?.count ?? 0 == 0{
            return cell
            
        }
        // set cell labels
        let place = self.places![indexPath.row]
        
        
        cell.cityName.text = "\(place.name ?? "cityName")"
        
        
        // set cell image
        if let photoUrlString = place.photoUrl{
            let photoUrl = URL(string: photoUrlString)
            if let photoUrl = photoUrl {
                cell.img.load(url: photoUrl)
            }else{
                cell.img.image = UIImage(named: "defaultCityImage")
            }
            
        }else{
            cell.img.image = UIImage(named: "defaultCityImage")
        }

        // set cell button actions for navigation
        cell.mapBtn.addTarget(self, action: #selector(navigateToMap(_:)), for: .touchUpInside)
        // send the index row to get the relevant place to send to another view controller
        cell.mapBtn.tag = indexPath.row
        
        cell.weatherBtn.addTarget(self, action: #selector(navigateToWeather(_:)), for: .touchUpInside)
        cell.weatherBtn.tag = indexPath.row
        return cell
    }
    
    // set the chosen place to pass it to other view controllers
    func choosePlace(index: Int){
        let place = places![index]
        chosenPlace = place
    }
    
    // button action for navigating to mao
    @objc func navigateToMap(_ sender: UIButton) {
        choosePlace(index: sender.tag)
        self.performSegue(withIdentifier: "FromHistoryToMap", sender: self)
    }
    // button action for navigating to weather
    @objc func navigateToWeather(_ sender: UIButton) {
        choosePlace(index: sender.tag)
        self.performSegue(withIdentifier: "FromHistoryToWeather", sender: self)
    }
    
    // prepare data before navigating
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FromHistoryToWeather" {
            if let destinationVC = segue.destination as? Weather {
                destinationVC.place = chosenPlace
            }
        }
        else if segue.identifier == "FromHistoryToMap" {
            if let destinationVC = segue.destination as? Map {
                destinationVC.place = chosenPlace
            }
        }
    }
    
    // delete row 
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let placeToRemove = self.places![indexPath.row]
            self.content.delete(placeToRemove)
            self.places?.remove(at: indexPath.row)
            self.placeTableView.deleteRows(at: [indexPath], with: .fade)
            // notify main page that item was deleted
            NotificationCenter.default.post(name: .onDeleteItemNotify, object: nil)
            
            do{
                try self.content.save()
                // fetch new data
                fetchPlaces()
            }catch{
                print("Error saving data")
            }
   
        }
    }
    
    // fetch new places when notification received from Main
    @objc func handleNotification(_ notification: Notification) {
        fetchPlaces()
    }
    
    func prepareText(text: String) -> String{
        // trim
        let trimmedCity = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var cityToSearch = trimmedCity
        let words = trimmedCity.split(separator: " ")
        
        if(words.count > 1){
            // if a city consists of 2 words, concatenate them with %20 so that it is able to be searched
            cityToSearch = words.joined(separator: "%20")
        }
        return cityToSearch
    }
    
    
    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        // create alert
        let alert = UIAlertController(title: "Search City", message: "What is the city name", preferredStyle: .alert)

        alert.addTextField { textField1   in
            textField1.placeholder = "city name"
        }
        
        let submitButton = UIAlertAction(title: "Search", style: .default){ action in

            let cityToSearch = self.prepareText(text: alert.textFields![0].text!)
            
            // get data from api
            self.getPlaceData(city: cityToSearch)

        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(submitButton)
        alert.addAction(cancelButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // show popup error if city not found
    func showErrorPopup(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "City not found", preferredStyle: .alert)
            let submitButton = UIAlertAction(title: "Ok", style: .default)
            
            alert.addAction(submitButton)
            self.present(alert, animated: true, completion: nil)
            // roll back uncommited changes
            self.content.rollback()
        }
    }
    
    
    
    
    // get weather data using openweather api
    func getPlaceData(city: String){
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(WEATHER_API_KEY)&units=metric"
        
        let url = URL(string: urlString)
        if let url = url {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.showErrorPopup()
                }
                else if let data = data{
                    do {
                        let readableData = try JSONDecoder().decode(WeatherData.self, from: data)
                        
                        // create a place object to save it later to database once we get all the neccesary data from API
                        let place = PlaceData(context: self.content)
                        
                        place.id = UUID()
                        place.latitude = readableData.coord.lat
                        place.longitude = readableData.coord.lon
                        place.humidity = Double(readableData.main.humidity)
                        place.name = readableData.name
                        place.temperature = readableData.main.temp
                        place.windSpeed = readableData.wind.speed * 3.6
                        place.weatherDescription = readableData.weather[0].main
                        place.createdAt = Date()
                        let iconCode = readableData.weather[0].icon
                        let iconUrlString = "https://openweathermap.org/img/wn/\(iconCode)@2x.png"
                        place.weatherIconUrl = iconUrlString
                        
                        // get place id using google api once we get data from weather api
                        self.getPlace(city: city, place: place)
                    }
                    catch{
                        self.showErrorPopup()
                    }
                }
            }
            dataTask.resume()
        }
    }
    // google place api
    func getPlace(city: String, place: PlaceData){
    
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(city)&types=(cities)&key=\(GOOGLE_API_KEY)&language=en"
        
        let url = URL(string: urlString)
        if let url = url {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.showErrorPopup()
                }
                else if let data = data{
                    
                    do {
                        let readableData = try JSONDecoder().decode(Place.self, from: data)
                        
                        // this field is needed to get the place details
                        let placeId = readableData.predictions[0].placeID
                        
                        // get photo reference using google api
                        self.getPlaceDetails(placeId: placeId, place: place)
                        
                
                    }
                    catch{
                        self.showErrorPopup()
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    // google place details api
    func getPlaceDetails(placeId: String, place: PlaceData){
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=photo&key=\(GOOGLE_API_KEY)&language=en"
        
        let url = URL(string: urlString)
        if let url = url {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.showErrorPopup()
                }
                else if let data = data{
                    
                    do {
                        let readableData = try JSONDecoder().decode(PlaceDetails.self, from: data)
             
                        // using photo reference, we can get a place photo url
                        let photoReference = readableData.result.photos[0].photoReference
                        // google place photo api url
                        let photoUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=\(photoReference)&key=\(self.GOOGLE_API_KEY)"
                        print(photoUrl)
                        
                        // save photo url to database
                        place.photoUrl = photoUrl
                        
                        
                        // finally, commit the saved data to database
                        do {
                            try self.content.save()
                            self.fetchPlaces()
                        } catch{
                            print("Error saving data")
                        }

                    }
                    catch{
                        self.showErrorPopup()
                    }
                }
            }
            dataTask.resume()
        }
    }
    
}
