//
//  User.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Marshal

struct WeekendDates {
    let thisWeekendStart: String
    let thisWeekendEnd: String
    let nextWeekendStart: String
    let nextWeekendEnd: String
}

final class User: NSObject, Unmarshaling {
    let id: Int
    var firstName: String
    var lastName: String
    var email: String
    var username: String
    let created: String?
    var lat: Float?
    var lon: Float?
    var budget: Int
    var people: Int
    var split: Int
    var homeAirport: String
    var travelDates: String
    let avatar: String
    var hotelTypes: String
    var currencyCode: String
    var locale: String
    var avatarBitmapB64: String?
    var avatarImage: UIImage?
    var weekendDates: WeekendDates?
    var leaveDay: String
    var returnDay: String
    var leaveDate: Double
    var returnDate: Double
    
    
    
    init(id: Int, firstName: String, lastName: String, email: String, username: String, created: String, lat: Float, lon: Float, budget: Int, people: Int, split: Int, homeAirport: String, travelDates: String, avatar: String, hotelTypes: String, currencyCode: String, locale: String, leaveDay: String, returnDay: String, leaveDate: Double, returnDate: Double) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.username = username
        self.created = created
        self.lat = lat
        self.lon = lon
        self.budget = budget
        self.people = people
        self.split = split
        self.homeAirport = homeAirport
        self.travelDates = travelDates
        self.avatar = avatar
        self.hotelTypes = hotelTypes
        self.currencyCode = currencyCode
        self.locale = locale
        self.leaveDay = leaveDay
        self.returnDay = returnDay
        self.leaveDate = leaveDate
        self.returnDate = returnDate
    }
    
    init(object: MarshaledObject) throws {
        id = try Int(object.value(for: "id") as String)!
        firstName = try object.value(for: "name")
        lastName = try object.value(for: "surname")
        email = try object.value(for: "mail")
        username = try object.value(for: "username")
        created = try object.value(for: "created")
        lat = try? Float(object.value(for: "latitude") as String)!
        lon = try? Float(object.value(for: "longitude") as String)!
        budget = try Int(object.value(for: "budget") as String)!
        people = try Int(object.value(for: "people") as String)!
        split = try Int(object.value(for: "split") as String)!
        homeAirport = try object.value(for: "home_airport")
        travelDates = try object.value(for: "travel_dates")
        avatar = try "https://cdn1.takemeaway.io/images/user/avatars\(object.value(for: "avatar") as String)"
        hotelTypes = try object.value(for: "hotel_types")
        currencyCode = try object.value(for: "currency_code")
        locale = try object.value(for: "locale")
        leaveDay = try object.value(for: "leaveday")
        returnDay = try object.value(for: "returnday")
        leaveDate = try Double(object.value(for: "leaveDate") as String)!
        returnDate = try Double(object.value(for: "returnDate") as String)!
        
        let thisWeekendStart: String? = try object.value(for: "thisWeekendStart")
        let thisWeekendEnd: String? = try object.value(for: "thisWeekendEnd")
        let nextWeekendStart: String? = try object.value(for: "nextWeekendStart")
        let nextWeekendEnd: String? = try object.value(for: "nextWeekendEnd")
        
        if let thisWeekendStart = thisWeekendStart, let thisWeekendEnd = thisWeekendEnd, let nextWeekendStart = nextWeekendStart, let nextWeekendEnd = nextWeekendEnd {
            weekendDates = WeekendDates(thisWeekendStart: thisWeekendStart, thisWeekendEnd: thisWeekendEnd, nextWeekendStart: nextWeekendStart, nextWeekendEnd: nextWeekendEnd)
        }
        
    }    
}
