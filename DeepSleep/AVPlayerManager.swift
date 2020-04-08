//
//  AVPlayerManager.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/31.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

/*
 Readme
 
  It’s important to maintain sample-accurate timing when working with media, and floating-point imprecisions can often result in timing drift. To resolve these imprecisions, AVFoundation represents time using the Core Media framework’s CMTime data type.
 
 */

// Key-value observing context
private var playerItemContext = 0
private var playerContext = 0


enum AudioPlayMode: Int {
    case listLoop = 0
    case singleLoop = 1
    case listRandom = 2
}

protocol PlayerUIDelegate {
    func playerReadyToPlay(withDuration duration: TimeInterval) -> Void
    func playerDidLoad(toProgress progress: TimeInterval) -> Void
    func playerDidPlay(toProgress progress: Float) -> Void
    func playerDidPlay(toTime: TimeInterval, totalTime: TimeInterval) -> Void
    func playbackBufferEmpty(_ bufferEmpty: Bool) -> Void
    func playbackLikelyToKeepUp(_ likelyToKeepUp: Bool) -> Void
    func playbackBufferFull(_ bufferFull: Bool) -> Void
    func playerDidFinishPlaying() -> Void
    func playerDidFailToPlay() -> Void
    func playerDidEndSeeking() -> Void
    func playerModeDidChange(toMode mode: AudioPlayMode) -> Void
    func playerItemDidChange(toItem item: AudioItem?) -> Void
    func playerTimeControlStatusDidChange(toStatus status: AVPlayer.TimeControlStatus) -> Void
    func playerItemsDidChange(items: [AudioItem]) -> Void
}

class AVPlayerManager: NSObject {
        
    private(set) var player: AVPlayer!
    fileprivate var chaseTime: CMTime = .zero
    fileprivate var sliderObserverToken: Any!
    fileprivate var timeObserverToken: Any!
    var delegate: PlayerUIDelegate?
    var audioItems: [AudioItem]?{
        didSet{
            if let delegate = delegate, let newItems = audioItems{
                delegate.playerItemsDidChange(items: newItems)
            }
        }
    }
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
    private(set) var playingItem: AudioItem?{
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
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: [])
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
            
