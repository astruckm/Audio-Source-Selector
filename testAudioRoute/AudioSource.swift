//
//  AudioSource.swift
//  testAudioRoute
//
//  Created by ASM on 10/31/18.
//  Copyright © 2018 POTO. All rights reserved.
//

import Foundation
import AVFoundation


struct PortInfo: Equatable {
    let port: AVAudioSessionPortDescription
    let numDataSources: Int
    
    init(port: AVAudioSessionPortDescription) {
        self.port = port
        self.numDataSources = port.dataSources?.count ?? 0
    }
}

struct AudioSource {
    let portInfo: PortInfo
    let dataSource: AVAudioSessionDataSourceDescription?
    
    init(portInfo: PortInfo, dataSource: AVAudioSessionDataSourceDescription?) {
        self.portInfo = portInfo
        self.dataSource = dataSource
    }
    
}


