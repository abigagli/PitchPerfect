//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Andrea Bigagli on 8/3/15.
//  Copyright (c) 2015 Andrea Bigagli. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    
    //MARK: Actions
    @IBAction func recordAudio() {
        if let fileURL = makeFileUrl() {
            var session = AVAudioSession.sharedInstance()
            session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
            audioRecorder = AVAudioRecorder(URL: fileURL, settings: nil, error: nil)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            state = .ongoing
        }
    }

    @IBAction func stopRecording() {
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        state = .stopped
    }
    
    @IBAction func pauseAndResume() {
        if (state == .ongoing) {
            audioRecorder.pause()
            state = .paused
        }
        else {
            audioRecorder.record()
            state = .ongoing
        }
    }

    //MARK: Stored Properties
    private var audioRecorder: AVAudioRecorder!
    //private var recordedAudio: RecordedAudio!
    
    //MARK: Computed Properties
    private enum RecordingState {
        case ongoing
        case stopped
        case paused
    }
    
    private var state: RecordingState = .stopped {
        didSet {
            updateUI(oldValue)
        }
    }
    
    private func updateUI (previousState : RecordingState) {
        switch state
        {
        case .ongoing :
            infoLabel.text = "recording"
            recordButton.enabled = false
            if (previousState == .paused) {
                //When coming from the paused state, just stop all animation and blast the alpha to 1.0
                pauseButton.layer.removeAllAnimations()
                pauseButton.alpha = 1.0
            }
            else {
                UIView.animateWithDuration(0.5){self.pauseButton.alpha = 1.0}
            }
            
            UIView.animateWithDuration(0.5){self.stopButton.alpha = 1.0}
        case .stopped:
            recordButton.enabled = true
            pauseButton.layer.removeAllAnimations()
            UIView.animateWithDuration(0.5){self.stopButton.alpha = 0}
            UIView.animateWithDuration(0.5){self.pauseButton.alpha = 0}
        case .paused:
            infoLabel.text = "paused"
            UIView.animateWithDuration(0.5, delay: 0, options: .AllowUserInteraction | .Repeat | .Autoreverse, animations: {self.pauseButton.alpha = 0.1}, completion: nil)
        }
    }
    
    
    
    //MARK: ViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.alpha = 0
        pauseButton.alpha = 0
        state = .stopped
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //As suggested in code review, set the label to "Tap to record" during viewWillAppear ONLY, and not everytime state becomes ".stopped"
        infoLabel.text = "Tap to record"
        state = .stopped
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundVC = segue.destinationViewController as! PlayAudioViewController
            playSoundVC.receivedAudio = sender as! RecordedAudio
        }
    }
    
    
    //MARK: AVAudioRecorder Delegate
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {
            var recordedAudio = RecordedAudio(filePathURL: recorder.url, title: recorder.url.lastPathComponent!)
            
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
        else {
            println ("Recording FAILED")
        }
        
        state = .stopped
    }
    
    //MARK: Business Logic
    private func makeFileUrl() -> NSURL? {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let currentDateTime = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = dateFormatter.stringFromDate(currentDateTime) + ".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        return filePath
    }

}

