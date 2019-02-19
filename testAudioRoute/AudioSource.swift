//
//  AudioSource.swift
//  testAudioRoute
//
//  Created by Andrew Struck-Marcell on 10/30/18.
//  MIT License.
//

import Foundation
import AVFoundation


struct PortInfo: Equatable {
    let description: AVAudioSessionPortDescription
    let numDataSources: Int
    
    init(port: AVAudioSessionPortDescription) {
        self.description = port
        self.numDataSources = port.dataSources?.count ?? 0
    }
    
    static func ==(lhs: PortInfo, rhs: PortInfo) -> Bool {
        return lhs.description.portType == rhs.description.portType && lhs.numDataSources == rhs.numDataSources
    }
}

struct AudioSource: Equatable {
    let portInfo: PortInfo
    let dataSource: AVAudioSessionDataSourceDescription?
    
    init(portInfo: PortInfo, dataSource: AVAudioSessionDataSourceDescription?) {
        self.portInfo = portInfo
        self.dataSource = dataSource
    }
    
    static func ==(lhs: AudioSource, rhs: AudioSource) -> Bool {
        switch (lhs.dataSource == nil, rhs.dataSource == nil) {
        case (true, true):
            return lhs.portInfo == rhs.portInfo
        case (false, false):
            return lhs.portInfo == rhs.portInfo && lhs.dataSource!.dataSourceID == rhs.dataSource!.dataSourceID && lhs.dataSource!.dataSourceName == rhs.dataSource!.dataSourceName
        default:
            return false
        }
    }
}


