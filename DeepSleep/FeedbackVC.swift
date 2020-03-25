//
//  FeedbackVC.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/25.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class FeedbackVC: UIViewController {

    @IBOutlet weak var textView: KMPlaceholderTextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.tintColor = .white

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
