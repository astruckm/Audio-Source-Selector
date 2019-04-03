//
//  TableViewDataSourceDelegate.swift
//  Audio Source Selector
//
//  Created by Andrew Struck-Marcell on 10/30/18.
//  MIT License.
//

import UIKit

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "AUDIO INPUT SOURCE"
        case 1:
            return "AUDIO OUTPUT"
//        case 2:
//            return "VOLUME"
        default:
            return ""
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if !inputAudioSources.isEmpty {
                return inputAudioSources.count
            }
            fallthrough
        case 1:
            if !outputAudioSources.isEmpty {
                return outputAudioSources.count
            }
            fallthrough
//        case 2:
//            return 1
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard audioSession.availableInputs != nil else { return UITableViewCell() }
            guard indexPath.row <= (inputAudioSources.count - 1) else {
                output.text += "\ncellForRowAt not in sync with input audio sources"
                return UITableViewCell()
            }
            
            let audioSourceCell = tableView.dequeueReusableCell(withIdentifier: "audioSource", for: indexPath) as! AudioSourceTableViewCell
            let audioSource = inputAudioSources[indexPath.row]
            if let audioSourceDataSource = audioSource.dataSource {
                //If cell is a data source, label it by port name AND data source name
                audioSourceCell.audioSourceLabel.text = audioSource.portInfo.description.portName + " " + audioSourceDataSource.dataSourceName
            } else {
                audioSourceCell.audioSourceLabel.text = audioSource.portInfo.description.portName
            }
            if let currentInput = currentInput {
                audioSourceCell.accessoryType = currentInput == audioSource ? .checkmark : .none
            }
            
            output.text += "\nThere are \(inputAudioSources.count) current inputs\n"
            return audioSourceCell
        case 1:
            guard indexPath.row <= (outputAudioSources.count - 1) else {
                output.text += "\ncellForRowAt not in sync with output audio sources"
                return UITableViewCell()
            }

            let audioSourceCell = tableView.dequeueReusableCell(withIdentifier: "audioSource", for: indexPath) as! AudioSourceTableViewCell
            let audioSource = outputAudioSources[indexPath.row]
            if let audioSourceDataSource = audioSource.dataSource {
                //If cell is a data source, label it by port name AND data source name
                audioSourceCell.audioSourceLabel.text = audioSource.portInfo.description.portName + " " + audioSourceDataSource.dataSourceName
            } else {
                audioSourceCell.audioSourceLabel.text = audioSource.portInfo.description.portName
            }
            if let currentOutput = currentOutput {
                audioSourceCell.accessoryType = currentOutput == audioSource ? .checkmark : .none
            }

            output.text += "\nThere are \(outputAudioSources.count) current outputs\n"
            return audioSourceCell
//        case 2:
//            let volumeCell = tableView.dequeueReusableCell(withIdentifier: "volumeBar", for: indexPath)
//            return volumeCell
        default:
            print("unable to populate cells")
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && !inputAudioSources.isEmpty {
            guard audioSession.availableInputs != nil else { return }
            guard indexPath.row <= (inputAudioSources.count - 1) else { return }
            let selectedAudioSource = inputAudioSources[indexPath.row]
            setAudioSource(selectedAudioSource)
        } else if indexPath.section == 1 && !outputAudioSources.isEmpty {
            guard indexPath.row <= (outputAudioSources.count - 1) else { return }
            let selectedAudioSource = outputAudioSources[indexPath.row]
            setAudioSource(selectedAudioSource)
        }
        tableView.reloadData()
    }
    
    private func setAudioSource(_ audioSource: AudioSource) {
        do {
            try audioSession.setPreferredInput(audioSource.portInfo.description)
            currentInput = audioSource
            if let dataSource = audioSource.dataSource {
                try audioSession.preferredInput?.setPreferredDataSource(dataSource)
            }
        } catch let error {
            output.text += "\n\(error.localizedDescription)\n"
        }
    }
    
}
