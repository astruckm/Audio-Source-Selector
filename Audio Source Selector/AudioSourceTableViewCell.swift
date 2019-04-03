//
//  AudioSourceTableViewCell.swift
//  Audio Source Selector
//
//  Created by Andrew Struck-Marcell on 10/30/18.
//  MIT License.
//

import UIKit

class AudioSourceTableViewCell: UITableViewCell {
    @IBOutlet weak var audioSourceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
