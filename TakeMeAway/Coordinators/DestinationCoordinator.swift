//
//  DestinationCoordinator.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Coordinator
import SafariServices
import SVProgressHUD

final class DestinationCoordinator: NavigationCoordinator, NeedsDependency {
    var dependencies: AppDependency? {
        didSet { updateChildCoordinatorDependencies() }
    }
    
    //    Declaration of all local pages (ViewControllers)
    enum Page {
        case chooseDestination
        case chooseHotel(Destination)
        case chooseHotelFromSaved(SavedItem)
        case hotelDetails(Hotel, Destination, Room)
        case tripSummary(Trip)
        case tripBooking(Trip, Int)
        case savedItems
        case savedItemDetails(SavedItem)
    }
    var page: Page = .chooseDestination
    
    func display(page: Page) {
        rootViewController.parentCoordinator = self
        rootViewController.delegate = self
        
        setupActivePage(page)
    }
    
    //    Coordinator lifecycle
    override func start(with completion: @escaping () -> Void = {}) {
        super.start(with: completion)
        
        checkDeviceToken()
        setupActivePage()
    }
    
    func checkDeviceToken() {
        // check device token
        let defaults = UserDefaults.standard
        let detectedDeviceToken = defaults.string(forKey: "detectedDeviceToken")
        let storedDeviceToken = defaults.string(forKey: "storedDeviceToken")
        
        if (detectedDeviceToken != storedDeviceToken) {
            print("found new device token")
            self.updateDeviceToken(sender: self, token: detectedDeviceToken!, completion: { (success, error) in
                if success {
                    print("stored new device token")
                    defaults.set(detectedDeviceToken, forKey: "storedDeviceToken")
                } else {
                    print("error storing device token")
                }
            })
        }
    }
    
