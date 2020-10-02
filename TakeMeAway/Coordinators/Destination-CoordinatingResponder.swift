//
//  DestinationCoordinatingResponder.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import UIKit

final class DestinationPageBox: NSObject {
    let unbox: DestinationCoordinator.Page
    init(_ value: DestinationCoordinator.Page) {
        self.unbox = value
    }
}
extension DestinationCoordinator.Page {
    var boxed: DestinationPageBox { return DestinationPageBox(self) }
}


extension UIResponder {
    
    @objc dynamic func fetchDestinations(sender: Any?, completion: @escaping ([Destination], Error?) -> Void ) {
        coordinatingResponder?.fetchDestinations(sender: sender, completion: completion)
    }
    
    @objc dynamic func fetchHotelsForDestination(sender: Any?, destination: Destination, completion: @escaping ([Hotel], Error?) -> Void) {
        coordinatingResponder?.fetchHotelsForDestination(sender: sender, destination: destination, completion: completion)
    }

    @objc dynamic func fetchHotelsForDestinationByID(sender: Any?, cityid: Int, completion: @escaping ([Hotel], Error?) -> Void) {
        coordinatingResponder?.fetchHotelsForDestinationByID(sender: sender, cityid: cityid, completion: completion)
    }
    
    @objc dynamic func fetchSavedItems(sender: Any?, completion: @escaping ([SavedItem], Error?) -> Void ) {
        coordinatingResponder?.fetchSavedItems(sender: sender, completion: completion)
    }
    
    @objc dynamic func showHotelsForDestination(sender: Any?, destination: Destination) {
        coordinatingResponder?.showHotelsForDestination(sender: sender, destination: destination)
    }

    @objc dynamic func showHotelsForDestination(sender: Any?, saveditem: SavedItem) {
        coordinatingResponder?.showHotelsForDestination(sender: sender, saveditem: saveditem)
    }
    
    @objc dynamic func showDetailsForHotel(sender: Any?, hotel: Hotel, destination: Destination, room: Room) {
        coordinatingResponder?.showDetailsForHotel(sender: sender, hotel: hotel, destination: destination, room: room)
    }
    
    @objc dynamic func showSummaryForTrip(sender: Any?, trip: Trip) {
        coordinatingResponder?.showSummaryForTrip(sender: sender, trip: trip)
    }

    @objc dynamic func showTripBooking(sender: Any?, trip: Trip, tab: Int) {
        coordinatingResponder?.showTripBooking(sender: sender, trip: trip, tab: tab)
    }
    
    @objc dynamic func goHome(sender: Any) {
        coordinatingResponder?.goHome(sender: sender)
    }
    
    @objc dynamic func showSummaryForSavedItem(sender: Any?, item: SavedItem) {
        coordinatingResponder?.showSummaryForSavedItem(sender: sender, item: item)
    }
    
    @objc dynamic func topUpAvailableDestinations(sender: Any?, amount: Int, completion: @escaping ([Destination], Error?) -> Void) {
        coordinatingResponder?.topUpAvailableDestinations(sender: sender, amount: amount, completion: completion)
    }
    
    @objc dynamic func bookFlightForTrip(sender: Any?, trip: Trip) {
        coordinatingResponder?.bookFlightForTrip(sender: sender, trip: trip)
    }
    
    @objc dynamic func bookHotelForTrip(sender: Any?, trip: Trip) {
        coordinatingResponder?.bookHotelForTrip(sender: sender, trip: trip)
    }
    
    @objc dynamic func emailTripDetails(sender: Any?, trip: Trip, completion: @escaping (Bool, Error?) -> Void) {
        coordinatingResponder?.emailTripDetails(sender: sender, trip: trip, completion: completion)
    }
    
    @objc dynamic func saveHotelAndDestination(sender: Any?, hotelId: Int, cityId: Int, flightPrice: Int, hotelPrice: Int, completion: @escaping (Error?) -> Void) {
        coordinatingResponder?.saveHotelAndDestination(sender: sender, hotelId: hotelId, cityId: cityId, flightPrice: flightPrice, hotelPrice: hotelPrice, completion: completion)
    }
    
    @objc dynamic func deleteSavedHotelAndDestination(sender: Any?, hotelId: Int, cityId: Int, completion: @escaping (Error?) -> Void) {
        coordinatingResponder?.deleteSavedHotelAndDestination(sender: sender, hotelId: hotelId, cityId: cityId, completion: completion)
    }
    
    @objc dynamic func userDidDeleteSavedItemFromDetailsPage(sender: Any? = nil) {
        coordinatingResponder?.userDidDeleteSavedItemFromDetailsPage(sender: sender)
    }
    
    @objc dynamic func updateDeviceToken(sender: Any?, token: String, completion: @escaping (Bool, Error?) -> Void) {
        coordinatingResponder?.updateDeviceToken(sender: sender, token: token, completion: completion)
    }
}
