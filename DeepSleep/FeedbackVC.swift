//
//  FeedbackVC.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/25.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import RxSwift
import RxCocoa

class FeedbackVC: UIViewController {

    @IBOutlet weak var textView: KMPlaceholderTextView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.tintColor = .white
        submitBtn.setTitleColor(.white, for: .normal)
        submitBtn.setTitleColor(.darkGray, for: .disabled)
        textView.rx.text.orEmpty.map{ $0.count>0 }.bind(to: submitBtn.rx.isEnabled).disposed(by: disposeBag)
    }
    
    @IBAction func onSubmit(_ sender: UIButton) {
        sender.isEnabled = false
        sender.setTitle("", for: .normal)
        indicatorView.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
            self.indicatorView.stopAnimating()
            sender.setTitle("提交成功", for: .normal)
            sender.isEnabled = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
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
