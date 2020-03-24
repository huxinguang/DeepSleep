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
    
    @IBAction func onListBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MusicListVC")
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        //vc.transitioningDelegate = PresentationObject.share
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

extension MainVC: UIViewControllerTransitioningDelegate{
    
    /*
     You can provide separate animator objects for presenting and dismissing the view controller.
     此方法返回的CustomPresentationController实例就是一个animator object，如果presenting和dismissing使用的是不同的animator object， 可以在在协议方法
     
     animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
     
     中返回一个新的animator object
     
     */
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    
    
    
}
