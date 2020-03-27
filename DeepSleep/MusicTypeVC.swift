//
//  MusicTypeVC.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/26.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class MusicTypeVC: UIViewController {

    @IBOutlet weak var testBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setCorner(10, [.bottomLeft, .bottomRight])
    }
    
    @IBAction func onCloseBtn(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTestBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MusicTypeListVC")
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = TestObjectTwo.share
        present(vc, animated: true, completion: nil)
    }
    
    deinit {
        print("MusicTypeVC denit")
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
