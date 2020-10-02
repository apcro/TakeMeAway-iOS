//
//  UserPreferences.swift
//  TakeMeAway
//
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim

import Foundation
import Marshal

final class UserPreferences: NSObject, Unmarshaling {
    let budget: Int
    let people: Int
    let split: Int
    let startDate: String
    let endDate: String
    let travelDates: String
    let leaveDay: String
    let returnDay: String
    
    init(budget: Int, people: Int, split: Int, startDate: String, endDate: String, travelDates: String, leaveDay: String, returnDay: String) {
        self.budget = budget
        self.people = people
        self.split = split
        self.startDate = startDate
        self.endDate = endDate
        self.travelDates = travelDates
        self.leaveDay = leaveDay
        self.returnDay = returnDay
    }
    
    init(object: MarshaledObject) throws {
        budget = try Int(object.value(for: "budget") as String)!
        people = try Int(object.value(for: "people") as String)!
        split = try Int(object.value(for: "split") as String)!
        startDate = try object.value(for: "humanStartDate")
        endDate = try object.value(for: "humanEndDate")
        travelDates = try object.value(for: "travel_dates")
        leaveDay = try object.value(for: "leaveday")
        returnDay = try object.value(for: "returnday")
    }
    
}
