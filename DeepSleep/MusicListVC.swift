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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setCorner(10, [.topLeft, .topRight])
        
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
