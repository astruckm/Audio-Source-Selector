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


class ViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var output: UITextView!
    @IBOutlet weak var audioSourcesTableView: UITableView!
    @IBOutlet weak var testToneButton: UIButton!
    
    //MARK: Properties
    let audioSession = AVAudioSession.sharedInstance()
    let viewModel = ViewModel()
    var audioPlayer: AVAudioPlayer?
    var testToneShouldPlay = true

    //Custom data sources
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
            viewModel.currentInput = AudioSource(portInfo: PortInfo(port: initialInput), dataSource: initialInput.dataSources?.first)
        }
        if let initialOutput = audioSession.currentRoute.outputs.first {
            viewModel.currentOutput = AudioSource(portInfo: PortInfo(port: initialOutput), dataSource: initialOutput.dataSources?.first)
        }
        viewModel.previousInput = nil
        viewModel.previousOutput = nil
        
        viewModel.inputAudioSources = viewModel.populateAudioSources(with: audioSession.availableInputs ?? audioSession.currentRoute.inputs)
        viewModel.outputAudioSources = viewModel.populateAudioSources(with: audioSession.currentRoute.outputs)
        
        NotificationCenter.default.post(name: AVAudioSession.routeChangeNotification, object: nil)
        setupNotifications()
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
        output.text += "handleRouteChange invoked"
        guard let userInfo = notification.userInfo else {
                output.text += "notification userInfo is nil"
                return
        }
        guard let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt else {
                output.text += "reasonValue not found or invalid"
                return
        }
        guard let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
            output.text += "unable to initialize route change reason"
            return
        }
        switch reason {
        case .newDeviceAvailable, .oldDeviceUnavailable:
            output.text += "new route plugged in or old route unplugged"
            let newInputPort = viewModel.portThatChanged(among: audioSession.availableInputs ?? audioSession.currentRoute.inputs)
            let newOutputPort = viewModel.portThatChanged(among: audioSession.currentRoute.outputs)
            viewModel.updateAudioSessionInfo(withNewInput: newInputPort, newOutput: newOutputPort)
            audioSourcesTableView.reloadData()
        case .routeConfigurationChange:
            output.text += "\nRoute configuration changed"
        //TODO: Handle other possible reasons?
        default:
            print("unknown reason")
        }
    }
    
}

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





