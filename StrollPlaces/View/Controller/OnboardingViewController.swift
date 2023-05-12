//
//  OnboardingViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/09.
//

import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {

    //MARK: - IB outlet
    
    @IBOutlet weak var onboardingCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var hideNextTimeButton: UIButton!
    
    //MARK: - normal property
    
    private let viewModel = OnboardingViewModel()
    private let userDefaults = UserDefaults.standard
    
    private var currentPage = 0 {
        didSet {
            self.pageControl.currentPage = currentPage
            
            if self.currentPage == self.viewModel.slide.count - 1 {
                // 마지막 페이지의 경우 시작 버튼으로 작동
                self.nextButton.changeAttributes(buttonTitle: "시작하기", interaction: true)
                self.hideNextTimeButton.isHidden = false
            } else {
                // 나머지 페이지의 경우 다음 버튼으로 작동
                self.nextButton.changeAttributes(buttonTitle: "다음", interaction: true)
                self.hideNextTimeButton.isHidden = true
            }
        }
    }
    
    private var isHideNextTimeChecked = false {
        didSet {
            if self.isHideNextTimeChecked {
                self.userDefaults.setValue(false, forKey: "hideOnboardingScreen")
            } else {
                self.userDefaults.setValue(true, forKey: "hideOnboardingScreen")
            }
        }
    }
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCollectionView()
        self.setupPageControl()
        self.setupButton()
    }
    
    //MARK: - directly called method
    
    // Collection View 설정
    private func setupCollectionView() {
        self.onboardingCollectionView.delegate = self
        self.onboardingCollectionView.dataSource = self
    }

    // PageControl 설정
    private func setupPageControl() {
        self.pageControl.currentPageIndicatorTintColor = K.Color.themeGreen
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
    }
    
    // Button 설정
    private func setupButton() {
        self.nextButton.backgroundColor = K.Color.themeGreen
        self.nextButton.layer.cornerRadius = self.nextButton.frame.height / 2.0
        self.nextButton.changeAttributes(buttonTitle: "다음", interaction: true)
        
        self.hideNextTimeButton.isHidden = true
        self.hideNextTimeButton.setImage(UIImage(systemName: "square"),
                                         for: .normal)
    }
    
    //MARK: - IB action
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // 마지막 페이지인 경우
        if self.currentPage == self.viewModel.slide.count - 1 {
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
                    as? UITabBarController else { return }
            
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .slide(direction: .up),
                                                       dismissing: .slide(direction: .up))
            
            self.present(nextVC, animated: true, completion: nil)
            
        } else {
            self.currentPage += 1
            let indexPath = IndexPath(item: self.currentPage, section: 0)
            self.onboardingCollectionView.scrollToItem(
                at: indexPath, at: .centeredHorizontally, animated: true
            )
        }
    }
    
    @IBAction func hideNextTimeButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async {
            if self.isHideNextTimeChecked {
                self.hideNextTimeButton.setImage(UIImage(systemName: "square"),
                                                 for: .normal)
            } else {
                self.hideNextTimeButton.setImage(UIImage(systemName: "checkmark.square"),
                                                 for: .normal)
            }
        }
        
        self.isHideNextTimeChecked.toggle()
    }
    
    //MARK: - directly called method
   
    
}

//MARK: - extension for

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.slide.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OnboardingCollectionViewCell", for: indexPath)
                as? OnboardingCollectionViewCell else { fatalError() }
        
        cell.setup(self.viewModel.slide[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        self.currentPage = Int(scrollView.contentOffset.x / width)
    }
    
}
