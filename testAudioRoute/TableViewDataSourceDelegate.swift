//
//  TableViewDataSourceDelegate.swift
//  testAudioRoute
//
//  Created by ASM on 10/30/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import UIKit

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "METRODRONE"
        case 1:
            return "AUDIO INPUT SOURCE"
        case 2:
            return "AUDIO OUTPUT"
        default:
            print("Error populating section titles")
            return ""
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return audioInputSources.count
        case 2:
            return audioOutputSources.count
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: this needs to match what is already in Modacity code
        let metrodroneCell = tableView.dequeueReusableCell(withIdentifier: "metrodrone", for: indexPath)
        guard let audioSourceCell = tableView.dequeueReusableCell(withIdentifier: "audioSource", for: indexPath) as? AudioSourceTableViewCell else { return UITableViewCell() }
        
        switch indexPath.section {
        case 0:
            return metrodroneCell
        case 1:
            audioSourceCell.audioSourceLabel.text = audioInputSources[indexPath.row].name
            audioSourceCell.audioSourceLabel.isHighlighted = audioInputSources[indexPath.row].isInUse
            print("is in use? \(audioInputSources[indexPath.row].isInUse)")
            return audioSourceCell
        case 2:
            audioSourceCell.audioSourceLabel.text = audioOutputSources[indexPath.row].name
            audioSourceCell.audioSourceLabel.isHighlighted = audioOutputSources[indexPath.row].isInUse
            print("is in use? \(audioInputSources[indexPath.row].isInUse)")
            return audioSourceCell
        default:
            print("unable to populate cells")
            return UITableViewCell()
        }
        
    }
    
}
