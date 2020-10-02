//
//  OnboardingViewController.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 03/04/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import UIKit
import UPCarouselFlowLayout
import Kingfisher

class OnboardingViewController: UIViewController {
    
    fileprivate let reuseIdentifier = "OnboardingCell"

    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var carouselContainerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    var pages: [UIImage] = []
    private var collectionView: UICollectionView!
    private let layout = UPCarouselFlowLayout()
    
    fileprivate var currentPage: Int = 0 {
        didSet {
            if !pages.isEmpty {
                pageIndicator.currentPage = currentPage
            } else {
                // TODO: show some sort of UI error or stop before we get to this stage
            }
        }
    }
    
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
        collectionView.register(UINib(nibName: "SimpleImageCollectionViewCell", bundle:nil), forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        self.carouselContainerView.addSubview(collectionView)
        
        // populate carousel and set up page indicator
        collectionView.reloadData()
        pageIndicator.numberOfPages = pages.count
        
        closeButton.addTarget(self, action: #selector(userDidTapCloseButton), for: .touchUpInside)

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
    
    @objc func userDidTapCloseButton(sender: Any?) {
        self.destinationShowPage(DestinationPageBox(.chooseDestination), sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Show the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

}

extension OnboardingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get data models
        let page = pages[indexPath.item]
        
        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! SimpleImageCollectionViewCell

        // set image in cell to page
        cell.imageView.image = page
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageSide = self.collectionView.bounds.width
        let offset = scrollView.contentOffset.x
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
}
