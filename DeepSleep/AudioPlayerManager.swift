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

protocol AudioPlayerUIDelegate {
    func playerDidPlayed(atTime time: TimeInterval)
    
}

class AudioPlayerManager: NSObject {
    
    fileprivate var player: AVAudioPlayer!
    fileprivate var audioItems: [AudioItem]!
    fileprivate var shuffledAudioItems: [AudioItem]!
    fileprivate var currentItem: AudioItem!
    fileprivate var currentPlayMode: AudioPlayMode!
    var delegate: AudioPlayerUIDelegate?
    
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
            player.removeObserver(self, forKeyPath: "currentTime")
            player = nil
        }
        currentItem = audioItem
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.enableRate = false
            player.numberOfLoops = 0
            if player.prepareToPlay() {
                player.play()
            }
            player.addObserver(self, forKeyPath: "currentTime", options: .new, context: nil)
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
            shuffledAudioItems = shuffled(originalItems: audioItems)
        default:
            currentPlayMode = .listLoop
        }
    }
    
    func seekToTime(_ time: TimeInterval) -> Bool {
        return player.play(atTime: time)
    }
    
    fileprivate func shuffled(originalItems items: [AudioItem]) -> [AudioItem]{
        var newItems:[AudioItem] = items
        for i in 1..<items.count {
            let index = Int(arc4random()) % i
            if index != i {
                newItems.swapAt(i, index)
            }
        }
        return newItems
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentTime" {
            guard let delegate = delegate else { return }
            delegate.playerDidPlayed(atTime: player.currentTime)
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    
}

extension AudioPlayerManager: AVAudioPlayerDelegate{
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            switch currentPlayMode {
            case .listLoop, .listRandom:
                if let items = currentPlayMode == .listLoop ? audioItems : shuffledAudioItems, let index = items.firstIndex(of: currentItem){
                    let nextIndex = index + 1 >= items.count ? 0 : index + 1
                    play(audioItem: items[nextIndex])
                    player.numberOfLoops = 0
                }
            default:
                player.numberOfLoops = -1
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }

    
}
