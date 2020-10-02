//
//  DataManager.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 05/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Moya
import Moya_Marshal
import SVProgressHUD

final class DataManager {
    // dependencies
    let api: TakeMeAwayService
    
    init(api: TakeMeAwayService) {
        self.api = api
    }
    
    let serviceErrorCallback = {(error: TakeMeAwayServiceError) in
        // server responded, but it wasn't what we hoped for
        print("Service Error: \(error.description)")
    }
    
    let requestFailureCallback = {(error: MoyaError) in
        // request didn't make it to the server
        print("Request Failure: \(error.errorDescription!)")
    }
}

extension DataManager {
    
    func getNearestAirport(lat: Float, lon: Float, callback: @escaping (Airport?, Error?) -> Void) {
        api.request(target: .nearestAirport(lat: lat, lon: lon), success: {(response) in
            do {
                let airportResponse = try response.map(to: NearestAirportResponse.self)
                callback(airportResponse.data, nil)
            } catch {
                callback(nil, error)
            }
        }, error: {(error) in
            callback(nil, error)
        }, failure: {(error) in
            callback(nil, error)
        })
    }
    
    func getAirportDetails(iata: String, callback: @escaping (Airport?, Error?) -> Void) {
        api.request(target: .airportDetails(iata: iata), success: {(response) in
            do {
                let airportsResponse = try response.map(to: AirportDetailsResponse.self)
                callback(airportsResponse.data, nil)
            } catch {
                callback(nil, error)
            }
        }, error: {(error) in
            callback(nil, error)
        }, failure: {(error) in
            callback(nil, error)
        })
    }
    
    func getNearAirports(lat: Float, lon: Float, callback: @escaping ([Airport], Error?) -> Void) {
        api.request(target: .airports(lat: lat, lon: lon), success: {(response) in
            do {
                let airportsResponse = try response.map(to: AirportsResponse.self)
                callback(airportsResponse.data, nil)
            } catch {
//                print("catch")
//                print(response)
                callback([], error)
            }
        }, error: {(error) in
//            print("error")
//            print(error)
            callback([], error)
        }, failure: {(error) in
//            print("failure")
            callback([], error)
        })
    }
    
    func saveAvatar(avatar: UIImage, callback: @escaping (Error?) -> Void) {
        api.request(target: .updateAvatar(avatar: avatar), success: {(response) in
            do {
                let avatarResponse = try response.map(to: AvatarResponse.self)
                if let avatar = avatarResponse.data {
                    let notificationCenter = NotificationCenter.default
                    notificationCenter.post(name: NSNotification.Name.avatarChanged, object: avatar)
                }
            } catch {
                callback(error)
            }
            callback(nil)
        }, error: {(error) in
            callback(error)
        }, failure: {(error) in
            callback(error)
        })
    }
    
    func saveProfile(user: User, callback: @escaping (Error?) -> Void) {
        api.request(target: .updateProfile(username: user.email, firstName: user.firstName, lastName: user.lastName, email: user.email, homeAirport: user.homeAirport, lat: user.lat ?? 0.0, lon: user.lon ?? 0.0), success: {(response) in
            callback(nil)
        }, error: {(error) in
            callback(error)
        }, failure: {(error) in
            callback(error)
        })
    }
    
    func saveSettings(user: User, callback: @escaping (Error?) -> Void) {
        api.request(target: .updateSettings(budget: user.budget, people: user.people, split: user.split, dates: user.travelDates, filters: user.hotelTypes, currency: user.currencyCode, locale: user.locale, leaveday: user.leaveDay, returnday: user.returnDay, leaveDate: user.leaveDate, returnDate: user.returnDate), success: {(response) in
            callback(nil)
        }, error: {(error) in
            callback(error)
        }, failure: {(error) in
            callback(error)
        })
    }
    
    func saveHotelAndDestination(hotelId: Int, cityId: Int, flightPrice: Int, hotelPrice: Int, callback: @escaping (Error?) -> Void) {
        api.request(target: .saveItem(cityId: cityId, hotelId: hotelId, flightPrice: flightPrice, hotelPrice: hotelPrice), success: {(response) in
            callback(nil)
        }, error: {(error) in
            callback(error)
        }, failure: {(error) in
            callback(error)
        })
    }
    
    func deleteSavedHotelAndDestination(hotelId: Int, cityId: Int, callback: @escaping (Error?) -> Void) {
        api.request(target: .deleteSavedItem(cityId: cityId, hotelId: hotelId), success: {(response) in
            callback(nil)
        }, error: {(error) in
            callback(error)
        }, failure: {(error) in
            callback(error)
        })
    }
    
