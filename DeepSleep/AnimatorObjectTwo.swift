//
//  AnimatorObjectTwo.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/27.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class AnimatorObjectTwo: NSObject {
    fileprivate var type: AnimatorType!
    fileprivate var duration: TimeInterval!

    convenience init(type: AnimatorType, duration: TimeInterval) {
        self.init()
        self.type = type
        self.duration = duration
    }
    
}

extension AnimatorObjectTwo: UIViewControllerAnimatedTransitioning{
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to), let fromVC = transitionContext.viewController(forKey: .from) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let dv = UIControl(frame: UIScreen.main.bounds)
        transitionContext.containerView.addSubview(dv)
        dv.addSubview(type == .present ? toVC.view : fromVC.view)
        
        if type == .present {
            toVC.view.frame = CGRect(x: 0, y: Styles.Constant.music_type_view_height-Styles.Constant.music_type_list_view_height , width: UIScreen.main.bounds.size.width, height: Styles.Constant.music_type_list_view_height)
            if let vc = fromVC as? MusicTypeVC {
                vc.closeBtn.isHidden = true
            }
            if let vc = toVC as? MusicTypeListVC {
                vc.tableView.alpha = 0
                dv.addTarget(vc, action: #selector(vc.onCloseBtn(_:)), for: .touchUpInside)
            }
            
        }else{
            fromVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Styles.Constant.music_type_list_view_height)
            if let vc = toVC as? MusicTypeVC {
                vc.closeBtn.isHidden = false
            }
        }
                
        UIView.animate(withDuration: duration, animations: {
            if self.type == .present {
                toVC.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: Styles.Constant.music_type_list_view_height)
                if let vc = fromVC as? MusicTypeVC {
                    vc.collectionView.alpha = 0
                }
                if let vc = toVC as? MusicTypeListVC {
                    vc.tableView.alpha = 1
                }
            }else{
                fromVC.view.frame = CGRect(x: 0, y: Styles.Constant.music_type_view_height-Styles.Constant.music_type_list_view_height, width: UIScreen.main.bounds.size.width, height: Styles.Constant.music_type_list_view_height)
                if let vc = toVC as? MusicTypeVC {
                    vc.collectionView.alpha = 1
                }
                if let vc = fromVC as? MusicTypeListVC {
                    vc.closeBtn.alpha = 0
                    vc.tableView.alpha = 0
                }
                
            }
        }) { (finished) in
        
            transitionContext.completeTransition(finished)
        }
        
    }
    
    

}
