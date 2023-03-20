//
//  PlaceInfoViewController+Modal.swift
//  StrollPlaces
//
//  Created by Eric on 2023/03/20.
//

import UIKit
import SnapKit

extension PlaceInfoViewController {
    
    //MARK: - internal functions
    
    internal func setupConstraints() {
        // Set dynamic constraints
        // First, set container to default height
        // after panning, the height can expand
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)
        
        // By setting the height to default height, the container will be hide below the bottom anchor view
        // Later, will bring it up by set it to 0
        // set the constant to default height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }
    
    internal func setupTapGesture() {
        // tap gesture on dimmed view to dismiss
        let tapGesture = UITapGestureRecognizer(
            target: self, action: #selector(self.handleCloseAction)
        )
        dimmedView.addGestureRecognizer(tapGesture)
    }
    
    internal func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
        self.containerView.addGestureRecognizer(panGesture)
    }
    
    internal func animateShowDimmedView() {
        dimmedView.alpha = 0
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.dimmedView.alpha = self.maxDimmedAlpha
            }
        }
    }
    
    internal func animateDismissView() {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                self.dimmedView.alpha = 0
            } completion: { _ in
                // once done, dismiss without animation
                self.dismiss(animated: false)
            }
            // hide main view by updating bottom constraint in animation block
            UIView.animate(withDuration: 0.3) {
                self.containerViewBottomConstraint?.constant = self.defaultHeight
                // call this to trigger refresh constraint
                self.view.layoutIfNeeded()
            }
        }
    }
    
    internal func animateContainerHeight(_ height: CGFloat) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                // Update container height
                self.containerViewHeightConstraint?.constant = height
                // Call this to trigger refresh constraint
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.setupTableView()
                self.view.layoutIfNeeded()
            }
            
            // Save current height
            self.currentContainerHeight = height
        }
    }
    
    // Present and dismiss animation
    internal func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - private functions
    
    // MARK: Pan gesture handler
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
//        print("Pan gesture y offset: \(translation.y)")
        
        // Get drag direction
        let isDraggingDown = translation.y > 0
//        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")
        
        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y
        
        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container
            
            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                self.tableView.removeFromSuperview()
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }
    
    @objc private func handleCloseAction() {
        animateDismissView()
    }
            
}
