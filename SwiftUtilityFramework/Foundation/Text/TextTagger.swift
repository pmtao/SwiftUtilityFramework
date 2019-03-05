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
        var lemmas: [String?] = []
        var originWords: [String] = []
        let range = NSRange(location: 0, length: sentence.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        let orthography = NSOrthography(dominantScript: "Latn", languageMap: ["Latn": ["en"]])
        (sentence as NSString).enumerateLinguisticTags(in: range, scheme: .lemma, options: options, orthography: orthography) { (tag, tokenRange, sentenceRange, _) in
            let originWord = (sentence as NSString).substring(with: tokenRange)
            lemmas.append(tag?.rawValue)
            originWords.append(originWord)
            // 结果修正
            // 解决分词可能存在的问题。
            // 情况1: 如 can't 分词时，被拆分为: 'ca', 'n't'，正确的应该是: 'can', 'n't'.
            if lemmas.count >= 2 {
                // 情况1:
                let indexNeedToFixed = lemmas.count - 2
                if originWord == "n't" && originWords[indexNeedToFixed] == "ca" {
                    var newItem = lemmas[indexNeedToFixed]
                    newItem = "can"
                    lemmas[indexNeedToFixed] = newItem
                }
            }
        }
        
        return lemmas.filter { $0 != nil } as! [String] // 去除结果不为 nil 的项
    }
    
    /// 分解英文句子提取详细信息，返回为元组类型的数组，元组中依次为原始单词、单词的词根、单词所在句子的范围。
    /// - 当提取的词根为 nil 时，只保留原词全部为英文字母的情况，其他情况需要忽略，如：纯数字，带标点的单词缩写:'ll 've 等。
    public static func analyzeEnglishSentence(_ sentence: String) -> [(String, String?, NSRange)] {
        var result: [(String, String?, NSRange)] = []
        let range = NSRange(location: 0, length: sentence.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther, .joinNames]
        let orthography = NSOrthography(dominantScript: "Latn", languageMap: ["Latn": ["en"]])
        (sentence as NSString).enumerateLinguisticTags(in: range, scheme: .lemma, options: options, orthography: orthography) { (tag, tokenRange, sentenceRange, _) in
            let originWord = (sentence as NSString).substring(with: tokenRange)
            let resultItem = (originWord, tag?.rawValue, sentenceRange)
            if tag == nil {
                // 词根为空时的处理
                let letterCharSet = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
                let wordSet = CharacterSet(charactersIn: originWord)
                if wordSet.isSubset(of: letterCharSet) {
                    result.append(resultItem)
                }
            } else {
                result.append(resultItem)
            }
            // 结果修正
            // 解决分词可能存在的问题。
            // 情况1: 如 can't 分词时，被拆分为: 'ca', 'n't'，正确的应该是: 'can', 'n't'.
            if result.count >= 2 {
                // 情况1:
                let indexNeedToFixed = result.count - 2
                if originWord == "n't" && result[indexNeedToFixed].0 == "ca" {
                    let item = result[indexNeedToFixed]
                    result[indexNeedToFixed] = ("can", "can", item.2)
                }
            }
        }
        return result
    }
    
}
