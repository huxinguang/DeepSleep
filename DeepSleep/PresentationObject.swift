//
//  PresentationObject.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/24.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class PresentationObject: NSObject, UIViewControllerTransitioningDelegate {
    static let share: PresentationObject = {
        let instance = PresentationObject()
        return instance
    }()
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting) as? UIViewControllerAnimatedTransitioning
    }

}
