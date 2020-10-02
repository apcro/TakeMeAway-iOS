//
//  DetailedHotel.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 14/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal
import MapKit

final class DetailedHotel: NSObject, Unmarshaling, MKAnnotation {
    let id: Int
    let url: String
    let name: String
    var rating: Float
    let bookingLink: String
    let minRate: Int
    let maxRate: Int
    var quotedRate: Int
    let hotelDescription: String
    let importantInfo: String
    let address: String
    let checkinFrom: String
    let checkinTo: String
    let checkoutFrom: String
    let checkoutTo: String
    let images: [String]
    let lat: Float
    let lon: Float
    let countrycode: String
    let bookingPrefs: UserPreferences
    // MKAnnotion protocol
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(self.lat), longitude: CLLocationDegrees(self.lon))
        }
    }
    var title: String? {
        get {
            return self.name
        }
    }
    var subtitle: String?
    var amenities1: String?
    var amenities2: String?
    var savedHotel: Bool = false
    
    
    init(id: Int, url: String, name: String, rating: Float, bookingLink: String, minRate: Int, maxRate: Int, quotedRate: Int, description: String, importantInfo: String, address: String, checkinFrom: String, checkinTo: String, checkoutFrom: String, checkoutTo: String, images: [String], lat: Float, lon: Float, countrycode: String, bookingPrefs: UserPreferences, amenities1: String, amenities2: String, savedHotel: Bool) {
        self.id = id
        self.url = url
        self.name = name
        self.rating = rating
        self.bookingLink = bookingLink
        self.minRate = minRate
        self.maxRate = maxRate
        self.quotedRate = quotedRate
        self.hotelDescription = description
        self.importantInfo = importantInfo
        self.address = address
        self.checkinFrom = checkinFrom
        self.checkinTo = checkinTo
        self.checkoutFrom = checkoutFrom
        self.checkoutTo = checkoutTo
        self.images = images
        self.lat = lat
        self.lon = lon
        self.bookingPrefs = bookingPrefs
        self.countrycode = countrycode
        self.amenities1 = amenities1
        self.amenities2 = amenities2
        self.savedHotel = savedHotel
    }
    
    init(object: MarshaledObject) throws {
        
        id = try Int(object.value(for: "hotel_id") as String)!
        url = try object.value(for: "url")
        name = try object.value(for: "name")
        bookingLink = try object.value(for: "bookinglink")
        minRate = try Int(object.value(for: "minrate") as String)!
        maxRate = try Int(object.value(for: "maxrate") as String)!
        quotedRate = minRate
        hotelDescription = try object.value(for: "description")
        importantInfo = try object.value(for: "important_information")
        address = try object.value(for: "address")
        checkinFrom = try object.value(for: "checkin_from")
        checkinTo = try object.value(for: "checkin_to")
        checkoutFrom = try object.value(for: "checkout_from")
        checkoutTo = try object.value(for: "checkout_to")
        images = try object.value(for: "images") ?? []
        lat = try Float(object.value(for: "lat") as String)!
        lon = try Float(object.value(for: "lon") as String)!
        
        bookingPrefs = try object.value(for: "prefs")
        countrycode = try object.value(for: "countrycode")
        rating = try Float(object.value(for: "review_score") as String)!
        
        amenities1 = try object.value(for: "amenities1") ?? ""
        amenities2 = try object.value(for: "amenities2") ?? ""
        savedHotel = false
    }
}
