//
//  HotelDetailsViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 17/12/2017.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import MapKit
import MaterialComponents
import UPCarouselFlowLayout
import Kingfisher
import SVProgressHUD
import Coordinator

class HotelDetailsViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var carouselContainerView: UIView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkOutLabel: UILabel!
    @IBOutlet weak var goButtonContainer: UIView!
    @IBOutlet weak var favouriteButtonContainer: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var ratingBox: UIView!
    @IBOutlet weak var ratingValue: UILabel!
    @IBOutlet weak var amenitiesLabel: UILabel!


    @IBOutlet weak var amenities1: UITextView!
    @IBOutlet weak var amenities2: UITextView!
    
  
    @IBOutlet weak var reviewsLayoutBox: UIView!
    @IBOutlet weak var readReviewsButton: UIButton!
    
    
    var hotel: DetailedHotel? {
        didSet {
            // render hotel details
            renderData()
        }
    }
    
    var destination: Destination? {
        didSet {
            
        }
    }
    
    var room: Room? {
        didSet {
            renderData()
        }
    }
    
    var trip: Trip? {
        didSet {
            
        }
    }
    
    fileprivate let reuseIdentifier = "PhotoCell"
    private var collectionView: UICollectionView!
    private let layout = UPCarouselFlowLayout()
    private var goButton: MDCButton!
    private var newFavouriteButton: MDCButton!
    
    private var shareButton: UIBarButtonItem!
    
    fileprivate var currentPage: Int = 0 {
        didSet {
            pageIndicator.currentPage = currentPage
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.textColor = UIColor.TMAColors.LightTeal
        priceLabel.textColor = UIColor.TMAColors.LightTeal
        priceLabel.font = UIFont(name: "Muli-Regular", size: 20)
        ratingLabel.textColor = UIColor.TMAColors.LightTeal
        ratingLabel.font = UIFont(name: "Muli-Regular", size: 20)
        
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
        carouselContainerView.bringSubviewToFront(pageIndicator)
        
        // button
        goButton = MDCFloatingButton()
        goButton.contentMode = .center
        goButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        goButton.imageView?.contentMode = .center
        goButton.setImage(UIImage(named: "ic2_takeoffLO"), for: .normal)
        goButton.setBackgroundColor(UIColor.TMAColors.DarkTeal)
        goButton.sizeToFit()
        goButtonContainer.addSubview(goButton)
        goButton.addTarget(self, action: #selector(userDidTapGoButton), for: .touchUpInside)
        
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
        
        if hotel == nil {
            SVProgressHUD.show()
        }

        readReviewsButton.addTarget(self, action: #selector(showReviews), for: .touchUpInside)
        
        shareButton = UIBarButtonItem(image: UIImage(named:"ic_share_white_24dp"), style: .plain, target: self, action: #selector(self.userDidTapShareButton))
        
        renderData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // fill container view
        collectionView.frame = carouselContainerView.bounds
        layout.itemSize = CGSize(width: carouselContainerView.bounds.width, height: carouselContainerView.bounds.height)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SVProgressHUD.dismiss()
    }
    

    // MARK: Data Rendering
    func renderData() {
        if let hotel = hotel, let room = room, isViewLoaded {
            
            SVProgressHUD.dismiss()
            
            let user = currentUser(sender: self)
            
            let thisPrice = Int(room.price)
            
            nameLabel.text = hotel.name
            priceLabel.text = "Hotel cost: \(wrapPrice(Int(thisPrice)))"
            descriptionLabel.text = hotel.hotelDescription
            detailsLabel.text = hotel.importantInfo
            addressLabel.text = hotel.address
            checkInLabel.text = hotel.checkinFrom
            checkOutLabel.text = hotel.checkoutTo
            
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
            
            // configure page indicator
            pageIndicator.numberOfPages = hotel.images.count 
            
            // reload collectionView
            collectionView.reloadData()
            
            // corner radius
            reviewsLayoutBox.layer.cornerRadius = CGFloat(10)
            
            // border
            reviewsLayoutBox.layer.borderWidth = CGFloat(1.0)
            reviewsLayoutBox.layer.borderColor = UIColor.TMAColors.DarkTeal.cgColor
            
            // shadow
            reviewsLayoutBox.layer.shadowColor = UIColor.TMAColors.DarkTeal.cgColor
            reviewsLayoutBox.layer.shadowOffset = CGSize(width: 1, height: 1)
            reviewsLayoutBox.layer.shadowOpacity = 0.7
            reviewsLayoutBox.layer.shadowRadius = 2.0
            
            readReviewsButton.layer.cornerRadius = CGFloat(10)
            readReviewsButton.layer.backgroundColor = UIColor.TMAColors.DarkTeal.cgColor
            readReviewsButton.tintColor = UIColor.white
            
            // show hotel on map
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(hotel)
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegion(center: hotel.coordinate,
                                                      latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    // MARK: Actions
    
    @objc func userDidTapShareButton(sender: Any?) {
        let message = trip!.shareMessage
        let url = trip!.shareUrl
        let activityViewController = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {()
            print("complete?")
        })
    }
    
    @objc func userDidTapGoButton(sender: Any?) {
        if let trip = trip {
            showSummaryForTrip(sender: self, trip: trip)
        }
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
}

extension HotelDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return hotel?.images.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get data model
        let imageUrlString = hotel!.images[indexPath.item]
        
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

extension HotelDetailsViewController: MKMapViewDelegate {
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

