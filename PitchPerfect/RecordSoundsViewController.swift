//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Andrea Bigagli on 8/3/15.
//  Copyright (c) 2015 Andrea Bigagli. All rights reserved.
//

import UIKit

class RecordSoundsViewController: UIViewController {
    
    //MARK: Computed Properties
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
    private func updateState ()
    {
        stopButton.hidden = (state == .stopped)
        recordingInProgress.hidden = (state == .stopped)
        recordButton.enabled = (state == .stopped)
    }

    //MARK: Outlets
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    
    //MARK: Actions
    @IBAction func recordAudio(sender: UIButton) {
        state = .ongoing
    }

    @IBAction func stopRecording(sender: UIButton) {
        state = .stopped
    }
    
    
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        state = .stopped
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        state = .stopped
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

