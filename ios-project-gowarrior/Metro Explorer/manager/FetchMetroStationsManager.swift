//
//  FetchMetroStationsManager.swift
//  Metro Explorer
//
//  Created by XYZ on 11/21/18.
//  Copyright © 2018 XYZ. All rights reserved.
import Foundation

protocol FetchStationsDelegate {
    func stationsFound(_ stations : [MStation])
    func stationsNotFound(reason : FetchMetroStationsManager.FailureReason)
}

class FetchMetroStationsManager {
    
    enum FailureReason: String {
        case noResponse = "No response received" //allow the user to try again
        case non200Response = "Bad response" //give up
        case noData = "No data recieved" //give up
        case badData = "Bad data" //give up
    }
    
    var delegate: FetchStationsDelegate?
    
    func fetchStations(){
        let urlComponents = URLComponents(string: "https://api.wmata.com/Rail.svc/json/jStations")!
        
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("9544b2246e82413fb86045a5b0c799d3", forHTTPHeaderField: "api_key")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //CODE HERE IS TO RUN UPON COMPLETION
            print("request complete")
            
            guard let response = response as? HTTPURLResponse else {
                print("response is nil")
                
                self.delegate?.stationsNotFound(reason: .noResponse)
                
                return
            }
            guard response.statusCode == 200 else {
                self.delegate?.stationsNotFound(reason: .non200Response)
                
                return
            }
            
            //HERE - response is NOT nil and IS 200
            guard let data = data else {
                print("data is nil")
                
                self.delegate?.stationsNotFound(reason: .noData)
                
                return
            }
            
            //HERE - data is NOT nil
            
            let decoder = JSONDecoder()
            
            do {
                let metroStationsResponse = try decoder.decode(MetroStationsResponse.self, from: data)
                
                //HERE - decoding was successful
                //print(metroStationsResponse.Stations)
                
                var stations = [MStation]()
                
                for stn in metroStationsResponse.Stations {
                    let name = stn.Name
                    
                    let lon = stn.Lon
                    let lat = stn.Lat
                    
                    let station = MStation(name: name, lat: lat, lon: lon)
                    
                    stations.append(station)
                }
                
                //put the stations into stationsFound()
                self.delegate?.stationsFound(stations)
                
                
            } catch let error {
                //if we get here, need to set a breakpoint and inspect the error to see where there is a mismatch between JSON and our Codable model structs
                print("codable failed - bad data format")
                print(error.localizedDescription)
                
                self.delegate?.stationsNotFound(reason: .badData)
            }
        }
        print("execute request")
        task.resume()
    }
    
}
