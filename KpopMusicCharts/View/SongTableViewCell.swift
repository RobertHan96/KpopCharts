//
//  SongTableViewCell.swift
//  KpopMusicCharts
//
//  Created by HanaHan on 2021/01/13.
//

import UIKit

class SongTableViewCell: UITableViewCell {
    @IBOutlet weak var albumartImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
