//
//  ViewController.swift
//  testAudioRoute
//
//  Created by ASM on 10/29/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import UIKit
import AVFoundation


//Use AVAudioSessionPort type only
//Use currentInput to determine selected cell
class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var audioSourcesTableView: UITableView!
    
    
    //MARK: Properties
    let audioSession = AVAudioSession.sharedInstance()
    let audioPlayer = AVAudioPlayer()

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
        audioSourcesTableView.tableFooterView = UIView()
        
        output.text += audioSession.currentRoute.description
        currentInput = audioSession.currentRoute.inputs.map({$0.portType}).first
        currentOutput = audioSession.currentRoute.outputs.map({$0.portType}).first
        previousInput = nil
        previousOutput = nil
        for input in audioSession.currentRoute.inputs {
//            let isInitialSource = input.portType == currentInput
            audioInputSources.append(input.portType)
        }
        for output in audioSession.currentRoute.outputs {
//            let isInitialSource = output.portType == currentOutput
            audioOutputSources.append(output.portType)
        }
        
        NotificationCenter.default.post(name: AVAudioSession.routeChangeNotification, object: nil)
        setupNotifications()
        
        updateAudioSessionInfo()
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
            output.text += "\nRoute change reason is: device plugged in"
            updateAudioSessionInfo(withNewInput: newInput, newOutput: newOutput)
        case .oldDeviceUnavailable:
            let newInput = inputPortThatChanged(among: audioSession.currentRoute.inputs, wasPluggedIn: false)
            let newOutput = outputPortThatChanged(among: audioSession.currentRoute.outputs, wasPluggedIn: false)
            output.text += "\nRoute change reason is: device unplugged"
            updateAudioSessionInfo(withNewInput: newInput, newOutput: newOutput)
        case .routeConfigurationChange:
            output.text += "\nRoute change reason is: route configuration change"
        //TODO: handle other possible reasons
        default: ()
            output.text += "unknown reason"
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
                currentOutput = wasPluggedIn ? portDescription.portType : previousOutput
            }
        }
        return nil
    }

}

