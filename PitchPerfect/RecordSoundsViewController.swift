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
    
    //MARK: Stored Properties
    private var audioRecorder : AVAudioRecorder!
    private var recordedAudio : RecordedAudio!
    
    //MARK: Computed Properties
    private enum RecordingState {
        case ongoing
        case stopped
    }
    
    private var state : RecordingState = .stopped {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI () {
        switch state
        {
        case .ongoing :
            infoLabel.text = "recording"
            UIView.animateWithDuration(0.5){self.stopButton.alpha = 1.0}
        case .stopped:
            infoLabel.text = "Tap to record"
            recordButton.enabled = true
            UIView.animateWithDuration(0.5){self.stopButton.alpha = 0}
        }
    }

    //MARK: Outlets
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    
    //MARK: Actions
    @IBAction func recordAudio(sender: UIButton) {
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

    @IBAction func stopRecording(sender: UIButton) {
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
        state = .stopped
    }
    
    
    
    //MARK: ViewController Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopButton.alpha = 0
        state = .stopped
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        state = .stopped
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundVC = segue.destinationViewController as PlayAudioViewController
            playSoundVC.receivedAudio = sender as RecordedAudio
        }
    }
    
    
    //MARK: AVAudioRecorder Delegate
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {
            recordedAudio = RecordedAudio(filePathURL: recorder.url, title: recorder.url.lastPathComponent!)
            
            performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
        else {
            println ("Recording FAILED")
        }
        
        state = .stopped
    }
    
    //MARK: Business Logic
    private func makeFileUrl() -> NSURL? {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let currentDateTime = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy-HHmmss"
        let recordingName = dateFormatter.stringFromDate(currentDateTime) + ".wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        return filePath
    }

}

