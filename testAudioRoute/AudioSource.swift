//
//  AudioSource.swift
//  testAudioRoute
//
//  Created by ASM on 10/31/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import Foundation
import AVFoundation


//TODO: is this necessary--use AVAudioSessionRouteDescription or AVAudioSessionPortDescription
struct PortInfo: Equatable {
    let port: AVAudioSessionPortDescription
    var isInUse: Bool
    let numDataSources: Int
    
    init(port: AVAudioSessionPortDescription, isInUse: Bool = false) {
        self.port = port
        self.isInUse = isInUse
        self.numDataSources = port.dataSources?.count ?? 0
    }
}

struct AudioSource {
    let portInfo: PortInfo
    let dataSource: AVAudioSessionDataSourceDescription
    
    init(portInfo: PortInfo, dataSource: AVAudioSessionDataSourceDescription) {
        self.portInfo = portInfo
        self.dataSource = dataSource
    }
    
}


