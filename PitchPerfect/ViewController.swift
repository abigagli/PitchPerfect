//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Andrea Bigagli on 8/3/15.
//  Copyright (c) 2015 Andrea Bigagli. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private enum RecordingState
    {
        case ongoing
        case stopped
    }
    
    private var state : RecordingState = .stopped {
        didSet {
            updateState()
        }
    }

    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    private func updateState ()
    {
        stopButton.hidden = (state == .stopped)
        recordingInProgress.hidden = (state == .stopped)
        recordButton.enabled = (state == .stopped)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        state = .stopped
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        state = .stopped
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordAudio(sender: UIButton) {
        state = .ongoing
    }

    @IBAction func stopRecording(sender: UIButton) {
        state = .stopped
    }
}

