import UIKit
import CoreLocation


final class WeatherViewController: UIViewController {
    
    @IBOutlet private var conditionImageView: UIImageView!
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var cityLabel: UILabel!
    @IBOutlet private var searchTextField: UITextField!
    
    private var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        

        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
    }
    
    @IBAction func locationButton(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
}

// MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
        print(searchTextField.text!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        print(textField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {return true} else {textField.placeholder="Мало текста"
            return false}
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Use search field to check weather
        if let city = textField.text {
            weatherManager.fetchWeather(cityName: city)
        }
        textField.text=""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager:WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text=weather.temperatureString
            self.cityLabel.text=weather.cityName
            self.conditionImageView.image=UIImage(systemName: weather.conditionName)
        }
    }
    
    func didFailWithErrorWeather(error: Error) {
        print(error)
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else {return}
        locationManager.stopUpdatingLocation() // не продолжает получать координаты бесконечно
        print (location.latitude)
        print (location.longitude)
        weatherManager.fetchWeather(String(location.latitude), String(location.longitude))
    }
    
    func locationManager (_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
}
