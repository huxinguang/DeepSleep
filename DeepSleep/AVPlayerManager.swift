//
//  AVPlayerManager.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/31.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import AVFoundation

private let kStatusKeyPath = "status"
private let kLoadedTimeRangesKeyPath = "loadedTimeRanges"
private let kPlaybackBufferEmptyKeyPath = "playbackBufferEmpty"
private let kPlaybackBufferFullKeyPath = "playbackBufferFull"
private let kPlaybackLikelyToKeepUpKeyPath = "playbackLikelyToKeepUp"
private let kTimeControlStatus = "timeControlStatus"
private let kPlayerRateKeyPath = "rate"

enum AudioPlayMode: Int {
    case listLoop = 0
    case singleLoop = 1
    case listRandom = 2
}

protocol PlayerUIDelegate {
    func playerReadyToPlay(withDuration duration: Float64) -> Void
    func playerDidLoad(toProgress progress: Float64) -> Void
    func playerDidPlay(toProgress progress: Float) -> Void
    func playerDidPlay(toTime: Float64, totalTime: Float64) -> Void
    func playbackBufferEmpty(_ bufferEmpty: Bool) -> Void
    func playbackLikelyToKeepUp(_ likelyToKeepUp: Bool) -> Void
    func playbackBufferFull(_ bufferFull: Bool) -> Void
    func playerDidFinishPlaying() -> Void
    func playerDidFailToPlay() -> Void
    func playerDidEndSeeking() -> Void
    func playerModeDidChange(toMode mode: AudioPlayMode) -> Void
    func playerItemDidChange(toItem item: AudioItem?) -> Void
    func playerTimeControlStatusDidChange(toStatus status: AVPlayer.TimeControlStatus) -> Void
    
    
}

class AVPlayerManager: NSObject {
        
    private(set) var player: AVPlayer!
    fileprivate var chaseTime: CMTime = .zero
    fileprivate var sliderObserverToken: Any!
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
    fileprivate var playingItem: AudioItem?{
        didSet{
            if let delegate = delegate{
                delegate.playerItemDidChange(toItem: playingItem)
            }
        }
    }
    var isSeekInProgress: Bool = false
    var headphonesConnected: Bool = false{
        didSet{
            if headphonesConnected {
                play()
            }else{
                pause()
            }
        }
    }
    
