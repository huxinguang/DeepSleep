//
//  SettingCell.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/25.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit

class SettingContainerCell: UITableViewCell {
    
    @IBOutlet weak var tableView: UITableView!
    
    var titles: [String]? {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension SettingContainerCell: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath) as! SettingCell
        cell.titleLabel.text = titles![indexPath.row]
        if indexPath.row == 2 {
            cell.accessoryView = nil
            cell.detailLabel.text = "1.0.0"
        }else{
            cell.accessoryView = UIImageView(image: UIImage(named: "arrow"))
            cell.detailLabel.text = ""
        }
        if indexPath.row == titles!.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.size.width, bottom: 0, right: 0)
        }else{
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }

        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath)
//        switch titles![indexPath.row] {
//        case "评分":
//            break
//        case "意见反馈":
////            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
////            let vc = storyboard.instantiateViewController(withIdentifier: "FeedbackVC")
//            
//            break
//        case "关于":
//            break
//        case "当前版本":
//            break
//        default:
//            break
//        }
//        
//    }
    
}
