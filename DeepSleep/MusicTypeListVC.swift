//
//  MusicTypeListVC.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/27.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class MusicTypeListVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.setCorner(10, [.bottomLeft, .bottomRight])
    }

    @IBAction func onCloseBtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func closeAll() {
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name.App.DismissMusicTypeVC, object: nil)
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

extension MusicTypeListVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        cell.imageView?.image = UIImage(named: "music")
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "PingFangSC-Regular", size: 15)
        cell.textLabel?.text = "第\(indexPath.row)首歌曲"
        cell.accessoryView = UIImageView(image: UIImage(named: "cell_play"))
        return cell
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
}
