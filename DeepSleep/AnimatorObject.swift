//
//  AnimatorObject.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/26.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


enum AnimatorType {
    case present
    case dismiss
}

class AnimatorObject: NSObject {
    
    fileprivate var type: AnimatorType!
    fileprivate var duration: TimeInterval!
    fileprivate let disposeBag = DisposeBag()

    convenience init(type: AnimatorType, duration: TimeInterval) {
        self.init()
        self.type = type
        self.duration = duration
    }
    
}

extension AnimatorObject: UIViewControllerAnimatedTransitioning{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(true)
            return
        }
        
        if type == .present {
            let dv = UIControl(frame: UIScreen.main.bounds)
            dv.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            transitionContext.containerView.addSubview(dv)
            dv.addSubview(toVC.view)
            
            toVC.view.frame = CGRect(x: 0, y: -Styles.Constant.music_type_view_height , width: UIScreen.main.bounds.size.width, height: Styles.Constant.music_type_view_height)
            if let vc = toVC as? MusicTypeVC {
                dv.addTarget(vc, action: #selector(vc.onCloseBtn(_:)), for: .touchUpInside)
            }

            dv.alpha = 0
            UIView.animate(withDuration: duration, animations: {
                toVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Styles.Constant.music_type_view_height)
                dv.alpha = 1
            }) { (finished) in
                transitionContext.completeTransition(finished)
            }
        }else{
            guard let vc = fromVC as? MusicTypeVC else {
                transitionContext.completeTransition(true)
                return
            }
            vc.view.superview?.alpha = 1
            vc.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Styles.Constant.music_type_view_height)
            UIView.animate(withDuration: duration, animations: {
                vc.view.frame = CGRect(x: 0, y: -Styles.Constant.music_type_view_height, width: UIScreen.main.bounds.size.width, height: Styles.Constant.music_type_view_height)
                vc.view.superview?.alpha = 0
            }) { (finished) in
                transitionContext.completeTransition(finished)
            }
            
        }
        
    }
    
}
