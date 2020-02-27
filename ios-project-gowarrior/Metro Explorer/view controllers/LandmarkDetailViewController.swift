//
//  LandmarkDetailViewController.swift
//  Metro Explorer
//
//  Created by XYZ on 12/7/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import UIKit

class LandmarkDetailViewController: UIViewController {
    
    let image1 = UIImage(named: "baseline_star_border_black_18dp.png") as UIImage?
    let image2 = UIImage(named: "baseline_star_black_18dp.png") as UIImage?
    let image3 = UIImage(named: "route.png") as UIImage?
    var landmark : MLandmark? = nil

    @IBOutlet weak var detailNameLabel: UILabel!
    
    @IBOutlet weak var detailAdressLabel: UILabel!
    @IBOutlet weak var detailRatingLabel: UILabel!
    
    @IBOutlet weak var landmarkDetailImage: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    @IBOutlet weak var routeButton: UIBarButtonItem!
    @IBAction func favoriteButtonPressed(_ sender: Any) {
        if let tempLandmark = landmark {
            if (PersistenceManager.sharedInstance.ifFavorites(favoriteLandmark: tempLandmark)){
                favoriteButton?.setBackgroundImage(image1, for: .normal, barMetrics: .default)
                PersistenceManager.sharedInstance.updateFavorite(favoriteLandmark: tempLandmark)
            } else {
                favoriteButton?.setBackgroundImage(image2, for: .normal, barMetrics: .default)
                PersistenceManager.sharedInstance.updateFavorite(favoriteLandmark: tempLandmark)
            }
        }
    }
    
    @IBAction func shareButtonPressed(_ sender: Any) {
        var shareText = ""//Is there better way to initializa it?
        if let name = landmark?.name, let address = landmark?.address {
            shareText = "Check out this great landmark near you: \(name) at \(address)!!!"
        }
        
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func showRouteButtonPressed(_ sender: Any) {
        if let lat = landmark?.lat, let lon = landmark?.lon, let url = URL(string : "http://maps.apple.com/?daddr=\(lat),\(lon)&dirflg=r"){
            print("lat: \(lat), lon: \(lon)")
            UIApplication.shared.openURL(url)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tempLandmark = landmark {
            if (PersistenceManager.sharedInstance.ifFavorites(favoriteLandmark: tempLandmark)){
                favoriteButton?.setBackgroundImage(image2, for: .normal, barMetrics: .default)
            } else {
                favoriteButton?.setBackgroundImage(image1, for: .normal, barMetrics: .default)
            }
        }
        
        if let name = landmark?.name, let address = landmark?.address {
            detailNameLabel.text = "Name: \(name)"
            detailAdressLabel.text = "Address: \(address)"
            title = name
        }
        
        if let temp = landmark?.rating {
            let rating = String(temp)
            detailRatingLabel.text = "Rating : \(rating)"
        }
        
        if let landmark = landmark, let imageUrlString = landmark.imageUrl, let url = URL(string: imageUrlString) {
            landmarkDetailImage.load(url: url)
        }
    }
    
}
