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

    var currentOutputs: [AVAudioSessionPortDescription]? {
        return audioSession.currentRoute.outputs
    }

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
        didSet {
            previousInput = oldValue
            output.text += "\ncurrentInput is: \(String(describing: currentInput)), previousInput is: \(String(describing: previousInput))\n"
        }
    }
    var currentOutput: AudioSource? {
        didSet {
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
        
        let initialInput = audioSession.currentRoute.inputs.first
        currentInput = AudioSource(portInfo: PortInfo(port: initialInput!), dataSource: initialInput?.dataSources?.first)
        let initialOutput = audioSession.currentRoute.outputs.first
        currentOutput = AudioSource(portInfo: PortInfo(port: initialOutput!), dataSource: initialOutput?.dataSources?.first)
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
        case .newDeviceAvailable:
            let newInputPort = portThatChanged(among: audioSession.currentRoute.inputs, fromPrevious: audioInputPorts, wasPluggedIn: true)
            let newOutputPort = portThatChanged(among: audioSession.currentRoute.outputs, fromPrevious: audioOutputPorts, wasPluggedIn: true)
            //TODO: handle cases where new port is nil
            updateAudioSessionInfo(withNewInput: newInputPort, newOutput: newOutputPort)
        case .oldDeviceUnavailable:
            let newInput = portThatChanged(among: audioSession.currentRoute.inputs, fromPrevious: audioInputPorts, wasPluggedIn: false)
            let newOutput = portThatChanged(among: audioSession.currentRoute.outputs, fromPrevious: audioOutputPorts, wasPluggedIn: false)
            updateAudioSessionInfo(withNewInput: newInput, newOutput: newOutput)
        case .routeConfigurationChange:
            output.text += "\nRoute change reason is: route configuration change"
        //TODO: Handle other possible reasons?
        default:
        print("unknown reason")
        }
    }
    
    
    private func portThatChanged(among newPorts: [AVAudioSessionPortDescription], fromPrevious oldPorts: Set<AVAudioSession.Port>, wasPluggedIn: Bool) ->  AVAudioSessionPortDescription? {
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
    
    @IBAction func testTone(_ sender: UIButton) {
        guard let testToneURL = Bundle.main.url(forResource: "440Hz_44100Hz_16bit_05sec.mp3", withExtension: nil) else {
            return }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: testToneURL)
            if testToneShouldPlay { audioPlayer?.play() } else { audioPlayer?.stop() }
            
        } catch let error {
            output.text += "\n" + error.localizedDescription + "\n"
        }
        testToneShouldPlay.toggle()
    }
    
    
    //MARK: Methods
    func updateAudioSessionInfo(withNewInput newInput: AVAudioSessionPortDescription?, newOutput: AVAudioSessionPortDescription?) {
        inputAudioSources = populateAudioSources(with: audioSession.availableInputs ?? audioSession.currentRoute.inputs)
        outputAudioSources = populateAudioSources(with: audioSession.currentRoute.outputs)
        
        if let newInput = newInput {
            output.text += ("\nnewInput's data sources are: \(String(describing: newInput.dataSources))\n")
            let newInputSources = convert(portDescription: newInput)
            output.text += "\nNew input source is: \(newInputSources)\n"
            newInputSources.forEach({addInputAudioSource($0)})
            currentInput = newInputSources.first
        }
        if let newOutput = newOutput {
            let newOutputSources = convert(portDescription: newOutput)
            newOutputSources.forEach({addOutputAudioSource($0)})
            currentOutput = newOutputSources.first
        }
        
        audioSourcesTableView.reloadData()
    }
    
    //helpers
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
    
    //use this to add source that changed (from notification) to data source
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






