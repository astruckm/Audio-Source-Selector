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
        case 3:
            return "VOLUME"
        default:
            return ""
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if let availableInputs = availableInputs {
                return availableInputs.count
            } else {
                fallthrough
            }
        case 2:
            if let currentOutputs = currentOutputs {
                return currentOutputs.count
            } else {
                fallthrough
            }
        case 3:
            return 1
        default:
            return 3
        }
    }
    
    //TODO: Some dictionary with [AVAudioSession.Port: String] to populate cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: this needs to match what is already in Modacity code
                
        switch indexPath.section {
        case 0:
            let metrodroneCell = tableView.dequeueReusableCell(withIdentifier: "metrodrone", for: indexPath)
            return metrodroneCell
        case 1:
            let audioSourceCell = tableView.dequeueReusableCell(withIdentifier: "audioSource", for: indexPath) as! AudioSourceTableViewCell
            if let availableInputs = availableInputs {
                audioSourceCell.audioSourceLabel.text =  availableInputs[indexPath.row].portName
                audioSourceCell.accessoryType = currentInput == availableInputs[indexPath.row].portType ? .checkmark : .none
                output.text += "\ncurrent route inputs: \(audioSession.currentRoute.inputs)\n"
                
                if let dataSources = availableInputs[indexPath.row].dataSources {
                    for dataSource in dataSources {
                        output.text += availableInputs[indexPath.row].portName + dataSource.dataSourceName +  "\n"
                    }
                }
                
            }
            return audioSourceCell
        case 2:
            let audioSourceCell = tableView.dequeueReusableCell(withIdentifier: "audioSource", for: indexPath) as! AudioSourceTableViewCell
            if let currentOutputs = currentOutputs {
                audioSourceCell.audioSourceLabel.text = currentOutputs[indexPath.row].portName
                audioSourceCell.accessoryType = currentOutput == currentOutputs[indexPath.row].portType ? .checkmark : .none
            }
            return audioSourceCell
        case 3:
            let volumeCell = tableView.dequeueReusableCell(withIdentifier: "volumeBar", for: indexPath)
            return volumeCell
        default:
            print("unable to populate cells")
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if let availableInputs = availableInputs {
                do {
                    try audioSession.setPreferredInput(availableInputs[indexPath.row])
                    currentInput = availableInputs[indexPath.row].portType
                    tableView.reloadData()
                } catch let error {
                    output.text += "\n\(error.localizedDescription)\n"
                }
            }
        }
    }
    
}
