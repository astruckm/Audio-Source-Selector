//
//  ViewController.swift
//  testAudioRoute
//
//  Created by ASM on 10/29/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var audioSourcesTableView: UITableView!
    
    
    //MARK: Properties
    let audioSession = AVAudioSession.sharedInstance()
    let audioPlayer = AVAudioPlayer()

    var currentInput: AVAudioSessionPortDescription?
    var currentOutput: AVAudioSessionPortDescription?
    var audioInputSources = [AudioSource]()
    var audioOutputSources = [AudioSource]()
    
    
    
    //MARK: View Controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        audioSourcesTableView.tableFooterView = UIView()
        currentInput = audioSession.currentRoute.inputs.first
        currentOutput = audioSession.currentRoute.outputs.first
        
        NotificationCenter.default.post(name: AVAudioSession.routeChangeNotification, object: nil)
        setupNotifications()
        
        updateAudioSessionInfo()
    }
    
    //MARK: Methods
    func updateAudioSessionInfo() {
        let currentRoute = audioSession.currentRoute
        output.text += "\nCurrent route: \(currentRoute) \n"
        
        
        for input in currentRoute.inputs {
            let dataSources = extractAudioInputDataSourceDescription(input.dataSources)
            let isCurrentInput = input == currentInput
            addInputAudioSource(withName: input.portName, sources: dataSources, isInUse: isCurrentInput)
        }
        for output in currentRoute.outputs {
            let dataSources = extractAudioInputDataSourceDescription(output.dataSources)
            let isCurrentInput = output == currentOutput
            addOutputAudioSource(withName: output.portName, sources: dataSources, isInUse: isCurrentInput)
        }

    }
    
    //helpers
    private func addInputAudioSource(withName name: String, sources: [String]? = nil, isInUse: Bool = false) {
        let audioSource = AudioSource(name: name, dataSources: sources, isInUse: isInUse)
        let isAlreadyAdded = audioInputSources.contains(audioSource)
        if isAlreadyAdded == false {
            audioInputSources.append(audioSource)
        }
    }

    private func addOutputAudioSource(withName name: String, sources: [String]? = nil, isInUse: Bool = false) {
        let audioSource = AudioSource(name: name, dataSources: sources, isInUse: isInUse)
        let isAlreadyAdded = audioOutputSources.contains(audioSource)
        if isAlreadyAdded == false {
            audioOutputSources.append(audioSource)
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
        output.text += "\nRoute change reason is: \(reason)\n\n"
        switch reason {
        case .newDeviceAvailable:
            for currentOutput in audioSession.currentRoute.outputs where currentOutput.portType == AVAudioSession.Port.headphones {
                
            }
            updateAudioSessionInfo()
            //TODO: this is where by default, when a new device is plugged in, Modacity uses that device
            //also, it appends a new device to input or output audio sources
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for currentOutput in previousRoute.outputs where currentOutput.portType == AVAudioSession.Port.headphones {
                    
                }
            }
        //TODO: handle other possible reasons
        default: ()
            output.text += "unknown reason"
        }
        
        audioSourcesTableView.reloadData()
        //TODO: some func that calls audioSession.setPreferredInput if input needs to change, and for some reason, it won't change automatically (is that necessary & possible for output as well?)
    }
    

}

