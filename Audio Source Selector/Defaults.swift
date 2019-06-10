//
//  Defaults.swift
//  Audio Source Selector
//
//  Created by ASM on 5/16/19.
//  Copyright © 2019 ASM. All rights reserved.
//

import Foundation

final class Defaults {
    let standardDefaults = UserDefaults.standard
    let selectedInputSource = "selectedInputSource"
    
    func saveSelectedInputSource(_ audioSource: AudioSource) {
        //TODO: likely need to encode this
        standardDefaults.set(audioSource, forKey: selectedInputSource)
    }
    
    func loadSelectedInputSource() -> AudioSource {
        //TODO: how to get an AudioSource?
        let audioSource = standardDefaults.object(forKey: selectedInputSource) as! AudioSource
        
        return audioSource
    }
}

