//
//  AudioSource.swift
//  testAudioRoute
//
//  Created by ASM on 10/31/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import Foundation
import AVFoundation

//TODO: is this necessary--use AVAudioSession.CategoryOptions instead ?
enum PossibleAudioSourceName {
    case deviceSpeakers
    case headphones
    case bluetoothHeadset
}

//TODO: is this necessary--use AVAudioSessionRouteDescription or AVAudioSessionPortDescription
struct AudioSource: Equatable {
    let port: AVAudioSessionPortDescription
    var isInUse: Bool
    
    init(port: AVAudioSessionPortDescription, isInUse: Bool = false) {
        self.port = port
        self.isInUse = isInUse
    }
    
}


