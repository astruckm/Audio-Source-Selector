//
//  ViewController.swift
//  Audio Source Selector
//
//  Created by Andrew Struck-Marcell on 10/30/18.
//  MIT License.
//

import UIKit
import AVFoundation
import MediaPlayer

//TODO: The three default device inputs (3 on the iPhone) 

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var audioSourcesTableView: UITableView!
    @IBOutlet weak var testToneButton: UIButton!
    
    //MARK: Properties
    let audioSession = AVAudioSession.sharedInstance()
    var audioPlayer: AVAudioPlayer?
    var testToneShouldPlay = true

    //Custom data sources
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
            output.text += "\ncurrentInput is: \(String(describing: currentInput)), previousInput is: \(String(describing: previousInput))\n"
        }
    }
    var currentOutput: AudioSource? {
        willSet {
            if let newAudioSource = newValue {
                setOutputAudioSource(newAudioSource)
            }
        } didSet {
            previousOutput = oldValue
            output.text += "\ncurrentOutput is: \(String(describing: currentOutput)), previousOutput is: \(String(describing: previousOutput))\n"
        }
    }
    var previousInput: AudioSource?
    var previousOutput: AudioSource?
    
    
    //MARK: View Controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP, .mixWithOthers])
            try audioSession.setActive(true)
        } catch let error {
            print(error.localizedDescription)
        }
        
        //TODO: this shouldn't be the first one if there is a saved audio source (from defaults)
        if let initialInput = audioSession.currentRoute.inputs.first {
            currentInput = AudioSource(portInfo: PortInfo(port: initialInput), dataSource: initialInput.dataSources?.first)
        }
        if let initialOutput = audioSession.currentRoute.outputs.first {
            currentOutput = AudioSource(portInfo: PortInfo(port: initialOutput), dataSource: initialOutput.dataSources?.first)
        }
        previousInput = nil
        previousOutput = nil
        
        inputAudioSources = populateAudioSources(with: audioSession.availableInputs ?? audioSession.currentRoute.inputs)
        outputAudioSources = populateAudioSources(with: audioSession.currentRoute.outputs)
        
        NotificationCenter.default.post(name: AVAudioSession.routeChangeNotification, object: nil)
        setupNotifications()
    }
    
    private func populateAudioSources(with descriptions: [AVAudioSessionPortDescription]) -> [AudioSource] {
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
    
    
    private func setUpViews() {
        audioSourcesTableView.tableFooterView = UIView()
    }
    
    private func setUpInitialAudioSources() {
        
        //Check if it is iPhone/iPad, then add default input sources
    }
    
    @IBAction func testTone(_ sender: UIButton) {
        guard let testToneURL = Bundle.main.url(forResource: "440Hz_44100Hz_16bit_05sec.mp3", withExtension: nil) else { return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: testToneURL)
            playOrStopTestTone(withAudioPlayer: audioPlayer)
        } catch let error {
            output.text += "\n" + error.localizedDescription + "\n"
        }
        testToneShouldPlay.toggle()
    }
    
    private func playOrStopTestTone(withAudioPlayer player: AVAudioPlayer?) {
        if testToneShouldPlay {
            player?.play()
        } else {
            player?.stop()
        }
    }
    
    //MARK: Audio Session Notifications
    func setupNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(handleRouteChange),name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable, .oldDeviceUnavailable:
            let newInputPort = portThatChanged(among: audioSession.currentRoute.inputs)
            let newOutputPort = portThatChanged(among: audioSession.currentRoute.outputs)
            updateAudioSessionInfo(withNewInput: newInputPort, newOutput: newOutputPort)
        case .routeConfigurationChange:
            output.text += "\nRoute configuration changed"
        //TODO: Handle other possible reasons?
        default:
            print("unknown reason")
        }
    }
    
    private func portThatChanged(among newPorts: [AVAudioSessionPortDescription]) ->  AVAudioSessionPortDescription? {
        for portDescription in newPorts {
            switch (audioInputPorts.contains(portDescription.portType), audioOutputPorts.contains(portDescription.portType)) {
            case (true, true):
                output.text += "Error! Input and output have the same port type!"
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
            output.text += ("\nnewInput's data source(s): \(String(describing: newInput.dataSources))\n")
            let newInputSources = convert(portDescription: newInput)
            output.text += "\nNew input source is: \(newInputSources)\n"
            newInputSources.forEach { addInputAudioSource($0) }
            currentInput = newInputSources.first
        } else {
            currentInput = previousInput
            output.text += "\naudioSession preferred input is: \(String(describing: audioSession.preferredInput))\n"
            //TODO: handle if previousInput is nil. Possibly check if audioSession.preferredInput (and then preferredDataSource) is available. (worst case, just do inputAudioSources.first)
        }
        if let newOutput = newOutput {
            let newOutputSources = convert(portDescription: newOutput)
            newOutputSources.forEach { addOutputAudioSource($0) }
            currentOutput = newOutputSources.first
        } else {
            currentOutput = previousOutput
        }
        
        audioSourcesTableView.reloadData()
    }
    
    //helpers
    
    //set system's preferred source
    private func setInputAudioSource(_ audioSource: AudioSource) {
        do {
            try audioSession.setPreferredInput(audioSource.portInfo.description)
            if let dataSource = audioSource.dataSource {
                try audioSession.preferredInput?.setPreferredDataSource(dataSource)
            }
        } catch let error {
            output.text += "\nUnable to set input source: \(error.localizedDescription)\n"
        }
    }
    private func setOutputAudioSource(_ audioSource: AudioSource) {
        do {
            if let dataSource = audioSource.dataSource {
                try audioSession.setOutputDataSource(dataSource)
            }
        } catch let error {
            output.text += "\nUnable to set output source: \(error.localizedDescription)\n"
        }
    }

    
    //Adds non-duplicate input source
    private func addInputAudioSource(_ audioSource: AudioSource, possibleDataSource: AVAudioSessionDataSourceDescription? = nil) {
        output.text += "\nAdding audio source: \(audioSource)\n"
        if !inputAudioSources.contains(audioSource) {
            output.text += "Adding input audio source"
            inputAudioSources.append(audioSource)
        }
    }

    //Adds non-duplicate output source
    private func addOutputAudioSource(_ audioSource: AudioSource, possibleDataSource: AVAudioSessionDataSourceDescription? = nil) {
        if !outputAudioSources.contains(audioSource) {
            outputAudioSources.append(audioSource)
        }
    }
    
    //use this to add source that changed (from notification) to array of AudioSources
    private func convert(portDescription: AVAudioSessionPortDescription) -> [AudioSource] {
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
        output.text += "\nconvertedAudioSources: \(convertedAudioSources)\n"
        return convertedAudioSources
    }
        

}






