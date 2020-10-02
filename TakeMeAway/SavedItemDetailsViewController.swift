//
//  SavedItemDetailsViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 25/02/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import MapKit
import MaterialComponents
import UPCarouselFlowLayout
import Kingfisher
import SVProgressHUD

class SavedItemDetailsViewController: UIViewController {
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var hotelNameLabel: UILabel!
    @IBOutlet weak var cityImageView: UIImageView!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var carouselContainerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var goButtonContainer: UIView!
    @IBOutlet weak var deleteButtonContainer: UIView!
    @IBOutlet weak var carouselPageIndicator: UIPageControl!
    
    @IBOutlet weak var ratingBox: UIView!
    @IBOutlet weak var ratingValue: UILabel!
    
    @IBOutlet weak var amenities1: UITextView!
    @IBOutlet weak var amenities2: UITextView!
    @IBOutlet weak var readReviewsButton: UIButton!
    @IBOutlet weak var reviewslayoutBox: UIView!
    
    
    var savedItem: SavedItem!
    var hotelImages: [String] = [] {
        didSet {
            if isViewLoaded {
                carouselPageIndicator.numberOfPages = hotelImages.count
                collectionView?.reloadData()
            }
        }
    }
    var hotel: DetailedHotel? {
        didSet {
            if let hotel = hotel {
                hotelImages = hotel.images
                    if isViewLoaded {
                        renderHotelDetails()
                    }
                }
            }
            
    }
    
    fileprivate let reuseIdentifier = "PhotoCell"
    private var collectionView: UICollectionView!
    private let layout = UPCarouselFlowLayout()
    private var goButton: MDCButton!
    private var deleteButton: MDCButton!
    private var mapView: MKMapView!
    