    static let share: AVPlayerManager = {
        let instance = AVPlayerManager()
        NotificationCenter.default.addObserver(instance, selector: #selector(handleInterruption(_:)), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        NotificationCenter.default.addObserver(instance, selector: #selector(handleRouteChange(_:)), name: AVAudioSession.routeChangeNotification, object: AVAudioSession.sharedInstance())
        return instance
    }()
    
    func play(audioItem: AudioItem) {
        guard let url = URL(string: audioItem.url), audioItem != playingItem else { return }
        let playerItem = AVPlayerItem(url: url)
        if player != nil {
            perform(#selector(removeKVO), on: .main, with: self, waitUntilDone: true)
            player.replaceCurrentItem(with: playerItem)
            play()
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
            play()
            sliderObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) {[weak self] (time) in
                guard let strongSelf = self, let delegate = strongSelf.delegate, let playerItem = strongSelf.player.currentItem else { return }
                let progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(playerItem.duration)
                delegate.playerDidPlay(toProgress: Float(progress))
            }
            timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) {[weak self] (time) in
                guard let strongSelf = self, let delegate = strongSelf.delegate, let playerItem = strongSelf.player.currentItem, strongSelf.player.status == .readyToPlay, !time.isIndefinite, !playerItem.duration.isIndefinite else { return }
                delegate.playerDidPlay(toTime: CMTimeGetSeconds(time), totalTime: CMTimeGetSeconds(playerItem.duration))
            }

            perform(#selector(addKVO), on: .main, with: self, waitUntilDone: true)
        }
        
        playingItem = audioItem
        
    }
    
    @objc
    func addKVO() {
        /*
        Important: You should register for KVO change notifications and unregister from KVO change notifications on the main thread. This avoids the possibility of receiving a partial notification if a change is being made on another thread. AV Foundation invokes observeValueForKeyPath:ofObject:change:context: on the main thread, even if the change operation is made on another thread.
        */
        
        guard let player = player else { return }
        player.addObserver(self, forKeyPath: kTimeControlStatus, options: .new, context: nil)
        
        guard let playerItem = player.currentItem else { return }
        playerItem.addObserver(self, forKeyPath: kStatusKeyPath, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: kLoadedTimeRangesKeyPath, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: kPlaybackBufferEmptyKeyPath, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: kPlaybackBufferFullKeyPath, options: .new, context: nil)
        playerItem.addObserver(self, forKeyPath: kPlaybackLikelyToKeepUpKeyPath, options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled(_:)), name: .AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        
        
    }
    
    @objc
    func removeKVO() {
        
        guard let player = player else { return }
        player.removeObserver(self, forKeyPath: kTimeControlStatus)
        
        guard let playerItem = player.currentItem else { return }
        playerItem.removeObserver(self, forKeyPath: kStatusKeyPath)
        playerItem.removeObserver(self, forKeyPath: kLoadedTimeRangesKeyPath)
        playerItem.removeObserver(self, forKeyPath: kPlaybackBufferEmptyKeyPath)
        playerItem.removeObserver(self, forKeyPath: kPlaybackBufferFullKeyPath)
        playerItem.removeObserver(self, forKeyPath: kPlaybackLikelyToKeepUpKeyPath)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
    }
    
    @objc
    func playbackStalled(_ notification: Notification) {
        print("playbackStalled")
    }
    
    @objc
    func playerItemDidPlayToEndTime(_ notification: Notification) {
        guard let delegate = delegate else { return }
        player.seek(to: .zero)
        delegate.playerDidFinishPlaying()
        print("rate === \(player.rate)")
        switch currentPlayMode {
        case .listLoop, .listRandom:
            guard let currentItem = playingItem, let audioItems = audioItems else { return }
            var items: [AudioItem]!
            if currentPlayMode == .listLoop {
                items = audioItems
            }else{
                if shuffledAudioItems == nil {
                    shuffledAudioItems = shuffled(originalItems: audioItems)
                }
                items = shuffledAudioItems
            }
            if let index = items.firstIndex(of: currentItem){
                let nextIndex = index + 1 >= items.count ? 0 : index + 1
                play(audioItem: items[nextIndex])
            }
            
        default:
            break
        }
    }
    
    @objc
    func playerItemFailedToPlayToEndTime(_ notification: Notification) {
        print("playerItemFailedToPlayToEndTime")
    }
    
    @objc
    func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        if type == .began {
            // Interruption began, take appropriate actions (save state, update user interface)
        }else if type == .ended {
            /*
             If the interruption type is AVAudioSessionInterruptionTypeEnded, the userInfo dictionary might contain an AVAudioSessionInterruptionOptions value. An options value of AVAudioSessionInterruptionOptionShouldResume is a hint that indicates whether your app should automatically resume playback if it had been playing when it was interrupted. Media playback apps should always look for this flag before beginning playback after an interruption. If it’s not present, playback should not begin again until initiated by the user. Apps that don’t present a playback interface, such as a game, can ignore this flag and reactivate and resume playback when the interruption ends.
             
             Note: There is no guarantee that a begin interruption will have a corresponding end interruption. Your app needs to be aware of a switch to a foreground running state or the user pressing a Play button. In either case, determine whether your app should reactivate its audio session.

             */
            guard let optionsValue =
                userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                // Interruption Ended - playback should resume
            }
        }
    }
    
    @objc
    func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                headphonesConnected = true
                break
            }
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where output.portType == AVAudioSession.Port.headphones {
                    headphonesConnected = false
                    break
                }
            }
        default: ()
        }
    }
    
    func play() {
        guard let _ = player.currentItem else { return }
        /*
         You can activate the audio session at any time after setting its category, but it’s generally preferable to defer this call until your app begins audio playback. Deferring the call ensures that you won’t prematurely interrupt any other background audio that may be in progress.
         */
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            print("Failed to activate audio session")
        }
        player.play()
        
