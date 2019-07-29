//
//  ViewModel.swift
//  Audio Source Selector
//
//  Created by ASM on 7/28/19.
//  Copyright © 2019 ASM. All rights reserved.
//

import Foundation
import AVFoundation

class ViewModel {
    
    //MARK: Properties
    let audioSession = AVAudioSession.sharedInstance()
    var inputAudioSources = [AudioSource]()
    var audioInputPorts: Set<AVAudioSession.Port> {
        let inputPorts = inputAudioSources.map{$0.portInfo.description.portType}
        return Set(inputPorts)
    }
    var outputAudioSources = [AudioSource]()
    var audioOutputPorts: Set<AVAudioSession.Port> {
        let outputPorts =  outputAudioSources.map({$0.portInfo.description.portType})
        return Set(outputPorts)
    }
    
    //In-use audio sources
    var currentInput: AudioSource? {
        willSet {
            if let newAudioSource = newValue {
                setInputAudioSource(newAudioSource)
            }
        } didSet {
            previousInput = oldValue
            print("\ncurrentInput is: \(String(describing: currentInput)), previousInput is: \(String(describing: previousInput))\n")
        }
    }
    var currentOutput: AudioSource? {
        willSet {
            if let newAudioSource = newValue {
                setOutputAudioSource(newAudioSource)
            }
        } didSet {
            previousOutput = oldValue
            print("\ncurrentOutput is: \(String(describing: currentOutput)), previousOutput is: \(String(describing: previousOutput))\n")
        }
    }
    var previousInput: AudioSource?
    var previousOutput: AudioSource?
    
    //MARK: Methods
    func populateAudioSources(with descriptions: [AVAudioSessionPortDescription]) -> [AudioSource] {
        var audioSources = [AudioSource]()
        for description in descriptions {
            let portInfo = PortInfo(port: description)
            if let dataSources = description.dataSources, !dataSources.isEmpty {
                for dataSource in dataSources {
                    audioSources.append(AudioSource(portInfo: portInfo, dataSource: dataSource))
                }
            } else {
                audioSources.append(AudioSource(portInfo: portInfo, dataSource: description.preferredDataSource))
            }
        }
        return audioSources
    }
    
    func portThatChanged(among newPorts: [AVAudioSessionPortDescription]) ->  AVAudioSessionPortDescription? {
        for portDescription in newPorts {
            switch (audioInputPorts.contains(portDescription.portType), audioOutputPorts.contains(portDescription.portType)) {
            case (true, true):
                print("Error! Input and output have the same port type!")
            case (true, false): continue
            case (false, true): continue
            case (false, false): return portDescription
            }
        }
        return nil
    }
    
    
    //MARK: Methods
    func updateAudioSessionInfo(withNewInput newInput: AVAudioSessionPortDescription?, newOutput: AVAudioSessionPortDescription?) {
        inputAudioSources = populateAudioSources(with: audioSession.availableInputs ?? audioSession.currentRoute.inputs)
        outputAudioSources = populateAudioSources(with: audioSession.currentRoute.outputs)

        if let newInput = newInput {
            print("\nnewInput's data source(s): \(String(describing: newInput.dataSources))\n")
            let newInputSources = convert(portDescription: newInput)
            print("\nNew input source is: \(newInputSources)\n")
            newInputSources.forEach { addInputAudioSource($0) }
            currentInput = newInputSources.first
        } else {
            assignCurrentInputWhenUnplugged()
            print("\naudioSession preferred input is: \(String(describing: audioSession.preferredInput))\n")
            //TODO: if previousInput is nil, try to load the preferred input from UserDefaults. Otherwise, need to cache previous input of the previous input
        }
        if let newOutput = newOutput {
            let newOutputSources = convert(portDescription: newOutput)
            newOutputSources.forEach { addOutputAudioSource($0) }
            currentOutput = newOutputSources.first
        } else {
            assignCurrentOutputWhenUnplugged()
        }

//        audioSourcesTableView.reloadData()
    }
    
    //set system's preferred source
    func setInputAudioSource(_ audioSource: AudioSource) {
        do {
            try audioSession.setPreferredInput(audioSource.portInfo.description)
            if let dataSource = audioSource.dataSource {
                try audioSession.preferredInput?.setPreferredDataSource(dataSource)
            }
        } catch let error {
            print("\nUnable to set input source: \(error.localizedDescription)\n")
        }
    }
    func setOutputAudioSource(_ audioSource: AudioSource) {
        do {
            if let dataSource = audioSource.dataSource {
                try audioSession.setOutputDataSource(dataSource)
            }
        } catch let error {
            print("\nUnable to set output source: \(error.localizedDescription)\n")
        }
    }
    
    
    //Adds non-duplicate input source
    func addInputAudioSource(_ audioSource: AudioSource, possibleDataSource: AVAudioSessionDataSourceDescription? = nil) {
        print("\nAdding audio source: \(audioSource)\n")
        if !inputAudioSources.contains(audioSource) {
            print("Adding input audio source")
            inputAudioSources.append(audioSource)
        }
    }
    
    //Adds non-duplicate output source
    func addOutputAudioSource(_ audioSource: AudioSource, possibleDataSource: AVAudioSessionDataSourceDescription? = nil) {
        if !outputAudioSources.contains(audioSource) {
            outputAudioSources.append(audioSource)
        }
    }
    
    func assignCurrentInputWhenUnplugged() {
        if let _currentInput = currentInput {
            if !inputAudioSources.contains(_currentInput) {
                currentInput = previousInput
            }
        }
    }
    
    func assignCurrentOutputWhenUnplugged() {
        if let _currentInput = currentInput {
            if !inputAudioSources.contains(_currentInput) {
                currentOutput = previousOutput
            }
        }
    }
    
    //use this to add source that changed (from notification) to array of AudioSources
    func convert(portDescription: AVAudioSessionPortDescription) -> [AudioSource] {
        var convertedAudioSources = [AudioSource]()
        if let dataSources = portDescription.dataSources, !dataSources.isEmpty {
            for dataSource in dataSources {
                let audioSource = AudioSource(portInfo: PortInfo(port: portDescription), dataSource: dataSource)
                convertedAudioSources.append(audioSource)
            }
            return convertedAudioSources
        }
        
        let audioSource = AudioSource(portInfo: PortInfo(port: portDescription), dataSource: nil)
        convertedAudioSources.append(audioSource)
        print("\nconvertedAudioSources: \(convertedAudioSources)\n")
        return convertedAudioSources
    }
    


}
