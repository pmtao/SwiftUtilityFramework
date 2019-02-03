//
//  TextTagger.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/1/18.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation
import NaturalLanguage

public class TextTagger {
    
    public static func decideTextLanguage(_ text: String) -> String {
        if #available(iOS 12.0, *) {
            let recog = NLLanguageRecognizer()
            recog.processString(text)
            guard let language = recog.dominantLanguage else {
                return ""
            }
            return language.rawValue
        } else {
            let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
            tagger.string = text
            guard let tag = tagger.tag(at: 0, scheme: .language, tokenRange: nil, sentenceRange: nil) else {
                return ""
            }
            return tag.rawValue
        }
    }
    
    public static func englishWordDetect(_ word: String) -> Bool {
        let englishChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-' "
        let englishCharSet = CharacterSet(charactersIn: englishChars)
        let wordSet = CharacterSet(charactersIn: word)
        if wordSet.isSubset(of: englishCharSet) {
            return true
        } else {
            return false
        }
    }
    
    
    
}
