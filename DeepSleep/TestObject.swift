//
//  TestObject.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/26.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class TestObject: NSObject {

    static let share: TestObject = {
        let instance = TestObject()
        return instance
    }()
    
}

extension TestObject: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatorObject(type: .present, duration: 0.5)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatorObject(type: .dismiss, duration: 0.5)
    }
}
