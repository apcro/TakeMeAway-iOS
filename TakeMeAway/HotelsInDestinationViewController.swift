//
//  HotelsInDestinationViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 17/12/2017.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import MapKit
import UPCarouselFlowLayout
import Kingfisher
import MaterialComponents
import SVProgressHUD
import Flurry_iOS_SDK

struct RoomInHotel {
    let hotel: Hotel
    let room: Room
}

class HotelsInDestinationViewController: UIViewController, CLLocationManagerDelegate {
    
    fileprivate let reuseIdentifier = "HotelCardCell"
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var carouselContainer: UIView!
    @IBOutlet weak var goButtonContainer: UIView!
    @IBOutlet weak var hotelDetailsButtonContainer: UIView!
    @IBOutlet weak var favouriteButtonContainer: UIView!
    
    @IBOutlet weak var pageIndicator: UIPageControl!
    
    private var collectionView: UICollectionView!
    private let layout = UPCarouselFlowLayout()
    private var goButton: MDCButton!
    private var hotelDetailsButton: MDCButton!
    private var newFavouriteButton: MDCButton!
    private var favouriteButton: UIBarButtonItem!
    private var shareButton: UIBarButtonItem!
    
    // local data models
    fileprivate var currentRoom: Int = 0 {
        didSet {
            // show location on map
            if !rooms.isEmpty && isViewLoaded {
                let hotel = rooms[currentRoom].hotel
                showHotelOnMap(hotel: hotel)
                
                updateFavouriteButtons()
                pageIndicator.currentPage = currentRoom
                
            } else {
                // TODO: show some sort of UI error or stop before we get to this stage
            }
        }
    }
    var destination: Destination! {
        didSet {
            if let destination = destination {
                hotels = destination.hotels ?? []
                if hotels.count == 0 {
                    SVProgressHUD.show()
                    fetchHotelsForDestination(sender: self, destination: destination, completion: {(hotels, error) in
                        SVProgressHUD.dismiss()
                        if error == nil {
                            self.hotels = hotels
                        } else {
                            print("Error fetching hotels for destination: \(error.debugDescription)")
                        }
                    })
                    
                    // if we get here, something went wrong                    
                }
            }
        }
    }
    var saveditem: SavedItem! {
        didSet {
            print("saveditem didset")
            if let saveditem = saveditem {
                print("loading hotels from saved item \(saveditem.cityId)")
                SVProgressHUD.show()
                fetchHotelsForDestinationByID(sender: self, cityid: saveditem.cityId, completion: {(hotels, error) in
                    SVProgressHUD.dismiss()
                    if error == nil {
                        self.hotels = hotels
                    } else {
                        print("Error fetching hotels for destination: \(error.debugDescription)")
                    }
                })
            }
        }
    }
    
    
    var hotels: [Hotel] = [] {
        didSet {
            // update carousel with hotels
            rooms = []
            for h in hotels {
                if h.rooms.isEmpty {
                    // make up a room with just hotel details
                    // FIXME: made up data
                    let room = Room(roomId: 0, roomName: "", hotelId: h.id, roomTypeId: 0, depositRequired: false, numAdults: 1, numRoomsAtThisPrice: 1, price: 0, refundable: false, blockId: "", refundableUntil: nil)
                    rooms.append(RoomInHotel(hotel: h, room: room))
                } else {
                    for r in h.rooms {
                        rooms.append(RoomInHotel(hotel: h, room: r))
                    }
                }
                
            }
            if isViewLoaded {
                collectionView.reloadData()
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotations(hotels)
            }
            currentRoom = 0
        }
    }
    private var rooms: [RoomInHotel] = [] {
        didSet {
            if isViewLoaded {
                pageIndicator.numberOfPages = rooms.count
                updateFavouriteButtons()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure mapview
        mapView.delegate = self
        if #available(iOS 11.0, *) {
            mapView.register(MKPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: "HotelAnnotation")
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(hotels)
        
        // configure collection view
        layout.scrollDirection = .horizontal
        layout.sideItemScale = 1.0
        layout.sideItemAlpha = 1.0
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 0.0)
        collectionView = UICollectionView(frame: carouselContainer.bounds, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        carouselContainer.addSubview(collectionView)
        
        
        // configure buttons
        hotelDetailsButton = MDCFloatingButton()
        hotelDetailsButton.contentMode = .scaleAspectFit
        hotelDetailsButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        hotelDetailsButton.setImage(UIImage(named: "ic2_hotel_info"), for: .normal)
        hotelDetailsButton.setBackgroundColor(UIColor.TMAColors.DarkTeal)
        hotelDetailsButton.sizeToFit()
        hotelDetailsButtonContainer.addSubview(hotelDetailsButton)
        hotelDetailsButton.addTarget(self, action: #selector(userDidTapDetailsButton), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userDidTapDetailsButton))
        collectionView.addGestureRecognizer(tapGesture)
        
        goButton = MDCFloatingButton()
        goButton.contentMode = .scaleAspectFit
        goButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        goButton.imageView?.contentMode = .center
        goButton.setImage(UIImage(named: "ic2_takeoffLO"), for: .normal)
        goButton.setBackgroundColor(UIColor.TMAColors.DarkTeal)
        goButton.sizeToFit()
        goButtonContainer.addSubview(goButton)
        goButton.addTarget(self, action: #selector(userDidTapGoButton), for: .touchUpInside)
        
        
        newFavouriteButton = MDCFloatingButton()
        newFavouriteButton.contentMode = .scaleAspectFit
        newFavouriteButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        newFavouriteButton.imageView?.contentMode = .center
        newFavouriteButton.setImage(UIImage(named: "ic_favorite_border_white_24dp"), for: .normal)
        newFavouriteButton.setBackgroundColor(UIColor.TMAColors.DarkTeal)
        newFavouriteButton.sizeToFit()
        favouriteButtonContainer.addSubview(newFavouriteButton)
        newFavouriteButton.addTarget(self, action: #selector(userDidTapFavouriteButton), for: .touchUpInside)
        
        pageIndicator.numberOfPages = hotels.count
        if (hotels.count > 1) {
            pageIndicator.isHidden = false
        } else {
            pageIndicator.isHidden = true
        }
        pageIndicator.tintColor = UIColor.TMAColors.DarkTeal
        pageIndicator.currentPageIndicatorTintColor = UIColor.TMAColors.LightTeal
        
        updateFavouriteButtons()
        
        shareButton = UIBarButtonItem(image: UIImage(named:"ic_share_white_24dp"), style: .plain, target: self, action: #selector(self.userDidTapShareButton))
        
        // set font family for all my view's subviews
        setFontFamilyForView("Muli-Regular", view: view, andSubviews: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if rooms.count > 0 {
            showHotelOnMap(hotel: rooms[currentRoom].hotel)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // fill container view
        collectionView.frame = carouselContainer.bounds
        layout.itemSize = CGSize(width: carouselContainer.bounds.width, height: carouselContainer.bounds.height)
    }
    
    // MARK: Actions
    
    @objc func userDidTapShareButton(sender: Any?) {
        let roomInHotel = rooms[currentRoom]
        let trip = Trip(destination: destination, hotel: roomInHotel.hotel, numPeople: 0, room: roomInHotel.room, fromDate: "", toDate: "")
        let message = trip.shareMessage
        let url = trip.shareUrl
        let activityViewController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {()
            print("complete?")
        })
    }
    
    @objc func userDidTapFavouriteButton(sender: Any?) {
        
        if isLoggedIn(sender: self) {
            // send api call to register this as a favourite
            let hotel = rooms[currentRoom].hotel
            // update local model
            hotel.savedHotel = !hotel.savedHotel
            self.updateFavouriteButtons()
            
            if hotel.savedHotel {
                saveHotelAndDestination(sender: self, hotelId: hotel.id, cityId: destination.cityId, flightPrice: destination.flightCost, hotelPrice: hotel.minRate, completion: {(error) in
                    if error != nil {
                        // undo change to ui and local model
                        hotel.savedHotel = false
                        self.updateFavouriteButtons()
                        // TODO: decide if this is worth notifying user about
                    }
                })
            } else {
                // un-save hotel and destination
                deleteSavedHotelAndDestination(sender: self, hotelId: hotel.id, cityId: destination.cityId, completion: {(error) in
                    if error != nil {
                        // undo change to ui and local model
                        hotel.savedHotel = true
                        self.updateFavouriteButtons()
                        // TODO: decide if this is worth notifying user about
                    }
                })
            }
        } else {
            showLoginAlert(message: "You need to be registered to save a trip.")
        }
        
    }
    
    @objc func userDidTapGoButton(sender: Any?) {
        
        if isLoggedIn(sender: self) {
            let roomInHotel = rooms[currentRoom]
            let user = currentUser(sender: self)
            
            let trip = Trip(destination: destination, hotel: roomInHotel.hotel, numPeople: 0, room: roomInHotel.room, fromDate: "", toDate: "")
            
            showSummaryForTrip(sender: self, trip: Trip(destination: destination, hotel: roomInHotel.hotel, numPeople: user!.people, room: roomInHotel.room, fromDate: Date().description, toDate: Date().description))
        } else {
            showLoginAlert(message: "You need to be registered to book a trip.")
        }
        
    }
    
    @objc func userDidTapDetailsButton(sender: Any?) {
        
        if isLoggedIn(sender: self) {
            
            // show hotel details
            let hotel = self.rooms[self.currentRoom].hotel
            
            user = currentUser(sender: self)
            let reachabilityManager = ReachabilityManager()
            let api = TakeMeAwayService(reachabilityManager: reachabilityManager)
            let dataManager = DataManager(api: api)
            let loginManager = LoginManager(api: api, dataManager: dataManager, shouldClearKeychain: false)
            
            let articleParams = [
                "token": loginManager.authToken,
                "action": "Show Hotel Details",
                "originAirport": user?.homeAirport,
                "destinationAirport": destination.iata,
                "destinationCity": destination.cityName,
                "destinationCityId": String(destination.cityId),
                "hotelId": String(hotel.id),
                "value": String(destination.flightCost + Int(hotel.price)),
                "currency": hotel.currencyCode,
                "prefs.people": String(user?.people ?? 1),
                "prefs.budget": String(user?.budget ?? 2000),
                "prefs.weekend": user?.travelDates
            ];
            Flurry.logEvent("ShowHotelDetails", withParameters: articleParams);
            
            
            showDetailsForHotel(sender: self, hotel: hotel, destination: self.destination, room: self.rooms[self.currentRoom].room)
        } else {
            showLoginAlert(message: "You need to be registered to see hotel information.")
        }
        
    }
    
    // MARK: UI Helpers
    
    func updateFavouriteButtons() {
        if rooms.count > 0 {
            let hotel = rooms[currentRoom].hotel
            var buttons: [UIBarButtonItem] = []
            
            if hotel.savedHotel == true {
                buttons = [shareButton]
                
                newFavouriteButton.setImage(UIImage(named: "ic_favorite_white_24dp"), for: .normal)
            } else {
                buttons = []
                newFavouriteButton.setImage(UIImage(named: "ic_favorite_border_white_24dp"), for: .normal)
            }
            
            navigationItem.setRightBarButtonItems(buttons, animated: true)
        }
    }
    
    func showLoginAlert(message: String) {
        
        let alert = UIAlertController(title: "Sorry", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Login", style: .default, handler: {(action) in
            self.accountShowPage(AccountPageBox.init(.login), sender: self)
        }))
        alert.addAction(UIAlertAction(title: "Register", style: .default, handler: {(action) in
            self.accountShowPage(AccountPageBox.init(.register), sender: self)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showHotelOnMap(hotel: Hotel) {
        if isViewLoaded {
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegion(center: hotel.coordinate,
                                                      latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
}

extension HotelsInDestinationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get data models
        let roomInHotel = rooms[indexPath.item]
        let hotel = roomInHotel.hotel
        let room = roomInHotel.room
        
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath)
        
        cell.contentView.subviews.first?.removeFromSuperview()
        
        let user = currentUser(sender: self)
        let thisPrice = Int(room.price)
        
        let card = HotelCarouselCardView(frame: cell.contentView.bounds)
        // TODO: set card properties
        card.perNightPriceLabel.text = "Hotel cost: \(wrapPrice(Int(thisPrice)))"
        card.ratingLabel.text = "Rating: \(String(format: "%.1f", hotel.rating))"
        card.ratingValue.text = "\(String(format: "%.1f", hotel.rating))"
        
        if #available(iOS 11.0, *) {
            card.ratingBox.clipsToBounds = true
            card.ratingBox.layer.cornerRadius = 6
            card.ratingBox.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        
        card.titleLabel.text = hotel.name
        if room.numRoomsAtThisPrice == 0 {
            card.ribbonView.labelText = "No rooms left"
            card.ribbonView.ribbonColour = UIColor.TMAColors.Red
        }
        else if room.numRoomsAtThisPrice == 1 {
            card.ribbonView.labelText = "Only 1 room left!"
            card.ribbonView.ribbonColour = UIColor.TMAColors.DarkTeal
        }
        else if room.numRoomsAtThisPrice <= 5 {
            card.ribbonView.labelText = "\(room.numRoomsAtThisPrice) rooms left"
            card.ribbonView.ribbonColour = UIColor.TMAColors.DarkTeal
        }
        else {
            card.ribbonView.isHidden = true
        }
        
        if (user == nil) {
            card.ribbonView.isHidden = true
            card.perNightPriceLabel.isHidden = true
        }
        
        
        let url = URL(string:hotel.photoName)
        card.imageView.kf.setImage(with: url)
        
        cell.contentView.addSubview(card)
        return cell
    }
}

extension HotelsInDestinationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageSide = self.collectionView.bounds.width
        let offset = scrollView.contentOffset.x
        currentRoom = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
}

extension HotelsInDestinationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if #available(iOS 11.0, *) {
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: "HotelAnnotation")
            view?.isEnabled = false
            return view
        } else {
            // Fallback on earlier versions
            let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "HotelAnnotation")
            view.isEnabled = false
            return view
        }
        
    }
}

