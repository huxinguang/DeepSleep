//
//  ThinTrackSlider.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/31.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class ThinTrackSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: (bounds.size.height - Styles.Constant.player_slider_height)/2, width: bounds.size.width, height: Styles.Constant.player_slider_height)
    }
    
    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let x = -Styles.Constant.player_slider_thumbimage_size.width/2 + CGFloat(value) * rect.size.width
        return CGRect(x: x , y: bounds.size.height/2 - Styles.Constant.player_slider_thumbimage_size.height/2, width: Styles.Constant.player_slider_thumbimage_size.width, height: Styles.Constant.player_slider_thumbimage_size.height)
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
