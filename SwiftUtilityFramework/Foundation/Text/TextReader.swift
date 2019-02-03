//
//  TextReader.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/1/18.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation
import Speech

public class TextReader {
    
    public static func readText(_ text: String) {
        let textLanguage = TextTagger.decideTextLanguage(text)
        let isEnglishWord = TextTagger.englishWordDetect(text)
        let voices = AVSpeechSynthesisVoice.speechVoices()
        let syntesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        var zh_voices:[AVSpeechSynthesisVoice] = []
        var enGB_voices:[AVSpeechSynthesisVoice] = []
        
        for voice in voices {
            if voice.language == "en-GB" && voice.name.hasPrefix("Daniel") {
                enGB_voices.append(voice)
            }
            if voice.language.hasPrefix("zh") {
                zh_voices.append(voice)
            }
        }
        
        var speechVoice = AVSpeechSynthesisVoice()
        if isEnglishWord {
            speechVoice = enGB_voices[0]
        }
        if textLanguage.hasPrefix("zh") {
            speechVoice = zh_voices[0]
        }
        
        utterance.voice = speechVoice
        utterance.rate = 0.5;
        syntesizer.speak(utterance)
    }
    
    
    
}
