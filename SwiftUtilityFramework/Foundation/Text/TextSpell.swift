//
//  TextSpell.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/1/18.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation

public class TextSpell {
    
    /// 根据输入的文本给出完整的单词建议，包含多个可能的建议，输出全部为小写。
    public static func getTextSpellSuggestion(_ text: String) -> [String] {
        guard text.isEmpty == false else { return [] }
        let textChecker = UITextChecker()
        var suggestions = [String]()
        let range = NSMakeRange(0, text.count)
        
        /// 搜集 UITextChecker 提供的所有建议项
        for language in NSLocale.preferredLanguages {
            guard let completions = textChecker.completions(forPartialWordRange: range,
                                                            in: text,
                                                            language: language)
                else { continue }
            suggestions.append(contentsOf: completions)
        }
        
        // 将输入单词的词根加入拼写建议中
        suggestions = suggestions.map {$0.lowercased() }
        let textLemmas = TextTagger.getEnglishSentenceLemma(text)
        if textLemmas.isEmpty == false {
            let lemma = textLemmas[0].lowercased()
            if suggestions.contains(lemma) == false {
                suggestions.insert(textLemmas[0], at: 0)
            }
        }
        
        // 对建议项进行排序，排序依据：按字母表顺序，顺序小的排在前面，如 at 在 but 前面；如果一个单词前半部分包含另一个单词，长度短的排在前面，如 go 在 good 前面。
        suggestions.sort { (wordOne, wordTwo) -> Bool in
            let countOne = wordOne.count
            let countTwo = wordTwo.count
            let minCount = countOne < countTwo ? countOne : countTwo
            for index in 0..<minCount {
                let charOne = wordOne[wordOne.index(wordOne.startIndex, offsetBy: index)]
                let charTwo = wordTwo[wordTwo.index(wordTwo.startIndex, offsetBy: index)]
                if  charOne < charTwo {
                    return true
                }
                if  charOne > charTwo {
                    return false
                }
            }
            if countOne < countTwo {
                return true
            } else {
                return false
            }
        }
        return suggestions
    }
    
    
}