    func fetchDestinations(count: Int, personalised: Bool, callback: @escaping ([Destination], Error?) -> Void) {
        
        // try fetching destinations
        api.request(target: personalised ? .personalisedDestinations(count: count) : .destinations(count: count), success: { (response) in
            // turn into model
            do {
                let destResponse: DestinationsResponse = try response.map(to: DestinationsResponse.self)
                let destinations = destResponse.data
                let destStatus = destResponse.status
                let destErrorMesage = destResponse.errorMessage
                if (destStatus == 1) {
                    callback(destinations, nil)
                } else {
                    if (destStatus != 2) {
                        // sometimes we will get a partial response, so an error, but some destinations anyway
                        // ignore these
                        if (destinations.count != 0) {
                            callback(destinations, nil)
                        } else {
                            print("Error detected: " + destErrorMesage!)
                            callback([], DataError.noDestinations)
                        }
                        
                    // so we go a status of 2 - no destinations found at all
                    } else {
                        print("Error detected: " + destErrorMesage!)
                        callback([], DataError.missingData)
                    }

                }
                
            } catch {
                print("Error fetching destinations: \(error)")
                callback([], DataError.internalError)
            }
            
        }, error: { (error) in
            self.serviceErrorCallback(error)
            callback([], error)
        }, failure: { (error) in
            self.requestFailureCallback(error)
            callback([], error)
        })
    }
    
    func fetchDestinationDetails(cityId: Int, callback: @escaping (Destination?, Error?) -> Void) {
        api.request(target: .cityDetails(cityId: cityId), success: { (response) in
            do {
                let destination: Destination = try response.map(to: Destination.self)
                callback(destination, nil)
            } catch {
                print("Error fetching destination details: \(error)")
                callback(nil, DataError.internalError)
            }
        }, error: { (error) in
            self.serviceErrorCallback(error)
            callback(nil, error)
        }, failure: { (error) in
            self.requestFailureCallback(error)
            callback(nil, error)
        })
    }
    
    func fetchHotels(forDestination destination: Destination, callback: @escaping ([Hotel], Error?) -> Void) {
        
        api.request(target: .hotels(count: 3, cityId: destination.cityId, extraHotelId: 0, flightCost: "100"), success: { (response) in
            do {
                let hotelsResponse = try response.map(to: HotelsResponse.self)
                callback(hotelsResponse.data, nil)
            } catch {
                print("Error fetching hotels: \(error)")
                callback([], DataError.internalError)
            }
            
        }, error: { (error) in
            self.serviceErrorCallback(error)
            callback([], error)
        }, failure: { (error) in
            self.requestFailureCallback(error)
            callback([], error)
        })
    }
    
    func fetchHotelsByID(forDestination cityid: Int, callback: @escaping ([Hotel], Error?) -> Void) {
        
        api.request(target: .hotels(count: 3, cityId: cityid, extraHotelId: 0, flightCost: "100"), success: { (response) in
            do {
                let hotelsResponse = try response.map(to: HotelsResponse.self)
                callback(hotelsResponse.data, nil)
            } catch {
                print("Error fetching hotels: \(error)")
                callback([], DataError.internalError)
            }
            
        }, error: { (error) in
            self.serviceErrorCallback(error)
            callback([], error)
        }, failure: { (error) in
            self.requestFailureCallback(error)
            callback([], error)
        })
    }
    
    func fetchHotelDetails(id: Int, callback: @escaping (DetailedHotel?, Error?) -> Void) {
        api.request(target: .hotelDetails(hotelId: id), success: { (response) in
            do {
                let hotelResponse: SingleHotelResponse = try response.map(to: SingleHotelResponse.self)
                callback(hotelResponse.data, nil)
            } catch {
                print("Error fetching destination details: \(error)")
                callback(nil, DataError.internalError)
            }
        }, error: { (error) in
            self.serviceErrorCallback(error)
            callback(nil, error)
        }, failure: { (error) in
            self.requestFailureCallback(error)
            callback(nil, error)
        })
    }
    
    func fetchCurrentUser(callback: @escaping (User?, Error?) -> Void) {

        api.request(target: .userDetails(), success: { (response) in
            do {
                let currentUserResponse = try response.map(to: UserResponse.self)
                
                // fire callback with CurrentUser if it's in the data, otherwise
                // fire callback with error instead
                guard let user = currentUserResponse.data else {
                    callback(nil, DataError.missingData)
                    return
                }
                callback(user, nil)
            } catch {
                print("Error fetching current user: \(error)")
                callback(nil, DataError.internalError)
            }
        }, error: { (error) in
            self.serviceErrorCallback(error)
            callback(nil, error)
        }, failure: { (error) in
            self.requestFailureCallback(error)
            callback(nil, error)
        })
    }
    
    func fetchSavedItems(callback: @escaping ([SavedItem]?, Error?) -> Void) {
        api.request(target: .savedItems(), success: {(response) in
            do {
                let savedItemsResponse = try response.map(to: SavedItemsResponse.self)
                guard let items = savedItemsResponse.data else {
                    callback(nil, DataError.missingData)
                    return
                }
                callback(items, nil)
            } catch {
                print("Error fetching saved items: \(error)")
                callback(nil, DataError.internalError)
            }
        }, error: { (error) in
            self.serviceErrorCallback(error)
            callback(nil, error)
        }, failure: { (error) in
            self.requestFailureCallback(error)
            callback(nil, error)
        })
    }
    
}
