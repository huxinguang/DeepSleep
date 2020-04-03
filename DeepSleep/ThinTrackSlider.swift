//
//  ThinTrackSlider.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/31.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class ThinTrackSlider: UISlider {
    
    fileprivate var indicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView = UIActivityIndicatorView(style: .white)
        indicatorView.frame.size = CGSize(width: Styles.Constant.player_slider_thumbimage_size.width + 6*2, height: Styles.Constant.player_slider_thumbimage_size.height + 6*2)
        indicatorView.isUserInteractionEnabled = false
        addSubview(indicatorView)
        indicatorView.startAnimating()
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: (bounds.size.height - Styles.Constant.player_slider_height)/2, width: bounds.size.width, height: Styles.Constant.player_slider_height)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let x = -Styles.Constant.player_slider_thumbimage_size.width/2 + CGFloat(value) * rect.size.width
        let y = bounds.size.height/2 - Styles.Constant.player_slider_thumbimage_size.height/2
        if let indicatorView = indicatorView {
            indicatorView.frame.origin = CGPoint(x: x-6, y: y-6)
        }
        return CGRect(x: x , y: y, width: Styles.Constant.player_slider_thumbimage_size.width, height: Styles.Constant.player_slider_thumbimage_size.height)
    }
    
    func showIndicator() {
        indicatorView.startAnimating()
    }
    
    func hideIndicator() {
        indicatorView.stopAnimating()
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
