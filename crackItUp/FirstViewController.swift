//
//  FirstViewController.swift
//  crackItUp
//
//  Created by TANVI HARDE on 12/08/25.
//

import UIKit

class FirstViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
 
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    @IBOutlet weak var CollectionView: UICollectionView!
    
    var currentIndex = 0
    var timer: Timer?
    
    var RoundsImages: [String] = ["img1","img2", "img3", "img4"]
 
    override func viewDidLoad() {
        super.viewDidLoad()
        CollectionView.delegate = self
        CollectionView.dataSource = self
        CollectionView.isPagingEnabled = true
        CollectionView.isScrollEnabled = true
               CollectionView.showsHorizontalScrollIndicator = false
               CollectionView.alwaysBounceHorizontal = true
        if let layout = CollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                    layout.scrollDirection = .horizontal
                    layout.minimumLineSpacing = 0
                    layout.estimatedItemSize = .zero
                }

                pageControl.numberOfPages = RoundsImages.count
                pageControl.currentPage = 0
            }

            override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                // Ensure the collection has its final size before starting the timer
                CollectionView.collectionViewLayout.invalidateLayout()
                startAutoScroll()
            }

            override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                timer?.invalidate()
            }

            // MARK: - DataSource
            func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                RoundsImages.count
            }

            func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
                cell.rounds.image = UIImage(named: RoundsImages[indexPath.item])
                cell.rounds.layer.cornerRadius = 0
                return cell
            }

            // MARK: - FlowLayout sizing (critical for paging)
            func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                                sizeForItemAt indexPath: IndexPath) -> CGSize {
                // Make each cell exactly one “page” wide
                return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
            }

    
    @IBAction func pageControlChanged(_ sender: UIPageControl) {
        currentIndex = sender.currentPage
               let indexPath = IndexPath(item: currentIndex, section: 0)
               CollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { timer?.invalidate() }

        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            currentIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
            pageControl.currentPage = currentIndex
            startAutoScroll()
        }

        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.bounds.width))
            pageControl.currentPage = pageIndex
            currentIndex = pageIndex
        }

        // MARK: - Auto scroll
        func startAutoScroll() {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 2.0,
                                         target: self,
                                         selector: #selector(moveToNextPage),
                                         userInfo: nil,
                                         repeats: true)
        }

    @objc func moveToNextPage() {
        let nextIndex = currentIndex + 1

        if nextIndex < RoundsImages.count {
            // Normal scroll
            let indexPath = IndexPath(item: nextIndex, section: 0)
            CollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            currentIndex = nextIndex
        } else {
            // Last → First jump without animation
            let indexPath = IndexPath(item: 0, section: 0)
            CollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            currentIndex = 0
        }

        pageControl.currentPage = currentIndex
    }

    
    @IBAction func `continue`(_ sender: Any){
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @IBAction func LoginBtn(_ sender: Any) {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
        
    }
    
    

}
