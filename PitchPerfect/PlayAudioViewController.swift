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
        stopButton.hidden = (state == .stopped)
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
        state = .stopped
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
    }
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathURL, error: nil)
        audioPlayer.delegate = self
        audioPlayer.enableRate = true
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
        audioPlayer.stop()
        if (fromBeginning) {
            audioPlayer.currentTime = 0
        }
        audioPlayer.rate = rate
        audioPlayer.play()
        state = .ongoing
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
