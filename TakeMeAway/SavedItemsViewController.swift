//
//  SavedItemsViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 17/12/2017.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import Floaty
import UPCarouselFlowLayout
import MaterialComponents
import Kingfisher
import SVProgressHUD
import FlexiblePageControl

class SavedItemsViewController: UIViewController {
    
    fileprivate let reuseIdentifier = "SavedItemCell"

    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var goButtonContainer: UIView!
    @IBOutlet weak var moreActionsButton: Floaty!
    @IBOutlet weak var carouselContainerView: UIView!
    @IBOutlet weak var flexiblePageControl: FlexiblePageControl!
    
    private var collectionView: UICollectionView!
    private let layout = UPCarouselFlowLayout()
    private var goButton: MDCButton!
    
//    let pageControl = FlexiblePageControl()
    
    fileprivate var currentPage: Int = 0 {
        didSet {
            if !savedItems.isEmpty {
                currentItem = savedItems[currentPage]
                flexiblePageControl.setCurrentPage(at: currentPage)
            } else {
                // TODO: show some sort of UI error or stop before we get to this stage
            }
        }
    }
    var savedItems: [SavedItem] = [] {
        didSet {
            if isViewLoaded {
                collectionView.reloadData()
                
                // hide buttons if there are no items
                moreActionsButton.isHidden = savedItems.isEmpty

                flexiblePageControl.numberOfPages = savedItems.count
                flexiblePageControl.pageIndicatorTintColor = UIColor.TMAColors.DarkTeal
                flexiblePageControl.currentPageIndicatorTintColor = UIColor.TMAColors.LightTeal
                flexiblePageControl.setCurrentPage(at: 0)
                collectionView.collectionViewLayout.invalidateLayout()
            }
            
            currentPage = 0
        }
    }
    var currentItem: SavedItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // configure collection view
        layout.scrollDirection = .horizontal
        layout.sideItemScale = 1.0
        layout.sideItemAlpha = 1.0
        layout.spacingMode = UPCarouselFlowLayoutSpacingMode.fixed(spacing: 0.0)
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.register(UINib(nibName: "SavedItemCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.carouselContainerView.addSubview(collectionView)
        
        // configure buttons
        moreActionsButton.openAnimationType = .slideLeft
        moreActionsButton.plusColor = UIColor.TMAColors.LightTeal
        moreActionsButton.itemImageColor = UIColor.TMAColors.LightTeal
        moreActionsButton.itemTitleColor = UIColor.TMAColors.LightTeal
        moreActionsButton.tintColor = UIColor.TMAColors.LightTeal
        moreActionsButton.buttonColor = UIColor.TMAColors.DarkTeal
        moreActionsButton.itemButtonColor = UIColor.TMAColors.DarkTeal
        moreActionsButton.addItem("Remove Hotel and Destination", icon: UIImage(named:"ic2_delete"), handler: {(buttonItem) in
            SVProgressHUD.setForegroundColor(UIColor.TMAColors.LightTeal)
            SVProgressHUD.show()
            self.deleteSavedHotelAndDestination(sender: self, hotelId: self.currentItem!.hotelId, cityId: self.currentItem!.cityId, completion: {(error) in
                if let error = error {
                    // handle error
                    SVProgressHUD.showError(withStatus: "Error removing saved item: \(error)")
                } else {
                    // handle deletion
                    SVProgressHUD.showSuccess(withStatus: "Saved item removed!")
                    self.updateData()
                }
            })
        })
        
        goButton = MDCFloatingButton()
        goButton.contentMode = .center
        goButton.imageView?.tintColor = UIColor.TMAColors.LightTeal
        goButton.imageView?.contentMode = .center
        goButton.setImage(UIImage(named: "ic2_takeoffLO"), for: .normal)
        goButton.setBackgroundColor(UIColor.TMAColors.DarkTeal)
        goButton.sizeToFit()
        goButtonContainer.addSubview(goButton)
        goButton.addTarget(self, action: #selector(userDidTapGoButton), for: .touchUpInside)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // load the saved items
        updateData()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        layout.invalidateLayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
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
    }

    @objc func userDidTapGoButton(sender: Any?) {
        let item = savedItems[currentPage]
        
        if item.hotelId == 0 {
            
            do {
                let destination: Destination = try Destination(saveditem: item)
                showHotelsForDestination(sender: self, destination: destination)
            } catch _ {
                
            }
        } else {
            showSummaryForSavedItem(sender: self, item: item)
        }
        
    }
    
    //    MARK: Data updates
    
    func updateData() {
        SVProgressHUD.show()
        
        fetchSavedItems(sender: self) {
            [weak self] arr, error in
            guard let `self` = self else {
                SVProgressHUD.dismiss()
                return
            }
            
            // hide spinner on error
            if let error = error {
                if self.isLoggedIn(sender: self) {
                    SVProgressHUD.dismiss()
                    let alert = UIAlertController(title: "Sorry", message: "Unable to fetch saved items.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true)
                } else {
                    SVProgressHUD.showError(withStatus: "Unable to fetch destinations. ErrorCode: 4")
                }
                return
            }
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if arr.count == 0 {
                    self.collectionView.isHidden = true
                    self.moreActionsButton.isHidden = true
                    self.goButtonContainer.isHidden = true
                    self.carouselContainerView.isHidden = true
                    SVProgressHUD.showError(withStatus: "You don't have any saved destinations yet!")
                } else {
                    self.savedItems = arr
                    print("set \(arr.count) saved items")
                    self.flexiblePageControl.numberOfPages = self.savedItems.count
                    self.flexiblePageControl.pageIndicatorTintColor = UIColor.TMAColors.DarkTeal
                    self.flexiblePageControl.currentPageIndicatorTintColor = UIColor.TMAColors.LightTeal
                    self.flexiblePageControl.setCurrentPage(at: 0)
                    self.collectionView.collectionViewLayout.invalidateLayout()
                }
            }
        }
    }
}

extension SavedItemsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return savedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get data models
        let item = savedItems[indexPath.item]
        
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! SavedItemCollectionViewCell
        
        cell.cityLabel.textColor = UIColor.TMAColors.LightTeal
        cell.savedOn.textColor = UIColor.TMAColors.LightTeal
        cell.flightPrice.textColor = UIColor.TMAColors.LightTeal
        cell.hotelPrice.textColor = UIColor.TMAColors.LightTeal
        
        cell.cityLabel.text = item.cityName
        cell.cityImageView.kf.setImage(with: URL(string:item.cityImage))
        
        if item.hotelId != 0 {
            cell.hotelLabel.textColor = UIColor.TMAColors.LightTeal
            cell.hotelLabel.text = item.hotelName
            cell.hotelImageView.kf.setImage(with: URL(string:item.hotelImage))
            cell.hotelPrice.text = wrapPrice(item.hotelprice!)
            cell.ratingValue.text = "\(String(format: "%.1f", item.rating!))"
            if #available(iOS 11.0, *) {
                cell.ratingBox.clipsToBounds = true
                cell.ratingBox.layer.cornerRadius = 6
                cell.ratingBox.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
            } else {
                // Fallback on earlier versions
            }
            cell.ratingValue.textColor = UIColor.white
            if (item.hotelprice == 0) {
                cell.hotelPrice.isHidden = true
            }
            cell.hotelLabel.isHidden = false
            cell.hotelImageView.isHidden = false
            cell.hotelPrice.isHidden = false
            cell.ratingValue.isHidden = false
            cell.ratingBox.isHidden = false
            cell.hotelGradient.isHidden = false
            collectionView.reloadItems(at: [indexPath])
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        } else {
            cell.cityImageView.frame = view.bounds
            
            cell.hotelLabel.isHidden = true
            cell.hotelImageView.isHidden = true
            cell.hotelPrice.isHidden = true
            cell.ratingValue.isHidden = true
            cell.ratingBox.isHidden = true
            
            cell.cityImageView.contentMode = .scaleAspectFill
            cell.hotelGradient.isHidden = true
            
            collectionView.reloadItems(at: [indexPath])
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
        cell.flightPrice.text = wrapPrice(item.flightprice!)
        
        let unixTimestamp = Double(item.savedon)
        let date = Date(timeIntervalSince1970: unixTimestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd-MM-yyyy" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        cell.savedOn.text = "Saved on: " + strDate
        
        if (item.savedon == 0) {
            cell.savedOn.isHidden = true
        }
        if (item.flightprice == 0) {
            cell.flightPrice.isHidden = true
        }

        // force labels to front because for some reason they are not laid out in order specified in nib
        if item.hotelId != 0 {
            cell.hotelLabel?.superview?.bringSubviewToFront(cell.hotelLabel)
            cell.hotelPrice?.superview?.bringSubviewToFront(cell.hotelPrice)
            cell.ratingBox?.superview?.bringSubviewToFront(cell.ratingBox)
            cell.ratingValue?.superview?.bringSubviewToFront(cell.ratingValue)
        }
        cell.cityLabel?.superview?.bringSubviewToFront(cell.cityLabel)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(userDidTapGoButton(sender:)))
        cell.isUserInteractionEnabled = true
        cell.addGestureRecognizer(tapGestureRecognizer)
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageSide = self.collectionView.bounds.width
        let offset = scrollView.contentOffset.x
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.flexiblePageControl.setProgress(contentOffsetX: scrollView.contentOffset.x, pageWidth: scrollView.bounds.width)
    }
    
}
