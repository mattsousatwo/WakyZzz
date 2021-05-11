//
//  MPVolumeView+EXT.swift
//  WakyZzz
//
//  Created by Matthew Sousa on 5/11/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import Foundation
import MediaPlayer

extension MPVolumeView {
    
    /// Set the volume of system
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
    
}
