//
//  ViewController.swift
//  testAudioRoute
//
//  Created by ASM on 10/29/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var setting1: UILabel!
    @IBOutlet weak var setting2: UILabel!
    @IBOutlet weak var setting3: UILabel!
    @IBOutlet weak var output: UITextView!    
    @IBOutlet weak var audioSourcesTableView: UITableView!
    
    //Model
    struct AudioSource {
        let name: String
        let sources: [String]?
        let route: String?
        var isInUse: Bool
        
        init(name: String, sources: [String]? = nil, route: String? = nil, isInUse: Bool = false) {
            self.name = name
            self.sources = sources
            self.route = route
            self.isInUse = isInUse
        }
    }
    
    //TODO: account for all, and add this to codebase (depending on Modacity code)
    enum PossibleAudioSources {
        case deviceSpeakers
        case headphones
        case bluetoothHeadset
    }
    
    //MARK: Properties
    var audioInputSources = [AudioSource]()
    var audioOutputSources = [AudioSource]()
    
    let audioSession = AVAudioSession()
    let audioPlayer = AVAudioPlayer()
    var headphonesConnected = false {
        didSet {
            updateUI(settingSelected: headphonesConnected ? setting1 : setting2)
        }
    }
    
    //MARK: View Controller lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        audioSourcesTableView.tableFooterView = UIView()
        
        NotificationCenter.default.post(name: AVAudioSession.routeChangeNotification, object: nil)
        setupNotifications()
        
        let labelToSelect  = headphonesConnected ? setting1 : setting2
        updateUI(settingSelected: labelToSelect!)
        displayAudioSessionInfo()
    }
    
    //MARK: Methods
    func displayAudioSessionInfo() {
        //TODO: use this to have in-use audio source cell checkmarked. Need to check inputs and outputs against currentRoutes ins and outs
        let inputNames: Set<String> = Set(audioSession.currentRoute.inputs.map { ($0.portName) })
        let outputNames: Set<String> = Set(audioSession.currentRoute.outputs.map { $0.portName })
        
        output.text += "\nCurrent route: \(audioSession.currentRoute) \n"

        if let availableInputs = audioSession.availableInputs {
            availableInputs.forEach { (input) in
                output.text += "portName: " + input.portName + "\n"
                let isInCurrentRoute = inputNames.contains(input.portName) ///provisional code
                
                let dataSourceNames = extractAudioInputDataSourceDescription(input.dataSources)
                output.text += "Input dataSources: \(String(describing: dataSourceNames)) \n"
                addInputAudioSource(withName: input.portName, sources: dataSourceNames, isInUse: isInCurrentRoute)
            }
        }
        if let outputDataSources = audioSession.outputDataSources {
            outputDataSources.forEach { (outputDataSource) in
                let dataSourceName = outputDataSource.dataSourceName
                let isInCurrentRoute = outputNames.contains(dataSourceName) ///provisional code
                
                output.text += "Output dataSourceName: \(dataSourceName) \n"
                addOutputAudioSource(withName: dataSourceName, isInUse: isInCurrentRoute)
            }
        } else {
            output.text += "\nOutput data source is nil. \n"
        }
        
    }

    func updateUI(settingSelected: UILabel) {
        let labels = [setting1, setting2, setting3]
        for label in labels {
            label?.textColor = .black
        }
        settingSelected.textColor = .red
    }
    
    //helpers
    private func addInputAudioSource(withName name: String, sources: [String]? = nil, andRoute route: String? = nil, isInUse: Bool = false) {
        let audioSource = AudioSource(name: name, sources: sources, route: route, isInUse: isInUse)
        audioInputSources.append(audioSource)
    }

    private func addOutputAudioSource(withName name: String, sources: [String]? = nil, andRoute route: String? = nil, isInUse: Bool = false) {
        let audioSource = AudioSource(name: name, sources: sources, route: route, isInUse: isInUse)
        audioOutputSources.append(audioSource)
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
            let session = AVAudioSession.sharedInstance()
            for currentOutput in session.currentRoute.outputs where currentOutput.portType == AVAudioSession.Port.headphones {
                output.text += "headphones connected set to true"
                headphonesConnected = true
            }
            //TODO: this is where that by default, when a new device is plugged in, Modacity uses that device???
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for currentOutput in previousRoute.outputs where currentOutput.portType == AVAudioSession.Port.headphones {
                    output.text += "headphones connected set to false"
                    headphonesConnected = false
                }
            }
        //TODO: account for ALL possible reasons
        default: ()
            headphonesConnected.toggle()
            output.text += "unknown reason"
        }
        
        audioInputSources = []
        audioOutputSources = []
        displayAudioSessionInfo()
        audioSourcesTableView.reloadData()
    }
    

}

