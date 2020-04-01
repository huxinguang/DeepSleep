//
//  AVPlayerManager.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/31.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import AVFoundation

enum AudioPlayMode: Int {
    case listLoop = 0
    case singleLoop = 1
    case listRandom = 2
}

protocol PlayerUIDelegate {
    func playerReadyToPlay() -> Void
    func playerDidLoad(toProgress progress: Float64) -> Void
    func playerDidPlay(toTime: CMTime, totalTime: CMTime) -> Void
    func playerPlaybackBufferEmpty() -> Void
    func playerPlaybackLikelyToKeepUp() -> Void
    func playerDidFinishPlaying() -> Void
    func playerDidFailToPlay() -> Void
    func playerDidEndSeeking() -> Void
    func playerModeDidChange(toMode mode: AudioPlayMode) -> Void
}

class AVPlayerManager: NSObject {
        
    fileprivate var player: AVPlayer!
    fileprivate var chaseTime: CMTime = .zero
    fileprivate var timeObserverToken: Any!
    var delegate: PlayerUIDelegate?
    var audioItems: [AudioItem]?
    fileprivate var shuffledAudioItems: [AudioItem]?
    private(set) var currentPlayMode: AudioPlayMode!{
        didSet{
            if let player = player, let delegate = delegate {
                player.actionAtItemEnd = currentPlayMode == .singleLoop ? .none : .pause
                UserDefaults.standard.set(currentPlayMode.rawValue, forKey: Constant.UserDefaults.PlayerMode)
                UserDefaults.standard.synchronize()
                delegate.playerModeDidChange(toMode: currentPlayMode)
            }
        }
    }
    fileprivate var currentItem: AudioItem!
    var isSeekInProgress: Bool = false
    
    static let share: AVPlayerManager = {
        let instance = AVPlayerManager()
        return instance
    }()

