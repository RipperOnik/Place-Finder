//
//  ViewController.swift
//  Andrey_Kan_FE_8828400
//
//  Created by Andrey Kan on 05.08.2023.
//

import UIKit

class Main: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var searchInput: UITextField!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var weatherBtn: UIButton!
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var historyBtn: UIBarButtonItem!
    
    let content = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var lastPlace: PlaceData?
    
    var WEATHER_API_KEY: String? = nil
    var GOOGLE_API_KEY: String? = nil
    
    
    func initKeys() async{
        if let plistPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let plistData = FileManager.default.contents(atPath: plistPath) {
            
            do {
                if let config = try PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any] {
                    if let weatherApiKey = config["WEATHER_API_KEY"] as? String {
                        WEATHER_API_KEY = weatherApiKey
                    }
                    
                    if let googleAPIKey = config["GOOGLE_API_KEY"] as? String {
                        GOOGLE_API_KEY = googleAPIKey
                    }
                }
            } catch {
                print("Error reading plist: \(error.localizedDescription)")
            }
        }
    }
    
    
    var preloadedData = false
    
    
    override func viewDidLoad() {
        messageLabel.text = ""
        super.viewDidLoad()
        searchInput.delegate = self
        
        weatherBtn.isEnabled = false
        mapBtn.isEnabled = false
        Task {
            await initKeys()
        }
        
        
        
        if(PlaceData.getCount() >= 5){
            // don't preload data twice during the app run
            preloadedData = true
        }
        if(!preloadedData){
            // preload data only if there are less than 5 rows
            prepopulateData()
            // don't preload data twice during the app run
            preloadedData = true
        }
        
      
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeleteNotification(_:)), name: .onDeleteItemNotify, object: nil)
    }
    
    // clear input data if user deleted any search history item to prevent nil errors
    @objc func handleDeleteNotification(_ notification: Notification) {
        weatherBtn.isEnabled = false
        mapBtn.isEnabled = false
        lastPlace = nil
        searchInput.text = ""
    }
    

    
    func renderError(){
        DispatchQueue.main.async {
            self.messageLabel.textColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1)
            self.messageLabel.text = "City not found"
            // disable these buttons so that user could not get data on non-existing city
            self.weatherBtn.isEnabled = false
            self.mapBtn.isEnabled = false
            self.historyBtn.isEnabled = true
            // roll back uncommited changes
            self.content.rollback()
        }
    }
    
    func prepopulateData(){
        let placesCount = PlaceData.getCount()
        
        if(placesCount < 5){
            PlaceData.insertInitialData()
        }
    }
    
    
    
    // get weather data using openweather api
    func getPlaceData(city: String){
        // disable the history button while fetching data
        historyBtn.isEnabled = false
        messageLabel.text = ""
        
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(WEATHER_API_KEY!)&units=metric"
        
        let url = URL(string: urlString)
        if let url = url {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.renderError()
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
                        self.renderError()
                    }
                }
            }
            dataTask.resume()
        }
    }
    // google place api
    func getPlace(city: String, place: PlaceData){
    
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(city)&types=(cities)&key=\(GOOGLE_API_KEY!)&language=en"
        
        let url = URL(string: urlString)
        if let url = url {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.renderError()
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
                        self.renderError()
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    // google place details api
    func getPlaceDetails(placeId: String, place: PlaceData){
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=photo&key=\(GOOGLE_API_KEY!)&language=en"
        
        let url = URL(string: urlString)
        if let url = url {
            let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.renderError()
                }
                else if let data = data{
                    
                    do {
                        let readableData = try JSONDecoder().decode(PlaceDetails.self, from: data)
             
                        // using photo reference, we can get a place photo url
                        let photoReference = readableData.result.photos[0].photoReference
                        // google place photo api url
                        let photoUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=500&photoreference=\(photoReference)&key=\(self.GOOGLE_API_KEY!)"
                        
                        // save photo url to database
                        place.photoUrl = photoUrl
                        
                        // set the last place for Weather and Map pages
                        self.lastPlace = place
                        
                        // finally, commit the saved data to database
                        do {
                            try self.content.save()
                        } catch{
                            print("Error saving data")
                        }
                        // notify History page that new data was added to database
                        self.sendNotificationToHistory()
                        
                        // once we get data saved to database, we can reveal the navigation buttons
                        DispatchQueue.main.async {
                            self.weatherBtn.isEnabled = true
                            self.mapBtn.isEnabled = true
                            self.historyBtn.isEnabled = true
                            self.messageLabel.textColor = UIColor(red: 0, green: 255, blue: 0, alpha: 1)
                            self.messageLabel.text = "City has been found"
                        }
                
                    }
                    catch{
                        self.renderError()
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    func sendNotificationToHistory() {
        NotificationCenter.default.post(name: .onAddNewSearchNotify, object: nil)
    }
        
    
    // once any navigation buttons are pressed, we will send the last searched place to other view controllers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "FromMainToWeather" {
                if let destinationVC = segue.destination as? Weather {
                    destinationVC.place = lastPlace
                }
        }
        else if segue.identifier == "FromMainToMap" {
                if let destinationVC = segue.destination as? Map {
                    destinationVC.place = lastPlace
                }
        }
    }
    
    @IBAction func searchButton(_ sender: UIButton) {
        
        let cityToSearch = prepareText(text: searchInput.text!)
        
        
        getPlaceData(city: cityToSearch)
    }
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        let cityToSearch = prepareText(text: textField.text!)
        
        
        getPlaceData(city: cityToSearch)
        
        return true
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
    /**
     * Called when the user click on the view (outside the UITextField).
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}





extension Notification.Name {
    static let onAddNewSearchNotify = Notification.Name("MainToHistoryCommunication")
    static let onDeleteItemNotify = Notification.Name("HistoryToMainCommunication")
}