//        UIApplication.shared.beginBackgroundTask(withName: Constant.Background.taskName) {
//
//        }
    }
    
    func pause() {
        guard let _ = player.currentItem else { return }
        player.pause()
    }
    
    func playPreviousItem() {
        guard let audioItems = audioItems, let currentItem = playingItem else { return }
        var items: [AudioItem]!
        if currentPlayMode == .listRandom {
            if shuffledAudioItems == nil {
                shuffledAudioItems = shuffled(originalItems: audioItems)
            }
            items = shuffledAudioItems
        }else{
            items = audioItems
        }
        if let index = items.firstIndex(of: currentItem){
            let previousIndex = index - 1 < 0 ? items.count - 1 : index - 1
            play(audioItem: items[previousIndex])
        }
    }
    
    func playNextItem() {
        guard let audioItems = audioItems, let currentItem = playingItem else { return }
        var items: [AudioItem]!
        if currentPlayMode == .listRandom {
            if shuffledAudioItems == nil {
                shuffledAudioItems = shuffled(originalItems: audioItems)
            }
            items = shuffledAudioItems
        }else{
            items = audioItems
        }
        if let index = items.firstIndex(of: currentItem){
            let nextIndex = index + 1 >= items.count ? 0 : index + 1
            play(audioItem: items[nextIndex])
        }
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
                    self.play()
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
        guard let newChange = change else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == kStatusKeyPath {
            guard let newValue = newChange[NSKeyValueChangeKey.newKey] as? Int else { return }
            let status = AVPlayer.Status(rawValue: newValue)
            switch status {
            case .unknown:
                break
            case .readyToPlay:
                /*
                There are two ways to ensure that the value of duration is accessed only after it becomes available:
                
                1. Wait until the status of the player item is AVPlayerItem.Status.readyToPlay.
                
                2. Register for key-value observation of the property, requesting the initial value. If the initial value is reported as indefinite, the player item will notify you of the availability of its duration via key-value observing as soon as its value becomes known.
                 
                 readyToPlay不代表AVPlayerItem就能播放了
                 
                */
                guard let delegate = delegate, let playItem = player.currentItem else { return }
                DispatchQueue.main.async {
                    delegate.playerReadyToPlay(withDuration: CMTimeGetSeconds(playItem.duration))
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
            
        }else if keyPath == kLoadedTimeRangesKeyPath{
            guard let playerItem = player.currentItem, let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue, let delegate = delegate else { return }
            let rangeStart = CMTimeGetSeconds(timeRange.start)
            let rangeDuration = CMTimeGetSeconds(timeRange.duration)
            let rangeEnd = rangeStart + rangeDuration
            let progress = rangeEnd/CMTimeGetSeconds(playerItem.duration)
            DispatchQueue.main.async {
                delegate.playerDidLoad(toProgress: progress)
                print("rate = \(self.player.rate)")
            }
        }else if keyPath == kPlaybackBufferEmptyKeyPath{
            guard let bufferEmpty = newChange[NSKeyValueChangeKey.newKey] as? Bool else { return }
            guard let delegate = delegate else { return }
            DispatchQueue.main.async {
                delegate.playbackBufferEmpty(bufferEmpty)
            }
        }else if keyPath == kPlaybackLikelyToKeepUpKeyPath{
            /*
                Indicates whether the item will likely play through without stalling.
             AVPlayer会根据当前的AVPlayerItem的loadedTimeRanges和网速来评估AVPlayerItem是否可以流畅播放而没有停顿，不同AVPlayerItem、不同网络状况，playbackLikelyToKeepUp从fasle变成true时loadedTimeRanges占总的百分比也不尽相同，只有playbackLikelyToKeepUp变成true时，AVPlayer才会播放，否则处于暂停加载状态
                
            */
            guard let likelyToKeepUp = newChange[NSKeyValueChangeKey.newKey] as? Bool else { return }
            guard let delegate = delegate else { return }
            DispatchQueue.main.async {
                delegate.playbackLikelyToKeepUp(likelyToKeepUp)
            }
        }else if keyPath == kPlaybackBufferFullKeyPath{
            guard let bufferFull = newChange[NSKeyValueChangeKey.newKey] as? Bool else { return }
            guard let delegate = delegate else { return }
            DispatchQueue.main.async {
                delegate.playbackBufferFull(bufferFull)
            }
        }else if keyPath == kTimeControlStatus{
            guard let newValue = newChange[NSKeyValueChangeKey.newKey] as? Int, let timeControlStatus = AVPlayer.TimeControlStatus(rawValue: newValue), let delegate = delegate else { return }
            DispatchQueue.main.async {
                delegate.playerTimeControlStatusDidChange(toStatus: timeControlStatus)
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
        player.removeTimeObserver(sliderObserverToken!)
        player.removeTimeObserver(timeObserverToken!)
        sliderObserverToken = nil
        timeObserverToken = nil
        NotificationCenter.default.removeObserver(self)
        player.currentItem?.cancelPendingSeeks()
        perform(#selector(removeKVO), on: .main, with: self, waitUntilDone: true)
    }
    
    
}
