//
//  AudioPlayerManager.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/30.
//  Copyright © 2020 wy. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioPlayMode {
    case listLoop
    case singleLoop
    case listRandom
}

class AudioPlayerManager: NSObject {
    
    fileprivate var player: AVAudioPlayer!
    fileprivate var audioItems: [AudioItem]!
    fileprivate var currentItem: AudioItem!
    fileprivate var currentPlayMode: AudioPlayMode!
    
    static let share: AudioPlayerManager = {
        let instance = AudioPlayerManager()
        return instance
    }()
    
    func play(audioItem: AudioItem) {
        guard let url = URL(string: audioItem.url) else { return }
        if player != nil {
            if player.isPlaying {
                player.pause()
            }
            player.stop()
            player = nil
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.enableRate = false
            player.numberOfLoops = 0
            if player.prepareToPlay() {
                player.play()
            }
            self.player = player
        } catch  {
            print(error)
        }
    }
    
    func resetPlayMode() {
        switch currentPlayMode {
        case .listLoop:
            currentPlayMode = .singleLoop
        case .singleLoop:
            currentPlayMode = .listRandom
        default:
            currentPlayMode = .listLoop
        }
    }
    
    func seekToTime(_ time: TimeInterval) -> Bool {
        return player.play(atTime: time)
    }
    
    
    
}

extension AudioPlayerManager: AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            if currentPlayMode == .listLoop {
                
                
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }

    
    
    
}
