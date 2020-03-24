//
//  CustomPresentationController.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/24.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class CustomPresentationController: UIPresentationController {
    
    fileprivate lazy var dimmingView: UIView = {
        let dv = UIControl(frame: UIScreen.main.bounds)
        dv.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        dv.addTarget(self, action: #selector(onDimViewClicked), for: .touchUpInside)
        return dv
    }()
    
    /*
     The default implementation of this method does nothing. Subclasses can override it and use it to add custom views to the view hierarchy and to create any animations associated with those views.
     */
    override func presentationTransitionWillBegin() {
        containerView?.addSubview(dimmingView)
        dimmingView.addSubview(presentedViewController.view)
        let transitionCoordinator = presentingViewController.transitionCoordinator
        dimmingView.alpha = 0
        /*
         To perform your animations, get the transition coordinator of the presented view controller and call its animate(alongsideTransition:completion:) or animateAlongsideTransition(in:animation:completion:) method. Calling those methods ensures that your animations are executed at the same time as any other transition animations.
         */
        transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 1
        }, completion: nil)
        
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
//        if completed {
//            dimmingView.removeFromSuperview()
//        }
    }
    
    override func dismissalTransitionWillBegin() {
        
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
    }
    
    override var frameOfPresentedViewInContainerView: CGRect{
        return CGRect(x: 0, y: UIScreen.main.bounds.size.height-300, width: UIScreen.main.bounds.size.width, height: 300)
    }
    
//    override var shouldPresentInFullscreen: Bool{
//        return false
//    }

    @objc
    fileprivate func onDimViewClicked(){
        guard let vc = presentedViewController as? MusicListVC else { return }
        
    }
    
    
    
}
