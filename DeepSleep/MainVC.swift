//
//  MainVC.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/23.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

private let animationKey = "ImageRotationAnimation"

class MainVC: BaseVC {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var slider: ThinTrackSlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var modeBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var unfoldBtn: UIButton!
    
    fileprivate var sliderIsSliding: Bool = false
    fileprivate var data: [AudioItem]!
    fileprivate var categories: [AudioCategory]!
    
    lazy var imageAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.toValue = Double.pi*2
        animation.duration = 10
        animation.autoreverses = false
        animation.fillMode = .forwards
        animation.repeatCount = MAXFLOAT
        return animation
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        slider.setThumbImage(UIImage(named: "dot_nor"), for: .normal)
        //slider.setThumbImage(UIImage(named: "dot_disable"), for: .disabled)
        slider.setThumbImage(UIImage(named: "dot_sel"), for: .highlighted)

        let path = Bundle.main.path(forResource: "category", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        do {
            let json = try Data(contentsOf: url)
            let categories = try JSONDecoder().decode([AudioCategory].self, from: json)
            guard let category = categories.first else { return }
            data = category.musics
            self.categories = categories
        } catch {
            print(error)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        AVPlayerManager.share.delegate = self
        AVPlayerManager.share.audioItems = data
        AVPlayerManager.share.play(audioItem: data[0])
        
        unfoldBtn.setTitle(categories.first?.name ?? "选择分类", for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        imageView.layer.add(imageAnimation, forKey: animationKey)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        imageView.layer.removeAnimation(forKey: animationKey)
    }
    
    @objc
    func appDidEnterBackground() {
        imageView.layer.removeAnimation(forKey: animationKey)
    }
    
    @objc
    func appWillEnterForeground() {
        imageView.layer.add(imageAnimation, forKey: animationKey)
    }
    
    @IBAction func onUnfoldBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MusicTypeVC") as! MusicTypeVC
        vc.categories = categories
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = TestObject.share
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func slideDidEnd(_ sender: ThinTrackSlider) {
        AVPlayerManager.share.update(progress: sender.value)
    }
    
    @IBAction func sliderValueDidChange(_ sender: ThinTrackSlider) {
        sliderIsSliding = true
        guard let playerItem = AVPlayerManager.share.player.currentItem else { return }
        let totalSeconds = CMTimeGetSeconds(playerItem.duration)
        let currentSeconds = totalSeconds * TimeInterval(sender.value)
        currentTimeLabel.text = timeConverted(fromSeconds: currentSeconds)
    }
    
    @IBAction func onModeBtn(_ sender: UIButton) {
        AVPlayerManager.share.resetPlayMode()
    }
    
    @IBAction func onPreviousBtn(_ sender: UIButton) {
        AVPlayerManager.share.playPreviousItem()
    }
    
    @IBAction func onPlayPauseBtn(_ sender: UIButton) {
        if sender.isSelected {
            AVPlayerManager.share.pause()
        }else{
            AVPlayerManager.share.play()
        }
    }
    
    @IBAction func onNextBtn(_ sender: UIButton) {
        AVPlayerManager.share.playNextItem()
    }
    
    @IBAction func onListBtn(_ sender: UIButton) {
        /*
         To present a view controller using custom animations, do the following in an action method of your existing view controllers:

         1. Create the view controller that you want to present.
         2. Create your custom transitioning delegate object and assign it to the view controller’s transitioningDelegate property. The methods of your transitioning delegate should create and return your custom animator objects when asked.
         3. Call the presentViewController:animated:completion: method to present the view controller.
         */
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MusicListVC") as! MusicListVC
        vc.data = data
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc.presentationDelegate
        present(vc, animated: true, completion: nil)
    }
    
    func timeConverted(fromSeconds seconds: TimeInterval) -> String {
        let sec = Int(seconds)
        if sec >= 0 && sec < 10 {
            return "00:0\(sec)"
        }else if sec >= 10 && sec < 60{
            return "00:\(sec)"
        }else if sec >= 60 && sec < 600{
            return "0\(sec/60):\(timeConverted(fromSeconds: TimeInterval(sec%60)).suffix(2))"
        }else if sec >= 600 && sec < 3600{
            return "\(sec/60):\(timeConverted(fromSeconds: TimeInterval(sec%60)).suffix(2))"
        }else{
            return "too long"
        }
    }
    
    func startRotationAnimation() {
        let pausedTime = imageView.layer.timeOffset
        imageView.layer.speed = 1.0
        imageView.layer.timeOffset = 0.0
        imageView.layer.beginTime = 0.0
        let timeSincePause = imageView.layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        imageView.layer.beginTime = timeSincePause
    }
    
    func stopRotationAnimation() {
        print("stopRotationAnimation")
        let pausedTime = imageView.layer.convertTime(CACurrentMediaTime(), from: nil)
        imageView.layer.speed = 0.0
        imageView.layer.timeOffset = pausedTime
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainVC: PlayerUIDelegate{
    func playerReadyToPlay(withDuration duration: TimeInterval) {
        print("playerReadyToPlay")
        slider.isUserInteractionEnabled = true // slider.isEnabled = true
        totalTimeLabel.text = timeConverted(fromSeconds: duration)
    }
    
    func playerDidLoad(toProgress progress: TimeInterval) {
        print(progress)
       
    }
    
    func playerDidPlay(toTime: TimeInterval, totalTime: TimeInterval) {
        if !sliderIsSliding {
            currentTimeLabel.text = timeConverted(fromSeconds: toTime)
        }
        
    }
    
    func playerDidPlay(toProgress progress: Float){
        if !sliderIsSliding {
            slider.setValue(progress, animated: false)
        }
    }
    
    func playbackBufferEmpty(_ bufferEmpty: Bool) {
        print("playerPlaybackBufferEmpty = \(bufferEmpty)")
        if bufferEmpty {
            slider.showIndicator()
        }
    }
    
    func playbackLikelyToKeepUp(_ likelyToKeepUp: Bool) {
        print("playerPlaybackLikelyToKeepUp = \(likelyToKeepUp)")
        if likelyToKeepUp {
            slider.hideIndicator()
        }else{
            slider.showIndicator()
        }
    }
    
    func playbackBufferFull(_ bufferFull: Bool) {
        print("playbackBufferFull = \(bufferFull)")
    }
    
    func playerDidFinishPlaying() {
        print("playerDidFinishPlaying")
    }
    
    func playerDidFailToPlay() {
        print("playerDidFailToPlay")
    }
    
    func playerDidEndSeeking() {
        sliderIsSliding = false
    }
    
    func playerModeDidChange(toMode mode: AudioPlayMode) {
        switch mode {
        case .listLoop:
            modeBtn.setImage(UIImage(named: "list_loop"), for: .normal)
        case .listRandom:
            modeBtn.setImage(UIImage(named: "list_random"), for: .normal)
        default:
            modeBtn.setImage(UIImage(named: "single_loop"), for: .normal)
        }
    }
    
    func playerItemDidChange(toItem item: AudioItem?) {
        if let playingItem = item {
            nameLabel.text = playingItem.name
            currentTimeLabel.text = "00:00"
            totalTimeLabel.text = "--:--"
            imageView.kf.setImage(with: URL(string: playingItem.image_url))
            NotificationCenter.default.post(name: NSNotification.Name.App.PlayItemDidChange, object: nil)
        }
    }
    
    func playerTimeControlStatusDidChange(toStatus status: AVPlayer.TimeControlStatus){
        switch status {
        case .paused:
            print("AVPlayer.TimeControlStatus.paused")
            playBtn.isSelected = false
            slider.hideIndicator()
            stopRotationAnimation()
        case .playing:
            print("AVPlayer.TimeControlStatus.playing")
            playBtn.isSelected = true
            slider.hideIndicator()
            startRotationAnimation()
        default:
            print("AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate")
            stopRotationAnimation()
            slider.showIndicator()
            
            guard let reason = AVPlayerManager.share.player.reasonForWaitingToPlay else { return }
            switch reason {
            case .toMinimizeStalls:
                //Indicates that the player is waiting for appropriate playback buffer conditions before starting playback
                print("toMinimizeStalls")
                break
            case .noItemToPlay:
                //Indicates that the AVPlayer is waiting because its currentItem is nil
                slider.isUserInteractionEnabled = false//slider.isEnabled = false
                print("noItemToPlay")
                break
            case .evaluatingBufferingRate:
                print("evaluatingBufferingRate")
                break
            default:
                break
            }
            
            break
        }
    }
    
    func playerItemsDidChange(items: [AudioItem]) {
        data = items
    }
    
}




