//
//  Trip.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 13/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import CryptoSwift

final class Trip: NSObject {
    let destination: Destination
    let hotel: Hotel
    let numPeople: Int
    let room: Room?
    let fromDate: String
    let toDate: String
    var shareHash: String {
        get {
            let hash = "\(destination.cityId):\(hotel.id)".md5()
            return hash
        }
    }
    var shareUrl: String {
        get {
            let baseUrl = "{shareurl}"
            return "\(baseUrl)\(shareHash)"
        }
    }
    var shareMessage: String {
        get {
            let baseUrl = "{shareurl}" // TODO: move this to plist
            return "Check this out on TakeMeAway! We could be there next weekend! \(baseUrl)\(shareHash)"
        }
    }
    
    init(destination: Destination, hotel: Hotel, numPeople: Int, room: Room?, fromDate: String, toDate: String) {
        self.destination = destination
        self.hotel = hotel
        self.numPeople = numPeople
        self.room = room
        self.fromDate = fromDate
        self.toDate = toDate
    }
    
    init(savedItem: SavedItem, detailedHotel: DetailedHotel, room: Room? = nil) {
        self.destination = Destination(cityId: savedItem.cityId, cityName: savedItem.cityName, countryName: savedItem.country, iata: "", lat: savedItem.airportLat ?? 0.0, lon: savedItem.airportLon ?? 0.0, googlePlaceId: nil, cityDescription: nil, cityImage: savedItem.cityImage, flightCost: -1, currencyCode: nil, flightRefUri: nil, flightCurrency: nil, temperature: nil, weatherDescription: nil, weatherIcon: nil, hotels: [])
        
        self.hotel = Hotel(details: detailedHotel, image: savedItem.hotelImage, price: nil)
        self.numPeople = detailedHotel.bookingPrefs.people
        self.fromDate = detailedHotel.bookingPrefs.startDate
        self.toDate = detailedHotel.bookingPrefs.endDate
        self.room = room
    }
    
    func detailsForEmail() -> String {
        return "You are going to \(destination.cityName) from \(fromDate), returning \(toDate). You will be staying at \(hotel.name)."
    }
    
}