    fileprivate var currentPage: Int = 0 {
        didSet {
            carouselPageIndicator.currentPage = currentPage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // render data we know we have
        cityImageView.kf.setImage(with: URL(string: savedItem.cityImage))
        cityNameLabel.text = savedItem.cityName
        hotelNameLabel.text = savedItem.hotelName
        
        // configure map
        mapView = MKMapView(frame: self.mapContainerView.bounds)
        mapView.isUserInteractionEnabled = false
        mapView.delegate = self
        mapContainerView.addSubview(mapView)

        // configure collection view
        layout.scrollDirection = .horizontal
        layout.sideItemScale = 1.0
        layout.sideItemAlpha = 1.0
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 0.0)
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "SimpleImageCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        carouselContainerView.addSubview(collectionView)
        carouselContainerView.sendSubviewToBack(collectionView)
        
        
        // buttons
        goButton = MDCFloatingButton()
        goButton.contentMode = .center
        goButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        goButton.imageView?.contentMode = .center
        goButton.setImage(UIImage(named: "ic2_takeoffLO"), for: .normal)
        goButton.setBackgroundColor(UIColor.TMAColors.DarkTeal)
        goButton.sizeToFit()
        goButtonContainer.addSubview(goButton)
        goButton.addTarget(self, action: #selector(userDidTapGoButton), for: .touchUpInside)
        
        deleteButton = MDCFloatingButton()
        deleteButton.contentMode = .center
        deleteButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        deleteButton.imageView?.contentMode = .center
        deleteButton.setImage(UIImage(named: "ic2_delete"), for: .normal)
        deleteButton.setBackgroundColor(UIColor.TMAColors.DarkTeal)
        deleteButton.sizeToFit()
        deleteButtonContainer.addSubview(deleteButton)
        deleteButton.addTarget(self, action: #selector(userDidTapDeleteButton), for: .touchUpInside)
        
        readReviewsButton.addTarget(self, action: #selector(showReviews), for: .touchUpInside)
        
        if let hotel = hotel {
            hotelImages = hotel.images
            renderHotelDetails()
        } else {
            hotelImages.append(savedItem.hotelImage)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // fill container view
        collectionView.frame = carouselContainerView.bounds
        layout.itemSize = CGSize(width: carouselContainerView.bounds.width, height: carouselContainerView.bounds.height)
        
        mapView.frame = mapContainerView.bounds
    }
    
    @objc func showReviews() {
        
        let baseurl = hotel?.url.components(separatedBy: "/")
        print("baseurl: " + (baseurl?.last)!)
        let stub = baseurl?.last?.replacingOccurrences(of: ".html", with: "")
        print("stub: " + stub!)
        
        let cc = hotel?.countrycode
        
        let reviewuri = "https://www.booking.com/reviewlist.html?tmpl=reviewlistpopup;pagename="+stub!+";hrwt=1;cc1="+cc!+";target_aid=1362236;aid=1362236;target_label=TakeMeAway;target_lang=en;"
        
        UserDefaults.standard.set(reviewuri, forKey: "reviewuri")
        helpShowPage(HelpPageBox(.reviews), sender: self)
    }
    
    // MARK: Rendering data
    func renderHotelDetails() {
        if let hotel = hotel {
            descriptionLabel.text = hotel.hotelDescription
            detailsLabel.text = hotel.importantInfo
            addressLabel.text = hotel.address
            checkInLabel.text = "From \(hotel.checkinFrom) until \(hotel.checkinTo)"
            
            // show hotel on map
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(hotel)
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegion(center: hotel.coordinate,
                                                      latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
            
            ratingValue.text = "\(String(format: "%.1f", hotel.rating))"
            if #available(iOS 11.0, *) {
                ratingBox.clipsToBounds = true
                ratingBox.layer.cornerRadius = 6
                ratingBox.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
            } else {
                // Fallback on earlier versions
            }
            
            amenities1.text = hotel.amenities1!.replacingOccurrences(of: "<br/>", with: "\n").replacingOccurrences(of: "&#8226;", with: "•")
            amenities2.text = hotel.amenities2!.replacingOccurrences(of: "<br/>", with: "\n").replacingOccurrences(of: "&#8226;", with: "•")
            
            // corner radius
            reviewslayoutBox.layer.cornerRadius = CGFloat(10)
            
            // border
            reviewslayoutBox.layer.borderWidth = CGFloat(1.0)
            reviewslayoutBox.layer.borderColor = UIColor.TMAColors.DarkTeal.cgColor
            
            // shadow
            reviewslayoutBox.layer.shadowColor = UIColor.TMAColors.DarkTeal.cgColor
            reviewslayoutBox.layer.shadowOffset = CGSize(width: 1, height: 1)
            reviewslayoutBox.layer.shadowOpacity = 0.7
            reviewslayoutBox.layer.shadowRadius = 2.0
            
            readReviewsButton.layer.cornerRadius = CGFloat(10)
            readReviewsButton.layer.backgroundColor = UIColor.TMAColors.DarkTeal.cgColor
            readReviewsButton.tintColor = UIColor.white
        }
    }
    
    // MARK: Actions
    @objc func userDidTapGoButton(sender: Any?) {
        if let hotel = hotel {
            let trip = Trip(savedItem: savedItem, detailedHotel: hotel)
            showSummaryForTrip(sender: self, trip: trip)
        }
    }
    
    @objc func userDidTapDeleteButton(sender: Any?) {
        // delete saved item
        SVProgressHUD.show()
        self.deleteSavedHotelAndDestination(sender: self, hotelId: savedItem.hotelId, cityId: savedItem.cityId, completion: {(error) in
            if let error = error {
                // handle error
                SVProgressHUD.showError(withStatus: "Error removing saved item: \(error)")
            } else {
                // handle deletion
                SVProgressHUD.showSuccess(withStatus: "Saved item removed!")
                self.userDidDeleteSavedItemFromDetailsPage()
            }
        })
    }
}

extension SavedItemDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotelImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get data model
        let imageUrlString = hotelImages[indexPath.item]
        
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! SimpleImageCollectionViewCell
        
        let url = URL(string:imageUrlString)
        cell.imageView.kf.setImage(with: url)
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageSide = self.collectionView.bounds.width
        let offset = scrollView.contentOffset.x
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
}

extension SavedItemDetailsViewController: MKMapViewDelegate {
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
