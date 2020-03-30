//
//  MainVC.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/23.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class MainVC: BaseVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sunshine girl"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func onUnfoldBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MusicTypeVC")
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = TestObject.share
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func onListBtn(_ sender: UIButton) {
        /*
         To present a view controller using custom animations, do the following in an action method of your existing view controllers:

         1. Create the view controller that you want to present.
         2. Create your custom transitioning delegate object and assign it to the view controller’s transitioningDelegate property. The methods of your transitioning delegate should create and return your custom animator objects when asked.
         3. Call the presentViewController:animated:completion: method to present the view controller.
         */
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MusicListVC")
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc.presentationDelegate
        present(vc, animated: true, completion: nil)
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




