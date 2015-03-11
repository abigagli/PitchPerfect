//
//  PlayAudioViewController.swift
//  PitchPerfect
//
//  Created by Andrea Bigagli on 9/3/15.
//  Copyright (c) 2015 Andrea Bigagli. All rights reserved.
//

import UIKit
import AVFoundation

class PlayAudioViewController: UIViewController {
    
    //MARK: Stored properties
    var audioPlayer : AVAudioPlayer!
    
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
    
    
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        if let filePath = NSBundle.mainBundle().pathForResource("movie_quote", ofType: "mp3") {
            let filePathUrl = NSURL.fileURLWithPath(filePath)
            audioPlayer = AVAudioPlayer(contentsOfURL: filePathUrl, error: nil)
            audioPlayer.enableRate = true
        }
        else {
            println ("Failed loading movie_quote.mp3")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
