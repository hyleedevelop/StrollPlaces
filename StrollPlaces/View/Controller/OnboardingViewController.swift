//
//  OnboardingViewController.swift
//  StrollPlaces
//
//  Created by Eric on 2023/05/09.
//

import UIKit
import SnapKit
import UICheckbox_Swift

final class OnboardingViewController: UIViewController {

    //MARK: - IB outlet
    
    @IBOutlet weak var onboardingCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    private let checkBox: UICheckbox = {
        let box = UICheckbox(type: .custom)
        box.onSelectStateChanged = { (checkbox, selected) in
            debugPrint("Clicked - \(selected)")
        }
        return box
    }()
    
    //MARK: - normal property
    
    private let viewModel = OnboardingViewModel()
    private var currentPage = 0 {
        didSet {
            self.pageControl.currentPage = currentPage
            
            if self.currentPage == self.viewModel.slide.count - 1 {
                // 마지막 페이지의 경우 시작 버튼으로 작동
                self.nextButton.changeAttributes(buttonTitle: "시작하기", interaction: true)
                self.showCheckBox()
            } else {
                // 나머지 페이지의 경우 다음 버튼으로 작동
                self.nextButton.changeAttributes(buttonTitle: "다음", interaction: true)
            }
        }
    }
    
    //MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCollectionView()
        self.setupPageControl()
        self.setupButton()
        self.setupCheckBox()
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
    }
    
    // CheckBox 설정
    private func setupCheckBox() {
        self.view.addSubview(self.checkBox)
        
        self.checkBox.snp.makeConstraints {
            $0.top.equalTo(self.nextButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        self.checkBox.isHidden = true
    }
    
    //MARK: - IB action
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        // 마지막 페이지인 경우
        if self.currentPage == self.viewModel.slide.count - 1 {
            guard let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBar")
                    as? UITabBarController else { return }
            
            nextVC.modalPresentationStyle = .fullScreen
            nextVC.hero.isEnabled = true
            nextVC.hero.modalAnimationType = .selectBy(presenting: .zoomSlide(direction: .left),
                                                       dismissing: .zoomSlide(direction: .left))
            
            self.present(nextVC, animated: true, completion: nil)
            
        } else {
            self.currentPage += 1
            let indexPath = IndexPath(item: self.currentPage, section: 0)
            self.onboardingCollectionView.scrollToItem(
                at: indexPath, at: .centeredHorizontally, animated: true
            )
        }
    }
    
    //MARK: - directly called method
    
    private func showCheckBox() {
        self.checkBox.isHidden = false
    }
    
    
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
