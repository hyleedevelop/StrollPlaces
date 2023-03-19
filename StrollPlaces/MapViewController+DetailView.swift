//
//  MapViewController+DetailView.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/19.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx

extension MapViewController {
    
    internal func setupDetailView(){
        self.view.addSubview(self.detailView)
        
        self.detailView.frame = CGRect(x: 0,
                                       y: self.view.bounds.height,
                                       width: self.view.bounds.width,
                                       height: K.DetailView.slideViewHeight)
        
        self.detailView.layoutIfNeeded()
        self.detailView.addDropShadow(cornerRadius: K.DetailView.cornerRadiusOfSlideView)
        
        ////blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
//        blackView.frame = self.view.frame
//        blackView.frame.size.height = self.view.frame.height
//        blackView.alpha = 0
//        self.view.insertSubview(blackView, belowSubview: self.detailView)
//        blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        
        let downPan = UIPanGestureRecognizer(target: self, action: #selector(dismissSlideUpView(_:)))
        self.detailView.addGestureRecognizer(downPan)
    }
 
    // Animation when user interacts with the slide view
    @objc private func dismissSlideUpView(_ gestureRecognizer:UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: self.detailView)
        switch gestureRecognizer.state{
        case .began, .changed:
            // Pan gesture began and continued
            gestureRecognizer.view!.center = CGPoint(x: self.detailView.center.x, y: max(gestureRecognizer.view!.center.y + translation.y, originalCenterOfslideUpView))
            gestureRecognizer.setTranslation(CGPoint.zero, in: self.detailView)
            self.totalDistance += translation.y
            break
        case .ended:
            // Pan gesture ended
            // Set a constant : self.slideUpView.center.y > self.view.bounds.height - 40
            // OR set the following if statement
            if gestureRecognizer.velocity(in: self.detailView).y > 300 {
                handleDismiss()
            } else if self.totalDistance >= 0{
                UIView.animate(withDuration: TimeInterval(animationTime), delay: 0, options: [.curveEaseOut],
                               animations: {
                                self.detailView.center.y -= self.totalDistance
                                self.detailView.layoutIfNeeded()
                }, completion: nil)
            } else {
                // Cate other exceptions
                
            }
            
            self.totalDistance = 0
            break
        case .failed:
            print("Failed to do UIPanGestureRecognizer with slideUpView")
            break
        default:
            //default
            print("default: UIPanGestureRecognizer")
            break
        }
        
        print(self.isDetailViewHidden ? "Hidden" : "Shown")
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: TimeInterval(self.animationTime)) {
//                self.blackView.alpha = 0
                self.detailView.layer.cornerRadius = 0
                self.detailView.backgroundColor = UIColor.white
            }
        }
        
        self.detailView.slideDownHide(self.animationTime)
        
        self.isDetailViewHidden = true
    }
    
    internal func showDetailView() {
        self.totalDistance = 0
        self.detailView.frame = CGRect(x: 0,
                                       y: self.view.bounds.height - self.view.safeAreaInsets.bottom,
                                       width: self.view.bounds.width,
                                       height: K.DetailView.slideViewHeight)
        
        //DispatchQueue.main.async {
            //UIView.animate(withDuration: self.animationTime, delay: 0.0, options: .curveEaseOut) {
                //self.blackView.alpha = 0.0
                self.detailView.backgroundColor = UIColor.white
                self.detailView.layer.cornerRadius = K.DetailView.cornerRadiusOfSlideView
                self.detailView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            //}
        //}
        
        self.detailView.slideUpShow(animationTime)
        originalCenterOfslideUpView = self.detailView.center.y
        
        self.isDetailViewHidden = false
    }
    
}
