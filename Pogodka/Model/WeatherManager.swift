import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithErrorWeather(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=71750e02fb1ada6e41327e47921b66b5&units=metric" // please dont abuse my key thx
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(_ latitude:String, _ longitude:String) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString:String) {
        // 1. Create URL
        guard let url = URL(string: urlString) else {return}
        // 2. Create URLSession
        let session = URLSession(configuration: .default)
        // 3. Give URLSession a task (if you press Enter on auto-completion it reformats it into trailing Closure)
        let task = session.dataTask(with: url) { data, _, error in
            if error != nil
            {
                delegate?.didFailWithErrorWeather(error: error!)
            }
            if let data = data, let weather = parseJSON(data) {
                delegate?.didUpdateWeather(self, weather: weather)
            }
        }
            // 4. Start the task
            task.resume()
        }
        
        func parseJSON(_ weatherData: Data) -> WeatherModel? {
            let decoder = JSONDecoder()
            do { let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
                let id = decodedData.weather[0].id
                let temp = decodedData.main.temp
                let name = decodedData.name
                
                let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
                return weather
                
                
            } catch {
                delegate?.didFailWithErrorWeather(error: error)
                return nil
            }
        }
    }
