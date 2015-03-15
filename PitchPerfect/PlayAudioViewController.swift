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
    
    //MARK: Stored properties
    private var audioPlayer : AVAudioPlayer!
    private var audioEngine : AVAudioEngine!
    private var audioFile : AVAudioFile!
    
    //Needed to work-around what seems to be a "quirk" (or a bug) in the way AVAudioPlayerNode's
    //completion handler behaves: it seems to fire at least 2-3 seconds after the sound really stopped
    //playing, so it's not really good as a mean to automatically hide the stop button.
    //Resorting to an NSTimer-based solution instead, as read on SO
    private var hideStopTimer : NSTimer!
    
    var receivedAudio : RecordedAudio!
    
    //MARK: Computed properties
    private enum PlayingState
    {
        case ongoing
        case stopped
    }
    private var state : PlayingState = .stopped {
        didSet {
            updateState()
        }
    }
    private func updateState ()
    {
        //The logic is simple: stopButton.hidden = (state == .stopped)
        //but since I want to use animations, it's clearer to use an explicit switch 
        //that calls 2 separate functions
        
        switch state{
        case .ongoing:
            showStopButton()
        case .stopped:
            hideStopButton()
        }
    }


    //MARK: Outlets
    @IBOutlet weak var stopButton: UIButton!
    
    //MARK: Actions
    @IBAction func fastPlay(sender: UIButton) {
        playSoundWithRate(1.5)
    }

    @IBAction func slowPlay(sender: UIButton) {
        playSoundWithRate(0.5)
    }
    
    @IBAction func stopPlaying(sender: UIButton) {
        audioPlayer.stop()
        audioEngine.stop()
        hideStopTimer?.invalidate()
        state = .stopped
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playSoundWithPitch(1000)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playSoundWithPitch(-1000)
    }
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathURL, error: nil)
        audioPlayer.delegate = self
        audioPlayer.enableRate = true
        
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathURL, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        state = .stopped
    }
    
    //MARK: AVAudioPlayer Delegate
    
    func audioPlayerDidFinishPlaying(_: AVAudioPlayer!, successfully _: Bool) {
        state = .stopped
    }
    
    //MARK: Business Logic
    private func playSoundWithRate(rate : Float, fromBeginning : Bool = true) {
        hideStopTimer?.invalidate()
        audioPlayer.stop()
        if (fromBeginning) {
            audioPlayer.currentTime = 0
        }
        audioPlayer.rate = rate
        audioPlayer.play()
        state = .ongoing
    }
    
    private func playSoundWithPitch(pitch : Float)
    {
        hideStopTimer?.invalidate()
        audioPlayer.stop()
        
        audioEngine.stop()
        audioEngine.reset()
        
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
            
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
        state = .ongoing
        
        //This is kind of a kludge, but read the comments about hideStopTimer for a rationale
        if (audioPlayerNode.playing)
        {
            hideStopTimer?.invalidate()
            hideStopTimer = NSTimer.scheduledTimerWithTimeInterval(audioPlayer.duration, target: self, selector: "hideStopButton", userInfo: nil, repeats: false)
        }
    }
    
    private func showStopButton()
    {
        stopButton.hidden = false
    }
    
    func hideStopButton() //Can't make this private as that prevents it being usable as a selector in NSTimer's scheduledTimerWithTimeInterval
    {
        stopButton.hidden = true
    }
    // MARK: - Navigation
/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let s = segue;
    }
*/
}
