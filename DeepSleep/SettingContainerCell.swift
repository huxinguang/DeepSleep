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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell", for: indexPath)
        cell.textLabel?.text = "\(indexPath.row)"
        cell.textLabel?.textColor = .white
        cell.accessoryView = UIImageView(image: UIImage(named: "arrow"))
        return cell
    }
    
    
}
