//
//  PlayAudioViewController.swift
//  PitchPerfect
//
//  Created by Andrea Bigagli on 9/3/15.
//  Copyright (c) 2015 Andrea Bigagli. All rights reserved.
//

import UIKit
import AVFoundation

class PlayAudioViewController: UIViewController, AVAudioPlayerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var stopButton: UIButton!
    
    //MARK: Actions
    @IBAction func fastPlay() {
        playSoundWithRate(1.5)
    }

    @IBAction func slowPlay() {
        playSoundWithRate(0.5)
    }
    
    @IBAction func stopPlaying() {
        stopAllAudio()
        state = .stopped
    }
    
    @IBAction func playChipmunkAudio() {
        playSoundWithEffect {
            let changePitchEffect = AVAudioUnitTimePitch()
            changePitchEffect.pitch = 1000
            return changePitchEffect
        }
    }
    
    @IBAction func playDarthvaderAudio() {
        playSoundWithEffect {
            let changePitchEffect = AVAudioUnitTimePitch()
            changePitchEffect.pitch = -1000
            return changePitchEffect
        }
    }
    
    @IBAction func playReverbAudio() {
        playSoundWithEffect {
            let reverbEffect = AVAudioUnitReverb()
            reverbEffect.wetDryMix = 100
            return reverbEffect
            }
    }
    
    @IBAction func playEchoedAudio() {
        playSoundWithEffect {
            let delayEffect = AVAudioUnitDelay()
            delayEffect.delayTime = NSTimeInterval(1)
            return delayEffect
            }
    }

    //MARK: Stored properties
    private var audioPlayer: AVAudioPlayer!
    private var audioEngine: AVAudioEngine!
    private var audioFile: AVAudioFile!
    
    //Needed to work-around what seems to be a "quirk" (or a bug) in the way AVAudioPlayerNode's
    //completion handler behaves: it seems to fire at least 2-3 seconds after the sound really stopped
    //playing, so it's not really good as a mean to automatically hide the stop button.
    //Resorting to an NSTimer-based solution instead, as read on SO
    //NOTE: Unfortunately this doesn't completely work with the ECHO effect as the duration considered for the timer is the "nominal" duration of the file, i.e. not considering the echo tails, so that the button will disappear but the echo tails will still be playing for a while unless you navigate back to the recording VC, in which case the stopAllAudio call will shut down everything
    private var hideStopTimer: NSTimer!
    
    var receivedAudio: RecordedAudio!
    
    //MARK: Computed properties
    private enum PlayingState {
        case ongoing
        case stopped
    }
    
    private var state: PlayingState = .stopped {
        didSet {
            updateUI()
        }
    }
    private func updateUI () {
        
        switch state {
        case .ongoing:
            showStopButton()
        case .stopped:
            hideStopButton()
        }
    }


    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathURL)
        audioPlayer.delegate = self
        audioPlayer.enableRate = true
        
        audioEngine = AVAudioEngine()
        audioFile = try? AVAudioFile(forReading: receivedAudio.filePathURL)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        stopButton.alpha = 0
        state = .stopped
    }
    
    override func viewDidDisappear (animated: Bool) {
        super.viewDidDisappear(animated)
        
        //Remove the audio file
        let fileManager = NSFileManager.defaultManager()
        var err: NSError?
        
        do {
            try fileManager.removeItemAtURL(receivedAudio.filePathURL)
        } catch let error as NSError {
            err = error
            print("Failed removing \(receivedAudio.filePathURL): \(err!.localizedDescription)")
        }
        
        stopAllAudio()
    }
    
    //MARK: AVAudioPlayer Delegate
    
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully _: Bool) {
        state = .stopped
    }
    
    //MARK: Business Logic
    private func playSoundWithRate(rate: Float, fromBeginning: Bool = true) {
        stopAllAudio()
        
        if (fromBeginning) {
            audioPlayer.currentTime = 0
        }
        
        audioPlayer.volume = 1.0
        audioPlayer.rate = rate
        audioPlayer.play()
        
        state = .ongoing
    }
    
    private func playSoundWithEffect (configuredEffect: ()->AVAudioUnit) {
        stopAllAudio()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let effect = configuredEffect()
        
        audioEngine.attachNode(effect)
        
        audioEngine.connect(audioPlayerNode, to: effect, format: nil)
        audioEngine.connect(effect, to: audioEngine.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
            
        do {
            try audioEngine.start()
        } catch _ {
        }
        audioPlayerNode.volume = 1.0
        audioPlayerNode.play()
        state = .ongoing
        
        //This is kind of a kludge, but read the comments about hideStopTimer for a rationale
        if (audioPlayerNode.playing) {
            hideStopTimer?.invalidate()
            hideStopTimer = NSTimer.scheduledTimerWithTimeInterval(audioPlayer.duration, target: self, selector: #selector(PlayAudioViewController.hideStopButton), userInfo: nil, repeats: false)
        }
        
    }

    //Ensure we get really mute (i.e. sound and echo tails will stop)
    private func stopAllAudio()
    {
        hideStopTimer?.invalidate()
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    private func showStopButton() {
        UIView.animateWithDuration(0.5){self.stopButton.alpha = 1.0}
    }
    
    //Can't make this private as that prevents it being usable as a selector in NSTimer's scheduledTimerWithTimeInterval
    func hideStopButton() {
        UIView.animateWithDuration(0.5){self.stopButton.alpha = 0}
    }
}
