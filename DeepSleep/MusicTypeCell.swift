//
//  MusicTypeCell.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/27.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class MusicTypeCell: UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var playingView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func startPlayingAnimation() {
        playingView.isHidden = false
        let imageNames = ["playing1","playing2","playing3","playing4"]
        playingView.animationImages = imageNames.map{UIImage(named: $0)!}
        playingView.animationDuration = 1.2
        playingView.startAnimating()
    }
    
    func stopPlayingAnimation() {
        playingView.isHidden = false
        if playingView.isAnimating {
            playingView.stopAnimating()
        }
    }
    
    
    
}
