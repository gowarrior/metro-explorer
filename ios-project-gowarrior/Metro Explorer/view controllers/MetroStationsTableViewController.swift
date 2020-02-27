//
//  MetroStationsTableViewController.swift
//  Metro Explorer
//
//  Created by XYZ on 11/22/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import UIKit
import MBProgressHUD

class MetroStationsTableViewController: UITableViewController {
    
    let fetchMetroStationsManager = FetchMetroStationsManager()
    var stations = [MStation]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchMetroStationsManager.delegate = self
        fetchStns()
        title = "Select a Station"
    }

    // MARK: - Table view data source
    private func fetchStns(){
        MBProgressHUD.showAdded(to: self.view, animated: true)
        fetchMetroStationsManager.fetchStations()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #return the number of rows
        return stations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationCell", for: indexPath)
        as! StationTableViewCell
        
        let stn = stations[indexPath.row]
        
        cell.metroNameLabel.text = stn.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "metroLandmarkSegue", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //pass the data to next view controller
        
        let row = sender as! Int
        
        let vc = segue.destination as! LandmarksTableViewController
        vc.lon = stations[row].lon
        vc.lat = stations[row].lat
        vc.name = stations[row].name
        vc.flag = 2
    }
}

//extension is for protocal conform and implementation
extension MetroStationsTableViewController: FetchStationsDelegate {
    func stationsFound(_ stations: [MStation]) {
        DispatchQueue.main.async {
            print("stations found - here they are in the controller!")
            print(stations.count)
            self.stations = stations //get the value of stations
            MBProgressHUD.hide(for: self.view, animated: true)
        }

    }
    
    func stationsNotFound(reason : FetchMetroStationsManager.FailureReason) {
        print("no stations found")
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            //prompts dialogue for users
            let alertController = UIAlertController(title: "Problem fetching gyms", message: reason.rawValue, preferredStyle: .alert)
            
            switch(reason) {
            case .noResponse:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                    self.fetchStns()
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

