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
    var category: AudioCategory!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playItemDidChange), name: NSNotification.Name.App.PlayItemDidChange, object: nil)
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

extension MusicTypeListVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category.musics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        cell.imageView?.image = UIImage(named: "music")
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "PingFangSC-Regular", size: 15)
        cell.textLabel?.text = category.musics[indexPath.row].name
        if AVPlayerManager.share.playingItem == category.musics[indexPath.row] && AVPlayerManager.share.player.rate > 0 {
            cell.accessoryView = UIImageView(image: UIImage(named: "cell_pause"))
        }else{
            cell.accessoryView = UIImageView(image: UIImage(named: "cell_play"))
        }
        return cell
    }
       
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if AVPlayerManager.share.playingItem == category.musics[indexPath.row] {
            if AVPlayerManager.share.player.rate > 0 {
                AVPlayerManager.share.pause()
            }else{
                AVPlayerManager.share.play()
            }
            tableView.reloadData()
        }else{
            AVPlayerManager.share.currentCategory = category
            AVPlayerManager.share.play(audioItem: category.musics[indexPath.row])
        }
        
    }
    
    
    
}
