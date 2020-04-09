//
//  MusicTypeVC.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/26.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class MusicTypeVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var closeBtn: UIButton!
    var dimView: UIControl!
    var categories: [AudioCategory]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onCloseBtn(_:)), name: NSNotification.Name.App.DismissMusicTypeVC, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setCorner(10, [.bottomLeft, .bottomRight])
    }
    
    @IBAction func onCloseBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    deinit {
        print("MusicTypeVC denit")
        NotificationCenter.default.removeObserver(self)
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

extension MusicTypeVC: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MusicTypeCell", for: indexPath) as! MusicTypeCell
        let layout = collectionView.collectionViewLayout as! MusicTypeLayout
        cell.iconView.layer.cornerRadius = layout.itemSize.width/2
        cell.iconView.kf.setImage(with: URL(string: categories[indexPath.item].image_url))
        cell.startPlayingAnimation()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MusicTypeListVC") as! MusicTypeListVC
        vc.data = categories[indexPath.item].musics
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = TestObjectTwo.share
        present(vc, animated: true, completion: nil)
    }
    
    
}
