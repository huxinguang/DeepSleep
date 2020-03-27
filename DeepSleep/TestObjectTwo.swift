//
//  TestObjectTwo.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/27.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class TestObjectTwo: NSObject {
    static let share: TestObjectTwo = {
        let instance = TestObjectTwo()
        return instance
    }()
}

extension TestObjectTwo: UIViewControllerTransitioningDelegate{
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatorObjectTwo(type: .present, duration: 0.5)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimatorObjectTwo(type: .dismiss, duration: 0.5)
    }
}
