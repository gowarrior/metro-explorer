//
//  FetchLandmarksManager.swift
//  Metro Explorer
//
//  Created by XYZ on 11/24/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import Foundation

protocol FetchLandmarksDelegate {
    func landmarksFound(_ landmarks: [MLandmark])
    func landmarksNotFound(reason: FetchLandmarksManager.FailureReason)
    
}

class FetchLandmarksManager{
    
    enum FailureReason: String {
        case noResponse = "No response received" //allow the user to try again
        case non200Response = "Bad response" //give up
        case noData = "No data recieved" //give up
        case badData = "Bad data" //give up
    }
    
    var delegate: FetchLandmarksDelegate?
    
    func fetchLandmarks(latitude : Double, longtitude : Double){
        var urlComponents = URLComponents(string: "https://api.yelp.com/v3/businesses/search")!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(longtitude)"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "categories", value: "landmarks")
        ]
        
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        request.addValue("Bearer Hj4VMN1dEecXe-hJ2F7QCIxc2fYuGtOdRC_mbVAt76wqALV25lVUuyGc50OI8akXbPDS3xGLNVdkw5_XlSLuAA2YpSKk8btb5qV4HYOGjOvRveU7-uFqqgYX18n5W3Yx", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //CODE HERE TO RUN UPON COMPLETION
            print("request complete")
            
            guard let response = response as? HTTPURLResponse else {
                print("response is nil or 200")
                
                self.delegate?.landmarksNotFound(reason: .noResponse)
                
                return
            }
            
            guard response.statusCode == 200 else {
                self.delegate?.landmarksNotFound(reason: .non200Response)
                return
            }
            //HERE - response is NOT nil and IS 200
            
            guard let data = data else {
                print("data is nil")
                
                self.delegate?.landmarksNotFound(reason: .noData)
                
                return
            }
            
            //HERE - data is NOT nil
            
            let decoder = JSONDecoder()
            
            do {
                let landmarksResponse = try decoder.decode(LandmarksResponse.self, from: data)
                
                //HERE - decoding was successful
                
                var landmarks = [MLandmark]()
                
                for  lan in landmarksResponse.businesses {
                    let id = lan.id
                    let name = lan.name
                    let lat = lan.coordinates.latitude
                    let lon = lan.coordinates.longitude
     
                    let address = lan.location.displayAddress.joined(separator: ",")
                    
                    let rating = lan.rating
                    let imageU = lan.imageURL
                    var imageUrl : String? = nil
                    if let imageUr = imageU {
                        imageUrl = imageUr
                    }
                    //before colon is the name of the pararmeter will be; after colon is the variable we put in
                    let landmark = MLandmark(id : id, name: name, lat: lat, lon: lon, address : address, imageUrl : imageUrl, rating : rating)
                    
                    landmarks.append(landmark)
                }
                
                //we get the landmarks and put into landmarksFound method as parameter
                print(landmarks)
                
                self.delegate?.landmarksFound(landmarks)
                
            } catch let error {
                //if we get here, need to set a breakpoint and inspect the error to see where there is a mismatch between JSON and our Codable model structs
                print("codable failed - bad data format")
                print(error.localizedDescription)
                
                self.delegate?.landmarksNotFound(reason: .badData)
            }
        }
        print("execute request")
        task.resume()
    }
}
