//
//  RecordedAudio.swift
//  PitchPerfect
//
//  Created by Andrea Bigagli on 11/3/15.
//  Copyright (c) 2015 Andrea Bigagli. All rights reserved.
//

import Foundation

class RecordedAudio : NSObject {
    var filePathURL : NSURL
    var title : String
    
    init (filePathURL fpURL: NSURL, title t: String) {
        filePathURL = fpURL
        title = t
    }
    
    
}
