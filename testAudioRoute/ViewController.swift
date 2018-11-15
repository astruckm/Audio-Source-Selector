//
//  ViewController.swift
//  testAudioRoute
//
//  Created by ASM on 10/29/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

//Use AVAudioSessionPort type only
//Use currentInput to determine selected cell
class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var audioSourcesTableView: UITableView!
    @IBOutlet weak var testToneButton: UIButton!
    
    
    //MARK: Properties
    let audioSession = AVAudioSession.sharedInstance()
    var audioPlayer: AVAudioPlayer?
    var testToneShouldPlay = true

    var availableInputs: [AVAudioSessionPortDescription]? {
        return audioSession.availableInputs
    }
    
    var currentOutputs: [AVAudioSessionPortDescription]? {
        return audioSession.currentRoute.outputs
    }

    //Custom data sources
    var audioInputSources = [AVAudioSession.Port]()
    var audioOutputSources = [AVAudioSession.Port]()
    var currentInput: AVAudioSession.Port? {
        didSet {
            previousInput = oldValue
            output.text += "\ncurrentInput is: \(String(describing: currentInput)), previousInput is: \(String(describing: previousInput))\n"
        }
    }
    var currentOutput: AVAudioSession.Port? {
        didSet {
            previousOutput = oldValue
            output.text += "\ncurrentOutput is: \(String(describing: currentOutput)), previousOutput is: \(String(describing: previousOutput))\n"
        }

    }
    var previousInput: AVAudioSession.Port?
    var previousOutput: AVAudioSession.Port?
    
    
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
        
        currentInput = audioSession.currentRoute.inputs.map({$0.portType}).first
        currentOutput = audioSession.currentRoute.outputs.map({$0.portType}).first
        previousInput = nil
        previousOutput = nil
        for input in audioSession.currentRoute.inputs {
            audioInputSources.append(input.portType)
        }
        for output in audioSession.currentRoute.outputs {
            audioOutputSources.append(output.portType)
        }
        
        NotificationCenter.default.post(name: AVAudioSession.routeChangeNotification, object: nil)
        setupNotifications()
        
        updateAudioSessionInfo()
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
            let newInput = inputPortThatChanged(among: audioSession.currentRoute.inputs, wasPluggedIn: true)
            let newOutput = outputPortThatChanged(among: audioSession.currentRoute.outputs, wasPluggedIn: true)
            //TODO: if new device is input, append to input, if output append to output
            updateAudioSessionInfo(withNewInput: newInput, newOutput: newOutput)
            output.text += "\n\n" + audioSession.currentRoute.description + "\n\n"
        case .oldDeviceUnavailable:
            let newInput = inputPortThatChanged(among: audioSession.currentRoute.inputs, wasPluggedIn: false)
            let newOutput = outputPortThatChanged(among: audioSession.currentRoute.outputs, wasPluggedIn: false)
            updateAudioSessionInfo(withNewInput: newInput, newOutput: newOutput)
        case .routeConfigurationChange:
            output.text += "\nRoute change reason is: route configuration change"
        //TODO: handle other possible reasons
        default:
        print("unknown reason")
        }
        
        audioSourcesTableView.reloadData()
        //TODO: some func that calls audioSession.setPreferredInput if input needs to change, and for some reason, it won't change automatically (is that necessary & possible for output as well?)
    }
    
    private func inputPortThatChanged(among portDescriptions: [AVAudioSessionPortDescription], wasPluggedIn: Bool) ->  AVAudioSession.Port? {
        for portDescription in portDescriptions {
            if !audioInputSources.contains(portDescription.portType) {
                //Is a totally new input source
                currentInput = portDescription.portType
                return portDescription.portType
            } else {
                //Set currentInput to new device if plugged in, previous one if unplugged
                currentInput = wasPluggedIn ? portDescription.portType : previousInput
            }
        }
        return nil
    }
    
    private func outputPortThatChanged(among portDescriptions: [AVAudioSessionPortDescription], wasPluggedIn: Bool) ->  AVAudioSession.Port? {
        for portDescription in portDescriptions {
            if !audioOutputSources.contains(portDescription.portType) {
                //Is a totally new output source
                currentOutput = portDescription.portType
                return portDescription.portType
            } else {
                //Set currentInput to new device if plugged in, previous one if unplugged
                currentOutput = wasPluggedIn ? portDescription.portType : previousOutput
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
    func updateAudioSessionInfo(withNewInput newInput: AVAudioSession.Port? = nil, newOutput: AVAudioSession.Port? = nil) {
        if let newInput = newInput {
            let isCurrentInput = newInput == currentInput
            addInputAudioSource(withPort: newInput, isInUse: isCurrentInput)
        }
        if let newOutput = newOutput {
            let isCurrentOutput = newOutput == currentOutput
            addOutputAudioSource(withPort: newOutput, isInUse: isCurrentOutput)
        }
        
    }
    
    //helpers
    //Adds non-duplicate input source
    private func addInputAudioSource(withPort port: AVAudioSession.Port, isInUse: Bool = false) {
//        let audioSource = AudioSource(port: port, isInUse: isInUse)
        let isAlreadyAdded = audioInputSources.contains(port)
        if isAlreadyAdded == false {
            audioInputSources.append(port)
        }
    }

    //Adds non-duplicate output source
    private func addOutputAudioSource(withPort port: AVAudioSession.Port, isInUse: Bool = false) {
//        let audioSource = AudioSource(port: port, isInUse: isInUse)
        let isAlreadyAdded = audioOutputSources.contains(port)
        if isAlreadyAdded == false {
            audioOutputSources.append(port)
        }
    }
    
    private func extractAudioInputDataSourceDescription(_ dataSource: [AVAudioSessionDataSourceDescription]?) -> [String]? {
        guard let descriptionFields = dataSource else { return nil }
        let dataSourceNames = descriptionFields.map { $0.dataSourceName }
        return dataSourceNames
    }

    
    

}

