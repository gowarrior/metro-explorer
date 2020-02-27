//
//  LocationDetector.swift
//  Metro Explorer
//
//  Created by XYZ on 11/20/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import Foundation
import CoreLocation
import MBProgressHUD

protocol LocationDetectorDelegate {
    func locationDetected(latitude: Double, longitude: Double)
    func locationNotDetected(reason : LocationDetector.FailureReason)
}

 class LocationDetector: NSObject {
   
    enum FailureReason: String {
        case noPermission = "Please give permission in the setting" //give up
        case timeout = "Bad Network or Check your permission" //give up
    }
    
    var locationTimer: Timer!
    let locationManager = CLLocationManager()
    
    var delegate: LocationDetectorDelegate?
    
    override init() {
        super.init()
    }
    
    func findLocation() {
        let permissionStatus = CLLocationManager.authorizationStatus()
        locationManager.delegate = self
        //handle permission cases
        switch(permissionStatus) {
            
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                delegate?.locationNotDetected(reason: .noPermission)
            case .denied:
                delegate?.locationNotDetected(reason: .noPermission)
            case .authorizedAlways:
                break
            case .authorizedWhenInUse:
                locationManager.requestLocation()
                //use timer to limit time to 10s
                locationTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)

        }
    }
    
    @objc  func runTimedCode() {
        locationManager.stopUpdatingLocation()
        delegate?.locationNotDetected(reason: .timeout)
        
    }
}

extension LocationDetector: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get the latest location
        if let location = locations.last {
            locationTimer.invalidate()
            locationManager.stopUpdatingLocation()
            
            delegate?.locationDetected(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //handle the error
        print(error.localizedDescription)
        delegate?.locationNotDetected(reason : .timeout)

    }
    
    //this gets called after user accepts OR denies permission
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //handle this
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
        else {
            delegate?.locationNotDetected(reason: .noPermission)
        }
    }
    
}
