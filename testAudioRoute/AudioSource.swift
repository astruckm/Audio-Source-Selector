//
//  AudioSource.swift
//  testAudioRoute
//
//  Created by ASM on 10/31/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import Foundation

//TODO: is this necessary--use AVAudioSession.CategoryOptions instead ?
enum PossibleAudioSourceName {
    case deviceSpeakers
    case headphones
    case bluetoothHeadset
}

//TODO: is this necessary--use AVAudioSessionRouteDescription or AVAudioSessionPortDescription
struct AudioSource: Equatable {
    let name: String
    let dataSources: [String]?
    var isInUse: Bool
    
    init(name: String, dataSources: [String]? = nil, isInUse: Bool = false) {
        self.name = name
        self.dataSources = dataSources
        self.isInUse = isInUse
    }
}

