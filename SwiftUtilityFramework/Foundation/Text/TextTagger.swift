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
    
    /// 给文本进行简单分词
    public static func simpleTextTag(_ text: String) -> [String] {
        var tags: [String] = []
        let range = NSRange(location: 0, length: text.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace]
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = text
        tagger.enumerateTags(in: range,
                             scheme: .tokenType,
                             options: options)
        { (tag, range, _, _) in
            tags.append((text as NSString).substring(with: range))
        }
        return tags
    }
    
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
    
    /// 分解英文句子提取详细信息，返回元素为 TextTagRangeResult 结构体，包含原始单词的位置、单词的词根、单词所在句子的范围。
    /// - 当提取的词根为 nil 时，只保留原词全部为英文字母的情况，其他情况需要忽略，如：纯数字，带标点的单词缩写:'ll 've 等。
    public static func analyzeEnglishSentence(_ sentence: String) -> [TextTagRangeResult] {
        var result: [TextTagRangeResult] = []
        let range = NSRange(location: 0, length: sentence.count)
        let options: NSLinguisticTagger.Options = [.omitPunctuation, .omitWhitespace, .omitOther, .joinNames]
        let orthography = NSOrthography(dominantScript: "Latn", languageMap: ["Latn": ["en"]])
        (sentence as NSString).enumerateLinguisticTags(in: range, scheme: .lemma, options: options, orthography: orthography) { (tag, tokenRange, sentenceRange, _) in
            let originWord = (sentence as NSString).substring(with: tokenRange)
            let resultItem = TextTagRangeResult(tagRange: tokenRange, stem: tag?.rawValue, sentenceRange: sentenceRange)
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
            /// 不同字符形式的 not 缩写，对应的 unicode 编码分别为：u0027, u2019 .
            let notCases = ["n't", "n’t"]
            if result.count >= 2 {
                // 情况1:
                let indexNeedToFixed = result.count - 2
                let previousRange = result[indexNeedToFixed].tagRange
                let previousOriginWord = (sentence as NSString).substring(with: previousRange)
                if notCases.contains(originWord) && previousOriginWord == "ca" {
                    let item = result[indexNeedToFixed]
                    result[indexNeedToFixed] = TextTagRangeResult(
                        tagRange: NSRange(location: previousRange.location, length: 3),
                        stem: "can", sentenceRange:
                        item.sentenceRange)
                }
            }
        }
        return result
    }
    
}

/// 文本分词结果类型，包含原词范围、词干、句子范围。
public struct TextTagRangeResult {
    /// 原词所在文本中的范围
    public var tagRange: NSRange
    /// 词干
    public var stem: String?
    /// 原词所在的句子范围
    public var sentenceRange: NSRange
}