    func play(audioItem: AudioItem) {
        guard let url = URL(string: audioItem.url), audioItem != currentItem else { return }
        let playerItem = AVPlayerItem(url: url)
        currentItem = audioItem
        if player != nil {
            perform(#selector(removeKVO), on: .main, with: self, waitUntilDone: true)
            player.replaceCurrentItem(with: playerItem)
            player.play()
            perform(#selector(addKVO), on: .main, with: self, waitUntilDone: true)
        }else{
            player = AVPlayer(playerItem: playerItem)
            if let mode = UserDefaults.standard.object(forKey: Constant.UserDefaults.PlayerMode) as? Int {
                currentPlayMode = AudioPlayMode(rawValue: mode)
            }else{
                currentPlayMode = .listLoop
            }
            player.automaticallyWaitsToMinimizeStalling = true
            player.usesExternalPlaybackWhileExternalScreenIsActive = true
            player.play()
            timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) {[weak self] (time) in
                guard let strongSelf = self, let delegate = strongSelf.delegate, let playerItem = strongSelf.player.currentItem else {return}
                delegate.playerDidPlay(toTime: time, totalTime: playerItem.duration)
            }
            perform(#selector(addKVO), on: .main, with: self, waitUntilDone: true)
        }
        
    }
    
    @objc
    func addKVO() {
        /*
        Important: You should register for KVO change notifications and unregister from KVO change notifications on the main thread. This avoids the possibility of receiving a partial notification if a change is being made on another thread. AV Foundation invokes observeValueForKeyPath:ofObject:change:context: on the main thread, even if the change operation is made on another thread.
        */
        guard let playerItem = player.currentItem else { return }
        playerItem.addObserver(self, forKeyPath: "status", options: [.new,.old], context: nil)
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: [.new,.old], context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.new,.old], context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.new,.old], context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc
    func removeKVO() {
        guard let playerItem = player.currentItem else { return }
        playerItem.removeObserver(self, forKeyPath: "status")
        playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        playerItem.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    @objc
    func playerItemDidReachEnd() {
        guard let delegate = delegate else { return }
        delegate.playerDidFinishPlaying()
        player.seek(to: .zero)
        switch currentPlayMode {
        case .listLoop, .listRandom:
            if let items = currentPlayMode == .listLoop ? audioItems : shuffledAudioItems, let index = items.firstIndex(of: currentItem){
                let nextIndex = index + 1 >= items.count ? 0 : index + 1
                play(audioItem: items[nextIndex])
            }
        default:
            break
        }
        
    }
    
    func play() {
        guard let _ = player.currentItem else { return }
        player.play()
    }
    
    func pause() {
        guard let _ = player.currentItem else { return }
        player.pause()
    }
    
    func update(progress: Float) {
        guard let playerItem = player.currentItem else { return }
        let totalSeconds = CMTimeGetSeconds(playerItem.duration)
        let currentSeconds = totalSeconds * Float64(progress)
        let timeScale = playerItem.currentTime().timescale
        let current = CMTime(seconds: currentSeconds, preferredTimescale: timeScale)
        seekSmoothly(toTime: current) 
    }
    
    func seekSmoothly(toTime time: CMTime) {
        guard let playerItem = player.currentItem else { return }
        player.pause()
        if CMTimeCompare(time, .zero) == 1 && CMTimeCompare(time, playerItem.duration) == -1 && CMTimeCompare(time, chaseTime) != 0{
            chaseTime = time
            if !isSeekInProgress {
                trySeekToChaseTime()
            }
        }
        
    }
    
    func trySeekToChaseTime() {
        if player.status == .unknown {
            // wait until item becomes ready (KVO player.currentItem.status)
        }else{
            actuallySeekToTime()
        }
    }
    
    func actuallySeekToTime() {
        let seekTimeInProgress = chaseTime
        isSeekInProgress = true
        //Important: Calling the seekToTime:toleranceBefore:toleranceAfter: method with small or zero-valued tolerances may incur additional decoding delay, which can impact your app’s seeking behavior.
        player.seek(to: seekTimeInProgress, toleranceBefore: .zero, toleranceAfter: .zero) {[unowned self] (finished) in
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                if finished {
                    self.isSeekInProgress = false
                    self.player.play()
                    if let delegate = self.delegate {
                        delegate.playerDidEndSeeking()
                    }
                }
            }else{
                self.trySeekToChaseTime()
            }
        }
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            guard let newChange = change,let status = newChange[NSKeyValueChangeKey.newKey] as? AVPlayer.Status else { return }
            switch status {
            case .unknown:
                break
            case .readyToPlay:
                /*
                There are two ways to ensure that the value of duration is accessed only after it becomes available:
                
                1. Wait until the status of the player item is AVPlayerItem.Status.readyToPlay.
                
                2. Register for key-value observation of the property, requesting the initial value. If the initial value is reported as indefinite, the player item will notify you of the availability of its duration via key-value observing as soon as its value becomes known.
                */
                guard let delegate = delegate else { return }
                DispatchQueue.main.async {
                    delegate.playerReadyToPlay()
                }
                
            case .failed:
                if let error = player.currentItem?.error {
                    print(error.localizedDescription)
                }
                guard let delegate = delegate else { return }
                DispatchQueue.main.async {
                    delegate.playerDidFailToPlay()
                }
            default:
                break
            }
            
        }else if keyPath == "loadedTimeRanges"{
            guard let playerItem = player.currentItem, let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue, let delegate = delegate else { return }
            let rangeStart = CMTimeGetSeconds(timeRange.start)
            let rangeDuration = CMTimeGetSeconds(timeRange.duration)
            let rangeEnd = rangeStart + rangeDuration
            let progress = rangeEnd/CMTimeGetSeconds(playerItem.duration)
            DispatchQueue.main.async {
                delegate.playerDidLoad(toProgress: progress)
            }
        }else if keyPath == "playbackBufferEmpty"{
            guard let delegate = delegate else { return }
            DispatchQueue.main.async {
                delegate.playerPlaybackBufferEmpty()
            }
        }else if keyPath == "playbackLikelyToKeepUp"{
            guard let delegate = delegate else { return }
            DispatchQueue.main.async {
                delegate.playerPlaybackLikelyToKeepUp()
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
    }
    
    func resetPlayMode() {
        switch currentPlayMode {
        case .listLoop:
            currentPlayMode = .singleLoop
        case .singleLoop:
            currentPlayMode = .listRandom
            guard let audioItems = audioItems else { return }
            shuffledAudioItems = shuffled(originalItems: audioItems)
            print(shuffledAudioItems!, audioItems)
        default:
            currentPlayMode = .listLoop
        }
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
    
    deinit {
        player.removeTimeObserver(timeObserverToken!)
        timeObserverToken = nil
        NotificationCenter.default.removeObserver(self)
        player.currentItem?.cancelPendingSeeks()
        perform(#selector(removeKVO), on: .main, with: self, waitUntilDone: true)
    }
    
    
}
