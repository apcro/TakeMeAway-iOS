//
//  Hotel.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 07/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal
import MapKit

final class Hotel: NSObject, Unmarshaling, MKAnnotation {
    let id: Int
    let url: String?
    let name: String
    let lat: Float
    let lon: Float
    let countryCode: String?
    let minRate: Int
    let maxRate: Int
    let price: Float
    let currencyCode: String?
    let photoName: String
    var rooms: [Room] = []
    var rating: Float = 0.0
    let hotelDescription: String?
    let checkInFrom: String?
    let checkInTo: String?
    let checkOutFrom: String?
    let checkOutTo: String?
    let hotelierWelcome: String?
    let importantInfo: String?
    let address: String?
    let zip: String?
    var images: [String] = []
    var bookingLink: String?
    var savedHotel: Bool = false
    // MKAnnotion protocol
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var amenities1: String?
    var amenities2: String?
    
    
    init(id: Int, url: String?, name: String, lat: Float, lon: Float, countryCode: String?, minRate: Int, maxRate: Int, price: Float, currencyCode: String?, photoName: String, hotelDescription: String, rooms: [Room], rating: Float?, checkInFrom: String?, checkInTo: String?, checkOutFrom: String?, checkOutTo: String?, hotelierWelcome: String?, importantInfo: String?, address: String?, zip: String?, images: [String]?, bookingLink: String?, savedHotel: Bool, amenities1: String, amenities2: String) {
        self.id = id
        self.url = url
        self.name = name
        self.lat = lat
        self.lon = lon
        self.countryCode = countryCode
        self.minRate = minRate
        self.maxRate = maxRate
        self.price = price
        self.currencyCode = currencyCode
        self.photoName = photoName
        self.rooms = rooms
        self.rating = rating ?? 0.0
        self.hotelDescription = hotelDescription
        self.checkInFrom = checkInFrom
        self.checkInTo = checkInTo
        self.checkOutFrom = checkOutFrom
        self.checkOutTo = checkOutTo
        self.hotelierWelcome = hotelierWelcome
        self.importantInfo = importantInfo
        self.address = address
        self.zip = zip
        self.images = images ?? []
        self.bookingLink = bookingLink
        self.savedHotel = savedHotel
        self.amenities1 = amenities1
        self.amenities2 = amenities2
        
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.lat), longitude: CLLocationDegrees(self.lon))
        self.title = self.name
    }
    
    init(object: MarshaledObject) throws {
        
        id = try Int(object.value(for: "hotel_id") as String)!
        url = try object.value(for: "url")
        name = try object.value(for: "name")
        lat = try Float(object.value(for: "hotel_lat") as String)!
        lon = try Float(object.value(for: "hotel_lon") as String)!
        countryCode = try object.value(for: "countrycode")
        minRate = try Int(object.value(for: "minrate") as String)!
        maxRate = try Int(object.value(for: "maxrate") as String)!
        rating = try Float(object.value(for: "review_score") as String)!
        price = try Float(object.value(for: "price") as String)! 
        currencyCode = try object.value(for: "hotel_currency_code")
        photoName = try object.value(for: "photo")
        hotelDescription = try object.value(for: "description")
        rooms = try object.value(for: "rooms") ?? []
        
        checkInFrom = try object.value(for: "checkin_from")
        checkInTo = try object.value(for: "checkin_to")
        checkOutFrom = try object.value(for: "checkout_from")
        checkOutTo = try object.value(for: "checkout_to")
        hotelierWelcome = try object.value(for: "hotelier_welcome")
        importantInfo = try object.value(for: "important_information")
        address = try object.value(for: "address")
        zip = try object.value(for: "zip")
        images = try object.value(for: "images") ?? []
        bookingLink = try object.value(for: "bookinglink")
        savedHotel = false 
        
        amenities1 = try object.value(for: "amenities1") ?? ""
        amenities2 = try object.value(for: "amenities2") ?? ""

        // MKAnnotation Protocol
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.lat), longitude: CLLocationDegrees(self.lon))
        self.title = self.name
    }
    
    // convenience initialiser to help with loading saved items from sparse API response
    init(details: DetailedHotel, image: String?, price: Float?) {
        self.id = details.id
        self.name = details.name
        self.bookingLink = details.bookingLink
        self.photoName = image ?? details.images.first ?? ""
        self.lat = details.lat
        self.lon = details.lon
        self.savedHotel = true
        self.minRate = details.minRate
        self.maxRate = details.maxRate
        self.price = price ?? Float(details.maxRate)
        self.checkInFrom = details.checkinFrom
        self.checkInTo = details.checkinTo
        self.checkOutFrom = details.checkoutFrom
        self.checkOutTo = details.checkoutTo
        self.importantInfo = details.importantInfo
        self.address = details.address
        
        // set all optional values to nil to get rid of errors
        // TODO: address this properly
        self.url = nil
        self.countryCode = nil
        self.currencyCode = nil
        self.hotelDescription = nil
        self.hotelierWelcome = nil
        self.zip = nil
        
        // MKAnnotation Protocol
        self.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.lat), longitude: CLLocationDegrees(self.lon))
        self.title = self.name
    }
    
}
