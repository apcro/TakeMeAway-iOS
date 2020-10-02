//
//  SavedItem.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal

final class SavedItem: NSObject, Unmarshaling {
    let cityId: Int
    let cityName: String
    let country: String
    let cityImage: String
    let airportLat: Float?
    let airportLon: Float?
    let hotelName: String
    let hotelImage: String
    let hotelId: Int
    let hotelLat: Float?
    let hotelLon: Float?
    let shareHash: String
    let hotelprice: Float?
    let flightprice: Float?
    let startdate: Int
    let enddate: Int
    let people: Int
    let savedon: Int
    let rating: Float?
    
    
    
    
    init(cityId: Int, cityName: String, country: String, cityImage: String, airportLat: Float, airportLon: Float, hotelName: String, hotelImage: String, hotelId: Int, hotelLat: Float, hotelLon: Float, shareHash: String, hotelprice: Float, flightprice: Float, startdate: Int, enddate: Int, people: Int, savedon: Int, rating: Float) {
        self.cityId = cityId
        self.cityName = cityName
        self.country = country
        self.cityImage = cityImage
        self.airportLat = airportLat
        self.airportLon = airportLon
        self.hotelName = hotelName
        self.hotelImage = hotelImage
        self.hotelId = hotelId
        self.hotelLat = hotelLat
        self.hotelLon = hotelLon
        self.shareHash = shareHash
        self.hotelprice = hotelprice
        self.flightprice = flightprice
        self.startdate = startdate
        self.enddate = enddate
        self.people = people
        self.savedon = savedon
        self.rating = rating
    }
    
    init(object: MarshaledObject) throws {
        cityId = try Int(object.value(for: "cityId") as String)!
        cityName = try object.value(for: "cityname")
        country = try object.value(for: "country")
        cityImage = try "{cdnurl}}" + object.value(for: "cityimage") 
        airportLat = 0.0 
        airportLon = 0.0 
        hotelName = try object.value(for: "hotelname")
        hotelImage = try object.value(for: "hotelImage")
        hotelId = try Int(object.value(for: "hotelid") as String)!
        hotelLat = 0.0 
        hotelLon = 0.0 
        shareHash = try object.value(for: "share_hash")
        hotelprice = try Float(object.value(for: "hotelprice") as String)!
        flightprice = try Float(object.value(for: "flightprice") as String)!
        startdate = try Int(object.value(for: "startdate") as String)!
        enddate = try Int(object.value(for: "enddate") as String)!
        people = try Int(object.value(for: "people") as String)!
        do {
            savedon = try Int(object.value(for: "savedon") as String)!
        } catch {
            savedon = 0;
        }
        rating = try Float(object.value(for: "rating") as String)!
    }
    
}
