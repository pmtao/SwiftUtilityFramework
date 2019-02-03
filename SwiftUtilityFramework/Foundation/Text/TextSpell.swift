//
//  TextSpell.swift
//  SwiftUtilityFramework
//
//  Created by Meler Paine on 2019/1/18.
//  Copyright © 2019 SinkingSoul. All rights reserved.
//

import Foundation

public class TextSpell {
    
    public static func getTextSpellSuggestion(_ text: String) -> [String] {
        let textChecker = UITextChecker()
        var suggestions = [String]()
        let range = NSMakeRange(0, text.count)
        
        for language in NSLocale.preferredLanguages {
            guard let completions = textChecker.completions(forPartialWordRange: range,
                                                            in: text,
                                                            language: language)
                else { continue }
            suggestions.append(contentsOf: completions)
        }
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