            /*
             KVO works well for general state observations, but isn’t the right choice for observing player timing because it’s not well suited for observing continuous state changes
             */
            let timeScale = CMTimeScale(NSEC_PER_SEC)
            sliderObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.05, preferredTimescale: timeScale), queue: .main) {[weak self] (time) in
                guard let strongSelf = self, let delegate = strongSelf.delegate, let playerItem = strongSelf.player.currentItem else { return }
                let progress = CMTimeGetSeconds(time)/CMTimeGetSeconds(playerItem.duration)
                delegate.playerDidPlay(toProgress: Float(progress))
            }
            timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: timeScale), queue: .main) {[weak self] (time) in
                guard let strongSelf = self, let delegate = strongSelf.delegate, let playerItem = strongSelf.player.currentItem, strongSelf.player.status == .readyToPlay, !time.isIndefinite, !playerItem.duration.isIndefinite else { return }
                delegate.playerDidPlay(toTime: CMTimeGetSeconds(time), totalTime: CMTimeGetSeconds(playerItem.duration))
            }

            perform(#selector(addKVO), on: .main, with: self, waitUntilDone: true)
        }
        
        playingItem = audioItem
        
    }
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
     
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player.rate == 0.0 {
                self.play()
                return .success
            }
            return .commandFailed
        }
     
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player.rate == 1.0 {
                self.pause()
                return .success
            }
            return .commandFailed
        }
        commandCenter.nextTrackCommand.addTarget {[unowned self] event in
            self.playNextItem()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget {[unowned self] event in
            self.playPreviousItem()
            return .success
        }
        
    }
    
    func setupNowPlaying() {
        guard let playingItem = playingItem, let currentItem = player.currentItem else { return }
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = playingItem.name
        if let image = UIImage(named: "lockscreen") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentItem.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = currentItem.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
     
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    @objc
    func addKVO() {
        /*
        Important: You should register for KVO change notifications and unregister from KVO change notifications on the main thread. This avoids the possibility of receiving a partial notification if a change is being made on another thread. AV Foundation invokes observeValueForKeyPath:ofObject:change:context: on the main thread, even if the change operation is made on another thread.
        */
        
        guard let player = player else { return }
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: .new, context: &playerContext)
        
        guard let playerItem = player.currentItem else { return }
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.old, .new], context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.old, .new], context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), options: [.old, .new], context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull), options: [.old, .new], context: &playerItemContext)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), options: [.old, .new], context: &playerItemContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackStalled(_:)), name: .AVPlayerItemPlaybackStalled, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemFailedToPlayToEndTime(_:)), name: .AVPlayerItemFailedToPlayToEndTime, object: playerItem)
        
    }
    
    @objc
    func removeKVO() {
        
        guard let player = player else { return }
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), context: &playerContext)
        
        guard let playerItem = player.currentItem else { return }
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: &playerItemContext)
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), context: &playerItemContext)
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferEmpty), context: &playerItemContext)
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackBufferFull), context: &playerItemContext)
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp), context: &playerItemContext)
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
    
    /*
     Interruptions occur when a competing audio session from an app is activated and that session is not categorized by the system to mix with yours. Your app should respond to interruptions by saving state, updating the user interface, and so on.
     */
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
                play()
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
        let currentSeconds = totalSeconds * TimeInterval(progress)
        print("currentSeconds = \(currentSeconds)")
        let timeScale = playerItem.currentTime().timescale
        let current = CMTime(seconds: currentSeconds, preferredTimescale: timeScale)
        seekSmoothly(toTime: current) 
    }
    
    func seekSmoothly(toTime time: CMTime) {
        guard let playerItem = player.currentItem else { return }
        player.pause()
        if CMTimeCompare(time, .zero) >= 0 && CMTimeCompare(time, playerItem.duration) <= 0 && CMTimeCompare(time, chaseTime) != 0{
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
        if context == &playerItemContext {
            switch keyPath {
            case #keyPath(AVPlayerItem.status):
                let status: AVPlayerItem.Status
                if let newValue = change?[NSKeyValueChangeKey.newKey] as? Int {
                    status = AVPlayerItem.Status(rawValue: newValue)!
                }else{
                    status = .unknown
                }
                switch status {
                case .unknown:
                    print("AVPlayerStatusUnknown")
                    break
                case .readyToPlay:
                    /*
                    There are two ways to ensure that the value of duration is accessed only after it becomes available:
                    
                    1. Wait until the status of the player item is AVPlayerItem.Status.readyToPlay.
                    
                    2. Register for key-value observation of the property, requesting the initial value. If the initial value is reported as indefinite, the player item will notify you of the availability of its duration via key-value observing as soon as its value becomes known.
                     
                     readyToPlay不代表AVPlayerItem就要开始播放了
                     
                    */
                    guard let delegate = delegate, let playItem = player.currentItem else { return }
                    DispatchQueue.main.async {
                        self.setupNowPlaying()
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
            case #keyPath(AVPlayerItem.loadedTimeRanges):
                guard let playerItem = player.currentItem, let timeRange = playerItem.loadedTimeRanges.first?.timeRangeValue, let delegate = delegate else { return }
                let rangeStart = CMTimeGetSeconds(timeRange.start)
                let rangeDuration = CMTimeGetSeconds(timeRange.duration)
                let rangeEnd = rangeStart + rangeDuration
                let progress = rangeEnd/CMTimeGetSeconds(playerItem.duration)
                DispatchQueue.main.async {
                    delegate.playerDidLoad(toProgress: progress)
                }
            case #keyPath(AVPlayerItem.isPlaybackBufferEmpty):
                guard let bufferEmpty = change?[NSKeyValueChangeKey.newKey] as? Bool else { return }
                guard let delegate = delegate else { return }
                DispatchQueue.main.async {
                    delegate.playbackBufferEmpty(bufferEmpty)
                }
            case #keyPath(AVPlayerItem.isPlaybackBufferFull):
                guard let bufferFull = change?[NSKeyValueChangeKey.newKey] as? Bool else { return }
                guard let delegate = delegate else { return }
                DispatchQueue.main.async {
                    delegate.playbackBufferFull(bufferFull)
                }
            case #keyPath(AVPlayerItem.isPlaybackLikelyToKeepUp):
                /*
                    Indicates whether the item will likely play through without stalling.
                 AVPlayer会根据当前的AVPlayerItem的loadedTimeRanges和网速来评估AVPlayerItem是否可以流畅播放而没有停顿，不同AVPlayerItem、不同网络状况，playbackLikelyToKeepUp从fasle变成true时loadedTimeRanges占总的百分比也不尽相同，只有playbackLikelyToKeepUp变成true时，AVPlayer才会播放，否则处于暂停加载状态
                    
                */
                guard let likelyToKeepUp = change?[NSKeyValueChangeKey.newKey] as? Bool else { return }
                guard let delegate = delegate else { return }
                DispatchQueue.main.async {
                    delegate.playbackLikelyToKeepUp(likelyToKeepUp)
                }
            default:
                break
            }
        }else if context == &playerContext{
            switch keyPath {
            case #keyPath(AVPlayer.timeControlStatus):
                guard let newValue = change?[NSKeyValueChangeKey.newKey] as? Int, let timeControlStatus = AVPlayer.TimeControlStatus(rawValue: newValue), let delegate = delegate else { return }
                DispatchQueue.main.async {
                    delegate.playerTimeControlStatusDidChange(toStatus: timeControlStatus)
                }
            default:
                break
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
        if let player = player {
            if let sliderObserverToken = sliderObserverToken {
                player.removeTimeObserver(sliderObserverToken)
                self.sliderObserverToken = nil
            }
            if let timeObserverToken = timeObserverToken {
                player.removeTimeObserver(timeObserverToken)
                self.timeObserverToken = nil
            }
            player.currentItem?.cancelPendingSeeks()
        }
        
        NotificationCenter.default.removeObserver(self)
        perform(#selector(removeKVO), on: .main, with: self, waitUntilDone: true)
    }
    
    
}
