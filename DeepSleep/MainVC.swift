//
//  MainVC.swift
//  DeepSleep
//
//  Created by xinguang hu on 2020/3/23.
//  Copyright © 2020 wy. All rights reserved.
//

import UIKit
import AVFoundation

class MainVC: BaseVC {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var slider: ThinTrackSlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var modeBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    var sliderIsSliding: Bool = false
    var data: [AudioItem]!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sunshine girl"
        
        slider.setThumbImage(UIImage(named: "dot_nor"), for: .normal)
        slider.setThumbImage(UIImage(named: "dot_sel"), for: .highlighted)
        
        let path = Bundle.main.path(forResource: "music", ofType: "json")
        let url = URL(fileURLWithPath: path!)
        do {
            let json = try Data(contentsOf: url)
            let jsonData = try JSONSerialization.jsonObject(with: json, options: .mutableContainers)
            if let data = jsonData as? NSDictionary,let musics = data["data"] as? NSArray {
                var items = [AudioItem]()
                for music in musics {
                    if let dic = music as? NSDictionary {
                        let item = AudioItem(fromDictionary: dic)
                        items.append(item)
                    }
                }
                self.data = items
            }
            
        } catch {
            print(error)
        }
        
        AVPlayerManager.share.delegate = self
        AVPlayerManager.share.audioItems = data
        AVPlayerManager.share.play(audioItem: data[0])
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func onUnfoldBtn(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "MusicTypeVC")
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = TestObject.share
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func slideDidEnd(_ sender: ThinTrackSlider) {
        AVPlayerManager.share.update(progress: sender.value)
    }
    
    @IBAction func sliderValueDidChange(_ sender: ThinTrackSlider) {
        sliderIsSliding = true
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
        sender.isSelected = !sender.isSelected
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
        let vc = storyboard.instantiateViewController(withIdentifier: "MusicListVC")
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = vc.presentationDelegate
        present(vc, animated: true, completion: nil)
    }
    
    func timeConverted(fromSeconds seconds: Float64) -> String {
        let sec = Int(seconds)
        if sec >= 0 && sec < 10 {
            return "00:0\(sec)"
        }else if sec >= 10 && sec < 60{
            return "00:\(sec)"
        }else if sec >= 60 && sec < 600{
            return "0\(sec/60):\(timeConverted(fromSeconds: Float64(sec%60)).suffix(2))"
        }else if sec >= 600 && sec < 3600{
            return "\(sec/60):\(timeConverted(fromSeconds: Float64(sec%60)).suffix(2))"
        }else{
            return "too long"
        }
        
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
    
    func playerReadyToPlay() {
        print("playerReadyToPlay")
    }
    
    func playerDidLoad(toProgress progress: Float64) {
        
    }
    
    func playerDidPlay(toTime: Float64, totalTime: Float64) {
        print(toTime,totalTime)
        currentTimeLabel.text = timeConverted(fromSeconds: toTime)
        totalTimeLabel.text = timeConverted(fromSeconds: totalTime)
    }
    
    func playerDidPlay(toProgress progress: Float){
        if !sliderIsSliding {
            slider.setValue(progress, animated: false)
        }
    }
    
    func playerPlaybackBufferEmpty() {
        print("playerPlaybackBufferEmpty")
    }
    
    func playerPlaybackLikelyToKeepUp() {
        print("playerPlaybackLikelyToKeepUp")
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
        }
    }
    
}




