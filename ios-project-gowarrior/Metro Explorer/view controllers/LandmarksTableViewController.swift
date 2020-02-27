//
//  LandmarksUITableTableViewController.swift
//  Metro Explorer
//
//  Created by XYZ on 11/20/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreLocation

class LandmarksTableViewController: UITableViewController {
    
    let locationDetector = LocationDetector()
    let fetchLandmarksManager =  FetchLandmarksManager()
    let fetchMetroStationsManager = FetchMetroStationsManager()
    
    //flag for determining which what kind of data it wants to load
    var flag = 2, lat = 38.900140, lon = -77.049447, name :String? = nil
    
    var stations : [MStation] = []
    
    var landmarks = [MLandmark](){
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchLandmarksManager.delegate = self
        fetchMetroStationsManager.delegate = self
        if flag == 0 {
            print(flag)
            getLoc()
        }
        if flag == 2 {
            fetchLandmarksManager.fetchLandmarks(latitude: self.lat, longtitude: self.lon)
            title = name
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if flag == 1 {
            self.landmarks = PersistenceManager.sharedInstance.fetchFavorites()
            title = "Favorites"
        }
    }
    
    private func getLoc() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        locationDetector.delegate = self
        locationDetector.findLocation()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return landmarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "landmarkCell", for: indexPath) as! LandmarkTableViewCell
        
        let landmark = landmarks[indexPath.row]
        cell.landmarkNameLabel.text = landmark.name
        
        if let imageUrlString = landmark.imageUrl, let url = URL(string: imageUrlString) {
            cell.landmarkImage.load(url: url)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "landmarkDetailSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass the data to your next view controller
        let row = sender as! Int
        
        let vc = segue.destination as! LandmarkDetailViewController
        vc.landmark = landmarks[row]
    }

}

extension LandmarksTableViewController: FetchLandmarksDelegate {
    func landmarksFound(_ landmarks: [MLandmark]) {
        print("landmarks found - here they are in the controller!")
        print(landmarks.count)
        DispatchQueue.main.async {
            self.landmarks = landmarks
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    func landmarksNotFound(reason: FetchLandmarksManager.FailureReason) {
        print("no landmarks found")
        
        MBProgressHUD.hide(for: self.view, animated: true)
        let alertController = UIAlertController(title: "Problem fetching landmarks", message: reason.rawValue, preferredStyle: .alert)
        
        switch(reason) {
        case .noResponse:
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                if self.flag == 0 {
                    self.getLoc()
                }
                if self.flag == 2 {
                    self.fetchLandmarksManager.fetchLandmarks(latitude: self.lat, longtitude: self.lon)
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
            
            alertController.addAction(cancelAction)
            alertController.addAction(retryAction)
            
        case .non200Response, .noData, .badData:
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler:nil)
            
            alertController.addAction(okayAction)
        }
        
    }
}

extension LandmarksTableViewController: LocationDetectorDelegate {
    func locationDetected(latitude: Double, longitude: Double) {
        fetchMetroStationsManager.fetchStations()
        lat = latitude
        lon = longitude
    }
    
    func locationNotDetected(reason : LocationDetector.FailureReason) {
        print("no location found :(")
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let alertController = UIAlertController(title: "Problem fetching location", message: reason.rawValue, preferredStyle: .alert)
            
            switch(reason) {
                case .timeout:
                    let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                        self.getLoc()
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(retryAction)
                
                case .noPermission:
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler:nil)
                    
                    alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension LandmarksTableViewController: FetchStationsDelegate {
    func stationsFound(_ stations: [MStation]) {
        DispatchQueue.main.async {
            print("stations found - here they are in the controller!")
            print(stations.count)
            self.stations = stations //get the value of stations
            var distanceInMeters = Double.greatestFiniteMagnitude;
            var stn : MStation? = nil
            for station in self.stations {
                let coordinate0 = CLLocation(latitude: self.lat, longitude: self.lon)
                let coordinate1 = CLLocation(latitude: station.lat, longitude: station.lon)
                let temp = coordinate0.distance(from: coordinate1)
                if (temp < distanceInMeters) {
                    distanceInMeters = temp
                    stn = station
                }
            }
            if let latDouble = stn?.lat, let lonDouble = stn?.lon {
                self.title = stn?.name
                self.fetchLandmarksManager.fetchLandmarks(latitude: latDouble, longtitude: lonDouble)
            }
            
        }
        
    }
    
    func stationsNotFound(reason : FetchMetroStationsManager.FailureReason) {
        print("no stations found")
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let alertController = UIAlertController(title: "Problem fetching stations", message: reason.rawValue, preferredStyle: .alert)
            
            switch(reason) {
            case .noResponse:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.getLoc()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler:nil)
                
                alertController.addAction(cancelAction)
                alertController.addAction(retryAction)
                
            case .non200Response, .noData, .badData:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler:nil)
                
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
}