    // fetch new destinations and replace ones in choose destination vc
    func reloadDestinationCards() {
        checkDeviceToken()
        for vc in viewControllers {
            if let sidebarMenuVC = vc as? SidebarMenuViewController {
                SVProgressHUD.show(withStatus: "Loading destinations...")
                fetchDestinations(sender: self, completion: {(destinations, error) in
                    if let error = error {
                        print("Error fetching destinations for card reload: \(error.localizedDescription)")
                        
                        if self.isLoggedIn(sender: self) {
                            
                            SVProgressHUD.dismiss()
                            let alert = UIAlertController(title: "Sorry", message: "Unable to fetch destinations. Try changing your budget. Error code 1", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "Change Filters", style: .default, handler: self.userDidTapFiltersButton))
                            
                            self.present(alert)
                        } else {
                            SVProgressHUD.showError(withStatus: "Unable to fetch destinations. ErrorCode: 1")
                        }
                        
                        
                    } else {
                        SVProgressHUD.dismiss()
                        if let destVC = sidebarMenuVC.contentVC as? DestinationsViewController {
                            destVC.clearDestinations()
                            destVC.destinations = destinations   
                            destVC.updateAvatarView()
                        }
                    }
                })
            }
        }
    }
    
    @objc func userDidTapFiltersButton(sender: Any?) {
        self.accountShowPage(AccountPageBox(.filters), sender: self)
    }
    
    //    MARK:- Coordinating Messages
    //    must be placed here, due to current Swift/ObjC limitations
    override func saveHotelAndDestination(sender: Any?, hotelId: Int, cityId: Int, flightPrice: Int, hotelPrice: Int, completion: @escaping (Error?) -> Void) {
        if let dataManager = dependencies?.dataManager {
            dataManager.saveHotelAndDestination(hotelId: hotelId, cityId: cityId, flightPrice: flightPrice, hotelPrice: hotelPrice, callback: completion)
        } else {
            completion(AccountError.notLoggedIn)
        }
    }
    
    override func deleteSavedHotelAndDestination(sender: Any?, hotelId: Int, cityId: Int, completion: @escaping (Error?) -> Void) {
        if let dataManager = dependencies?.dataManager {
            dataManager.deleteSavedHotelAndDestination(hotelId: hotelId, cityId: cityId, callback: completion)
        } else {
            completion(AccountError.notLoggedIn)
        }
    }
    
    override func userDidDeleteSavedItemFromDetailsPage(sender: Any? = nil) {
        rootViewController.popViewController(animated: true)
    }
    
    override func logout(sender: Any?) {
        if let loginManager = dependencies?.loginManager, let api = dependencies?.apiManager {
            loginManager.logout()
            api.logout()
            self.didLogout(sender: self)
        }
    }
    
    override func fetchSavedItems(sender: Any?, completion: @escaping ([SavedItem], Error?) -> Void) {
        guard let manager = dependencies?.destinationManager else {
            completion([], nil)
            return
        }
        manager.savedItems(callback: completion)
    }
    
    override func fetchDestinations(sender: Any?, completion: @escaping ([Destination], Error?) -> Void) {
        guard let manager = dependencies?.destinationManager else {
            completion([], nil)
            return
        }
        guard let loginManger = dependencies?.loginManager else {
            completion([], nil)
            return
        }
        let personalised = loginManger.status == .loggedIn || loginManger.status == .loggedOutSavedCredentials // TODO: create "logging in" status
        manager.destinations(personalised: personalised, callback: completion)
    }
    
    // gets the manager to top up its model by a certain amount, then hands back updated model
    // TODO: should amount be decided in Manager class?
    override func topUpAvailableDestinations(sender: Any?, amount: Int, completion: @escaping ([Destination], Error?) -> Void) {
        guard let manager = dependencies?.destinationManager else {
            completion([], nil)
            return
        }
        guard let loginManger = dependencies?.loginManager else {
            completion([], nil)
            return
        }
        let personalised = loginManger.status == .loggedIn || loginManger.status == .loggedOutSavedCredentials
        
        // top up destinations, then pass back updated model
        manager.topUpDestinations(count: amount) {
            manager.destinations(personalised: personalised, callback: completion)
        }
        
    }
    override func fetchHotelsForDestination(sender: Any?, destination: Destination, completion: @escaping ([Hotel], Error?) -> Void) {
        guard let manager = dependencies?.destinationManager else {
            enqueueMessage { [unowned self] in
                self.fetchHotelsForDestination(sender: sender, destination: destination, completion: completion)
            }
            return
        }
        manager.hotelsForDestination(destination: destination, callback: completion)
    }
    override func fetchHotelsForDestinationByID(sender: Any?, cityid: Int, completion: @escaping ([Hotel], Error?) -> Void) {
        guard let manager = dependencies?.destinationManager else {
            enqueueMessage { [unowned self] in
                self.fetchHotelsForDestinationByID(sender: sender, cityid: cityid, completion: completion)
            }
            return
        }
        manager.hotelsForDestinationByID(cityid: cityid, callback: completion)
    }
    override func showHotelsForDestination(sender: Any?, destination: Destination) {
        display(page: .chooseHotel(destination))
    }

    override func showHotelsForDestination(sender: Any?, saveditem: SavedItem) {
        display(page: .chooseHotelFromSaved(saveditem))
    }
    
    override func showDetailsForHotel(sender: Any?, hotel: Hotel, destination: Destination, room: Room) {
        display(page: .hotelDetails(hotel, destination, room))
    }
    
    override func showSummaryForTrip(sender: Any?, trip: Trip) {
        display(page: .tripSummary(trip))
    }

    override func showTripBooking(sender: Any?, trip: Trip, tab: Int) {
        display(page: .tripBooking(trip, tab))
    }
    
    override func goHome(sender: Any?) {
        display(page: .chooseDestination)
    }
    
    // This appears to be next to useless with current data returned from the API...
    override func showSummaryForSavedItem(sender: Any?, item: SavedItem) {
        if let dataManager = dependencies?.dataManager {
            dataManager.fetchDestinationDetails(cityId: item.cityId, callback: {(destination, error) in
                if destination != nil {
                    dataManager.fetchHotelDetails(id: item.hotelId, callback: {(detailedHotel, error) in
                        if let detailedHotel = detailedHotel {
                            let trip = Trip(savedItem: item, detailedHotel: detailedHotel)
                            
                            self.display(page: .tripSummary(trip))
                        }
                    })
                }
            })
        }
    }
    
    override func bookFlightForTrip(sender: Any?, trip: Trip) {
        let url = URL(string: trip.destination.flightRefUri!)
        // TODO: open url in safari
//        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        let svc = SFSafariViewController(url: url!)
        present(svc)
    }
    
    override func bookHotelForTrip(sender: Any?, trip: Trip) {
        let url = URL(string: trip.hotel.bookingLink!)
        // open in safari view controller
        let svc = SFSafariViewController(url: url!)
        present(svc)
    }
    
    override func emailTripDetails(sender: Any?, trip: Trip, completion: @escaping (Bool, Error?) -> Void) {
        
        if let api = dependencies?.apiManager {
            api.request(target: TakeMeAwayAPI.emailTripDetails(cityId: "\(trip.destination.cityId)", hotelId: "\(trip.hotel.id)"), success: { (response) in
                // email sent successfully
                completion(true, nil)
            }, error: { (error) in
                // error sending email
                completion(false, error)
            }, failure: { (error) in
                // couldn't contact server
                completion(false, error)
            })
        } else {
            completion(false, TakeMeAwayServiceError.serviceNotAvailable)
        }
    }
    
    override func updateDeviceToken(sender: Any?, token: String, completion: @escaping (Bool, Error?) -> Void) {
        
        if let api = dependencies?.apiManager {
            api.request(target: TakeMeAwayAPI.updateDeviceToken(deviceToken: token, deviceType: "ios"), success: { (response) in
                // email sent successfully
                completion(true, nil)
            }, error: { (error) in
                // error sending email
                completion(false, error)
            }, failure: { (error) in
                // couldn't contact server
                completion(false, error)
            })
        } else {
            completion(false, TakeMeAwayServiceError.serviceNotAvailable)
        }
    }
}

