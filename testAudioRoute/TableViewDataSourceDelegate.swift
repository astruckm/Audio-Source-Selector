//
//  TableViewDataSourceDelegate.swift
//  testAudioRoute
//
//  Created by ASM on 10/30/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import UIKit

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewCell()
        headerView.backgroundColor = .lightGray
        
        
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return audioInputSources.count
        case 1:
            return audioOutputSources.count
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "audioSource", for: indexPath) as! AudioSourceTableViewCell
        
        switch indexPath.section {
        case 0:
            cell.audioSourceLabel.text = audioInputSources[indexPath.row].name
            cell.audioSourceLabel.isHighlighted = audioInputSources[indexPath.row].isInUse ? true : false
        case 1:
            cell.audioSourceLabel.text = audioOutputSources[indexPath.row].name
            cell.audioSourceLabel.isHighlighted = audioOutputSources[indexPath.row].isInUse ? true : false

        default:
            print("unable to populate cells")
        }
        
        
        return cell
    }
    
}
