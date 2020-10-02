//
//  DestinationManager.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 10/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation

final class DestinationManager {
    fileprivate var dataManager: DataManager
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
    
    // data models
    fileprivate(set) var destinations: [Destination] = []
    fileprivate(set) var savedItems: [SavedItem] = []
    fileprivate(set) var detailedDestinations: [Int: Destination] = [:]
    fileprivate(set) var detailedHotels: [Int:DetailedHotel] = [:]
    var chosenDestination: Destination? {
        didSet {
        }
    }
    fileprivate(set) var hotelsInDestinations: [Int:[Hotel]] = [:]
}

extension DestinationManager {
    //    MARK:- Public API
    //    These methods should be custom tailored to read specific data subsets,
    //    as required for specific views. These will be called by Coordinators,
    //    then routed into UIViewControllers
    func destinations(personalised: Bool, callback: @escaping ([Destination], DataError?) -> Void) {
        
        fetchDestinations(personalised: personalised) {
            [unowned self] _, dataError in
            if let dataError = dataError {
                callback( self.destinations, dataError )
                return
            }
            callback( self.destinations, nil )
            return
        }
    }
    
    func topUpDestinations(count: Int, completion: @escaping () -> Void) {
        fetchDestinations(count: 1, topUp: true) {
            _, _ in
            // destinations topped up or not, either way we're done here
            completion()
        }
    }
    
    func detailsForDestination(destination: Destination, callback: @escaping (Destination?, Error?) -> Void) {
        
        // check cache first
        if let detailed = detailedDestinations[destination.cityId] {
            callback(detailed, nil)
        } else {
            // go fetch from datamanager
            fetchDestinationDetails(destination: destination, callback: { (updated, error) in
                if updated {
                    callback(self.detailedDestinations[destination.cityId], nil)
                } else {
                    callback(nil, error)
                }
            })
        }
    }
    
    func hotelsForDestination(destination: Destination, callback: @escaping ([Hotel], Error?) -> Void) {
        fetchHotelsForDestination(destination: destination, callback: callback)
    }

    func hotelsForDestinationByID(cityid: Int, callback: @escaping ([Hotel], Error?) -> Void) {
        fetchHotelsForDestinationByID(cityid: cityid, callback: callback)
    }
    
    func detailsForHotel(hotelId: Int, callback: @escaping (DetailedHotel?, Error?) -> Void) {
        
        // check cache first
        if let detailed = detailedHotels[hotelId] {
            callback(detailed, nil)
        } else {
            // go fetch from datamanager
            fetchHotelDetails(hotelId: hotelId, callback: { (updated, error) in
                if updated {
                    callback(self.detailedHotels[hotelId], nil)
                } else {
                    callback(nil, error)
                }
            })
        }
    }
    
    func savedItems(callback: @escaping ([SavedItem], DataError?) -> Void) {
        fetchSavedItems() {
            [unowned self] _, dataError in
            if let dataError = dataError {
                callback( self.savedItems, dataError )
                return
            }
            callback( self.savedItems, nil )
            return
        }
    }
}


fileprivate extension DestinationManager {
    //    MARK:- Private API
    //    These are thin wrappers around DataManager‘s similarly named methods.
    //    They are used to process received data and splice and dice them as needed,
    //    into business logic that only DestinationManager knows about
    

    
    ///    `Destination` set comes from API
    ///
    ///    Fetch an update on app start
    ///
    ///    Callback first param is `true` if data set is successfully refreshed.
    func fetchDestinations(count: Int = 3, personalised: Bool = false, topUp: Bool = false, callback: @escaping (Bool, DataError?) -> Void = {_, _ in}) {
        
        dataManager.fetchDestinations(count: count, personalised: personalised) {
            destinations, dataError in
            if dataError != nil {
                callback(false, DataError.missingData)
                return
            }
            
            if topUp {
                self.destinations += destinations
            } else {
                self.destinations = destinations
            }
            
            
            callback(true, nil)
        }
    }
    
    func fetchHotelsForDestination(destination: Destination, callback: @escaping ([Hotel], Error?) -> Void) {
        dataManager.fetchHotels(forDestination: destination, callback: {(hotels, error) in
            destination.hotels = hotels
            callback(hotels, error)
        })
    }

    func fetchHotelsForDestinationByID(cityid: Int, callback: @escaping ([Hotel], Error?) -> Void) {
        dataManager.fetchHotelsByID(forDestination: cityid, callback: {(hotels, error) in
            callback(hotels, error)
        })
    }
    func fetchSavedItems(callback: @escaping (Bool, DataError?) -> Void = {_, _ in}) {
        dataManager.fetchSavedItems() {
            savedItems, dataError in
            if dataError != nil {
                callback(false, DataError.missingData)
                return
            }
            
            self.savedItems = savedItems!
            callback(true, nil)
        }
    }
    
    func fetchDestinationDetails(destination: Destination, callback: @escaping (Bool, DataError?) -> Void = {_,_ in}) {
        
        dataManager.fetchDestinationDetails(cityId: destination.cityId) {
            detailedDestination, dataError in
            
            if dataError != nil {
                callback(false, DataError.missingData)
                return
            }
            
            // cache details in a dict
            self.detailedDestinations[destination.cityId] = detailedDestination
            
            callback(true, nil)
        }
    }
    
    func fetchHotelDetails(hotelId: Int, callback: @escaping (Bool, DataError?) -> Void = {_,_ in}) {
        
        dataManager.fetchHotelDetails(id: hotelId) {
            detailedHotel, dataError in
            
            if dataError != nil {
                callback(false, DataError.missingData)
                return
            }
            
            // cache details in a dict
            self.detailedHotels[hotelId] = detailedHotel
            
            callback(true, nil)
        }
    }
    

}
