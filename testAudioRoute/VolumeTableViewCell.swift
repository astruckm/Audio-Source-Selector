//
//  VolumeTableViewCell.swift
//  testAudioRoute
//
//  Created by ASM on 11/9/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import UIKit
import MediaPlayer

class VolumeTableViewCell: UITableViewCell {
    @IBOutlet weak var wrapperView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let volumeSlider = MPVolumeView(frame: wrapperView.bounds)
        wrapperView.addSubview(volumeSlider)
        
//        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
//        volumeSlider.centerXAnchor.constraint(equalTo: wrapperView.centerXAnchor)
//        volumeSlider.centerYAnchor.constraint(equalTo: wrapperView.centerYAnchor)
//        volumeSlider.widthAnchor.constraint(equalToConstant: wrapperView.bounds.width)
//        volumeSlider.heightAnchor.constraint(equalToConstant: wrapperView.bounds.height)
//        volumeSlider.isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
