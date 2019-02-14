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
    
    /// 提取英文句子中所有单词的词根
    public static func getEnglishSentenceLemma(_ sentence: String) -> [String] {
        var lemmas: [String] = []
        let range = NSRange(location: 0, length: sentence.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        let orthography = NSOrthography(dominantScript: "Latn", languageMap: ["Latn": ["en"]])
        (sentence as NSString).enumerateLinguisticTags(in: range, scheme: .lemma, options: options, orthography: orthography) { (tag, tokenRange, sentenceRange, _) in
            if let lemma = tag?.rawValue {
                lemmas.append(lemma)
            }
        }
        return lemmas
    }
    
}
