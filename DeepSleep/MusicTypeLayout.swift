//
//  MusicTypeLayout.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/27.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class MusicTypeLayout: UICollectionViewFlowLayout {
    let column: CGFloat = 5.0
    let cellSpacing: CGFloat = 10.0
    let lineSpacing: CGFloat = 10.0
    let inset = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 10.0)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.scrollDirection = .vertical
        let exactW = floor((UIScreen.main.bounds.size.width - inset.left - inset.right - (column-1)*cellSpacing)/column)
        let exactH = exactW
        self.itemSize = CGSize(width: exactW, height: exactH)
        self.minimumLineSpacing = lineSpacing
        self.minimumInteritemSpacing = cellSpacing
        self.sectionInset = inset
    }
}
