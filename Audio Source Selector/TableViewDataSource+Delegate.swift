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
            if !viewModel.inputAudioSources.isEmpty {
                return viewModel.inputAudioSources.count
            }
            fallthrough
        case 1:
            if !viewModel.outputAudioSources.isEmpty {
                return viewModel.outputAudioSources.count
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
            guard indexPath.row <= (viewModel.inputAudioSources.count - 1) else {
                output.text += "\ncellForRowAt not in sync with input audio sources"
                return UITableViewCell()
            }
            let audioSourceCell = tableView.dequeueReusableCell(withIdentifier: "audioSource", for: indexPath) as! AudioSourceTableViewCell
            let audioSource = viewModel.inputAudioSources[indexPath.row]
            
            if let audioSourceDataSource = audioSource.dataSource {
                //If cell is a data source, label it by port name AND data source name
                audioSourceCell.audioSourceLabel.text = audioSource.portInfo.description.portName + " " + audioSourceDataSource.dataSourceName
            } else {
                audioSourceCell.audioSourceLabel.text = audioSource.portInfo.description.portName
            }
            if let currentInput = viewModel.currentInput {
                audioSourceCell.accessoryType = currentInput == audioSource ? .checkmark : .none
            }
            
            output.text += "\nThere are \(viewModel.inputAudioSources.count) current inputs\n"
            return audioSourceCell
        case 1:
            guard indexPath.row <= (viewModel.outputAudioSources.count - 1) else {
                output.text += "\ncellForRowAt not in sync with output audio sources"
                return UITableViewCell()
            }
            let audioSourceCell = tableView.dequeueReusableCell(withIdentifier: "audioSource", for: indexPath) as! AudioSourceTableViewCell
            let audioSource = viewModel.outputAudioSources[indexPath.row]
            
            if let audioSourceDataSource = audioSource.dataSource {
                //If cell is a data source, label it by port name AND data source name
                audioSourceCell.audioSourceLabel.text = audioSource.portInfo.description.portName + " " + audioSourceDataSource.dataSourceName
            } else {
                audioSourceCell.audioSourceLabel.text = audioSource.portInfo.description.portName
            }
            if let currentOutput = viewModel.currentOutput {
                audioSourceCell.accessoryType = currentOutput == audioSource ? .checkmark : .none
            }

            output.text += "\nThere are \(viewModel.outputAudioSources.count) current outputs\n"
            return audioSourceCell
//        case 2:
//            let volumeCell = tableView.dequeueReusableCell(withIdentifier: "volumeBar", for: indexPath)
//            return volumeCell
        default:
            print("unable to populate cells")
            return UITableViewCell()
        }
        
    }
    
    //TODO: add this helper func to cellForRowAt
    private func populateAudioSourceCell(_ audioSourceCell: AudioSourceTableViewCell, withAudioSource audioSource: AudioSource) -> AudioSourceTableViewCell {
        
        
        return audioSourceCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && !viewModel.inputAudioSources.isEmpty {
            guard audioSession.availableInputs != nil else { return }
            guard indexPath.row <= (viewModel.inputAudioSources.count - 1) else { return }
            let selectedAudioSource = viewModel.inputAudioSources[indexPath.row]
            viewModel.currentInput = selectedAudioSource
        } else if indexPath.section == 1 && !viewModel.outputAudioSources.isEmpty {
            guard indexPath.row <= (viewModel.outputAudioSources.count - 1) else { return }
            let selectedAudioSource = viewModel.outputAudioSources[indexPath.row]
            viewModel.currentOutput = selectedAudioSource
        }
        tableView.reloadData()
    }
    
    
    
}
