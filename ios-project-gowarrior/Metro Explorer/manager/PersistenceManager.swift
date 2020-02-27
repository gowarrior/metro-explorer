//
//  PersistenceManager.swift
//  Metro Explorer
//
//  Created by XYZ on 12/7/18.
//  Copyright © 2018 XYZ. All rights reserved.
//

import Foundation
import UIKit

class PersistenceManager {
    static let sharedInstance = PersistenceManager()
    
    let favoritesKey = "favorites"
    
    func updateFavorite(favoriteLandmark: MLandmark) {
        let userDefaults = UserDefaults.standard
        
        var favorites = fetchFavorites()
        
        if favorites.contains(where: { $0.id == "\(favoriteLandmark.id)" }) {
            if let index = favorites.firstIndex(where: { $0.id == "\(favoriteLandmark.id)"}){
                favorites.remove(at: index)
            }
        } else {
            favorites.append(favoriteLandmark)
        }
        
        let encoder = JSONEncoder()
        let encodedFavorites = try? encoder.encode(favorites) 
        
        userDefaults.set(encodedFavorites, forKey: favoritesKey)
    }
    
    func ifFavorites(favoriteLandmark: MLandmark) -> Bool {
        //let userDefaults = UserDefaults.standard
        
        let favorites = fetchFavorites()
        
        if favorites.contains(where: { $0.id == "\(favoriteLandmark.id)" }) {
            return true
        } else {
            return false
        }
        
    }
    
    func fetchFavorites() -> [MLandmark] {
        let userDefaults = UserDefaults.standard
        
        if let favoritesData = userDefaults.data(forKey: favoritesKey), let favorites = try? JSONDecoder().decode([MLandmark].self, from: favoritesData) {
            //workoutData is non-nil and successfully decoded
            return favorites
        }
        else {
            return [MLandmark]()
        }
    }

}


