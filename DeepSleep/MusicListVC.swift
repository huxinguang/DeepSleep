//
//  MusicListVC.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/24.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class MusicListVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    var data: [AudioItem]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setCorner(10, [.topLeft, .topRight])
        NotificationCenter.default.addObserver(self, selector: #selector(playItemDidChange), name: NSNotification.Name.App.PlayItemDidChange, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let lineLayer = CALayer()
        lineLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0.5)
        lineLayer.backgroundColor = UIColor.darkGray.cgColor
        closeButton.layer.addSublayer(lineLayer)
    }
    
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func playItemDidChange() {
        tableView.reloadData()
    }

    deinit {
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

extension MusicListVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        cell.imageView?.image = UIImage(named: "music")
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "PingFangSC-Regular", size: 15)
        cell.textLabel?.text = data[indexPath.row].name
        cell.accessoryView = UIImageView(image: UIImage(named: AVPlayerManager.share.playingItem == data[indexPath.row] ? "cell_pause" : "cell_play"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}