fileprivate extension DestinationCoordinator {
    func setupActivePage(_ enforcedPage: Page? = nil) {
        let p = enforcedPage ?? page
        page = p
        
        switch p {
            case .chooseDestination:
                let vc = SidebarMenuViewController.init(nibName: "SidebarMenuViewController", bundle: Bundle.main)
                let chooseDestinationVC = DestinationsViewController.init(nibName: "DestinationsViewController", bundle: Bundle.main)
                
                vc.contentVC = chooseDestinationVC
                if let destinationManager = dependencies?.destinationManager {
                    chooseDestinationVC.destinations = destinationManager.destinations
                }
                root(vc)
                break
            case .chooseHotelFromSaved(let saveditem):
                let vc = HotelsInDestinationViewController.init(nibName: "HotelsInDestinationViewController", bundle: Bundle.main)
                if let destinationManager = dependencies?.destinationManager, let hotels = destinationManager.hotelsInDestinations[saveditem.cityId] {
                    vc.hotels = hotels
                }
                vc.saveditem = saveditem
                vc.title = "Hotels in \(saveditem.cityName)"
                show(vc)
                break
            case .chooseHotel(let destination):
                let vc = HotelsInDestinationViewController.init(nibName: "HotelsInDestinationViewController", bundle: Bundle.main)
                if let destinationManager = dependencies?.destinationManager, let hotels = destinationManager.hotelsInDestinations[destination.cityId] {
                    vc.hotels = hotels
                }
                vc.destination = destination
                vc.title = "Hotels in \(destination.cityName)"
                show(vc)
                break
            case .hotelDetails(let hotel, let destination, let room):
                let vc = HotelDetailsViewController.init(nibName: "HotelDetailsViewController", bundle: Bundle.main)
                if let destinationManager = dependencies?.destinationManager {
                    destinationManager.detailsForHotel(hotelId: hotel.id, callback: {(detailedHotel, error) in
                        guard let detailedHotel = detailedHotel else {
                            print("Error loading hotel details: \(error.debugDescription)")
                            return
                        }
                        detailedHotel.rating = hotel.rating
                        detailedHotel.quotedRate = Int(hotel.price)
                        vc.hotel = detailedHotel
                        vc.destination = destination
                        vc.room = room
                        vc.trip = Trip(destination: destination, hotel: hotel, numPeople: detailedHotel.bookingPrefs.people, room: room, fromDate: detailedHotel.bookingPrefs.startDate, toDate: detailedHotel.bookingPrefs.endDate)
                    })
                }

                show(vc)
                break
            case .tripSummary(let trip):
                let vc = TripSummaryViewController.init(nibName: "TripSummaryViewController", bundle: Bundle.main)
                vc.trip = trip
                
                // get extra details for city/destination seeing as not all details are passed in initial API call...
                if let destinationManager = dependencies?.destinationManager {
                    destinationManager.detailsForDestination(destination: trip.destination, callback: {(detailedDestination, error) in
                        if detailedDestination != nil {
                            vc.flightBookingLink = detailedDestination?.flightRefUri
                        }
                    })
                    destinationManager.detailsForHotel(hotelId: trip.hotel.id, callback: {(detailedHotel, error) in
                        if detailedHotel != nil {
                            vc.hotelBookingLink = detailedHotel!.bookingLink
                        }
                    })
                }
                
                vc.title = "Trip Summary"
                show(vc)
                break
            case .tripBooking(let trip, let tab):
                let vc = HotelFlightBookingTabs.init(nibName: "HotelFlightBookingTabs", bundle: Bundle.main)
                
                vc.trip = trip
                vc.tab = tab
                vc.title = "Let us Take You Away"
                show(vc)
                break
                
            case .savedItems:
                let vc = SavedItemsViewController.init(nibName: "SavedItemsViewController", bundle: Bundle.main)
                show(vc)
                break
            case .savedItemDetails(let savedItem):
                let vc = SavedItemDetailsViewController.init(nibName: "SavedItemDetailsViewController", bundle: nil)
                
                guard let manager = dependencies?.destinationManager else {
                    enqueueMessage {
                        self.setupActivePage(.savedItemDetails(savedItem))
                    }
                    return
                }
                manager.detailsForHotel(hotelId: savedItem.hotelId, callback: {(detailedHotel, error) in
                    if let detailedHotel = detailedHotel {
                        vc.hotel = detailedHotel
                    }
                })
                vc.savedItem = savedItem
                show(vc)
                break
        }
    }
}
