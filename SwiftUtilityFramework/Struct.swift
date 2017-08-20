//
//  Struct.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 17-8-18.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import UIKit


/// 调度场算法
public struct SUF_ShuntingYard {
    
    
    /// 调度场转换算法：将中缀形式的数学表达式转换为后缀表达式（逆波兰表示法 RPN）
    ///
    /// - Parameter exp: 待转换的表达式
    public static func ShuntingYardTransform(exp: String) -> Queue<String> {
        /// 先将表达式解析为队列（已进行内部运算符号系统转换）
        var expQueue = SUF_MathAnalyze.analyzeMathExpression(expression: exp)
        var symbolStack = Stack<String>() // 符号栈
        var resultQueue = Queue<String>() //输出队列
        
        // 循环处理表达式队列
        while !((expQueue?.isEmpty)!) {
            // 从表达式队列中推出一个元素进行分析
            let expUnit = (expQueue?.dequeue())!
            // 队列元素的类型
            let type = SUF_MathAnalyze.checkSymbolType(symbol: expUnit[expUnit.startIndex])
            
            //根据符号类型进行处理
            switch type {
            case .number:
                resultQueue.enqueue(expUnit)
            case .plus, .minus, .multiply, .divide,.square, .sin, .cos:
//                如果队列中取出的元素表示一个操作符，记做o1，那么：
//                只要存在另一个记为o2的操作符（注意如果是括号，则无需比较直接压栈）位于栈的顶端，并且
//                        如果o1是左结合性的并且它的运算符优先级要小于或者等于o2的优先级，或者
//                        如果o1是右结合性的并且它的运算符优先级比o2的要低，那么
//                    将o2从栈的顶端弹出并且放入输出队列中（循环直至以上条件不满足为止）；
//                然后，将o1压入栈的顶端。
                
                var peek = symbolStack.peek
                // 只要符号栈顶有操作符，就要与队列中取出的操作符进行比较并操作。
                while peek != nil {
                    let type = SUF_MathAnalyze.checkSymbolType(symbol: Character(peek!))
                    //如果栈顶的符号是括号，直接将操作符压栈后该循环就结束了
                    if type == .leftParenthesis || type == .rightParenthesis {
                        symbolStack.push(expUnit)
                        break
                    }
                    
                    // 判断该元素符号的优先级、左右结合性
                    let unitLevel = (SUF_MathAnalyze.internalSymbols[expUnit])!["level"] as! Int
                    let stacklevel = (SUF_MathAnalyze.internalSymbols[peek!])!["level"] as! Int
                    let association = (SUF_MathAnalyze.internalSymbols[expUnit])!["association"] as! String
                    
                    if association == "left" && unitLevel <= stacklevel {
                        resultQueue.enqueue((symbolStack.pop())!)
                    } else if association == "right" && unitLevel < stacklevel {
                        resultQueue.enqueue((symbolStack.pop())!)
                    } else {
                        symbolStack.push(expUnit)
                        break //操作符压栈后该循环就结束了
                    }
                    
                    // 再次读取栈顶符号，用于下次循环判断
                    peek = symbolStack.peek
                }
                
                // 栈内无元素时直接压栈
                if peek == nil {
                    symbolStack.push(expUnit)
                }
            case .leftParenthesis:
                // 如果这个记号是一个左括号，那么就将其压入栈当中。
                symbolStack.push(expUnit)
            case .rightParenthesis:
                /*  如果这个记号是一个右括号，那么：
                                    从栈当中不断地弹出操作符并且放入输出队列中，直到栈顶部的元素为左括号为止。
                                    将左括号从栈的顶端弹出，但并不放入输出队列中去。
                                    如果此时位于栈顶端的记号表示一个函数，那么将其弹出并放入输出队列中去。(暂不含函数情况)
                                    如果在找到一个左括号之前栈就已经弹出了所有元素，那么就表示在表达式中存在不匹配的括号。*/
                var peek = symbolStack.peek
                while peek != nil && (peek!) != "("  {
                    resultQueue.enqueue((symbolStack.pop())!)
                    peek = symbolStack.peek
                }
                
                if peek != nil && (peek!) == "(" {
                    let _ = symbolStack.pop()
                    peek = symbolStack.peek 
                    if peek == nil {
                        print("表达式中存在不匹配的括号数量")
                        break // 退出 switch
                    }
                }
                
            default:
                break
            } //结束 switch
        } // 结束 while
        
        /*  如果表达式队列都已处理完
                    如果此时在栈当中还有操作符：
                    如果此时位于栈顶端的操作符是一个括号，那么就表示在表达式中存在不匹配的括号。
                    将操作符逐个弹出并放入输出队列中。*/
        if (expQueue?.isEmpty)! {
            var peek = symbolStack.peek
            while peek != nil {
                let type = SUF_MathAnalyze.checkSymbolType(symbol: Character(peek! ))
                switch type {
                case .leftParenthesis, .rightParenthesis:
                    print("表达式中存在不匹配的括号数量")
                default:
                    resultQueue.enqueue((symbolStack.pop())!)
                }
                peek = symbolStack.peek
            }
        }
        
        return resultQueue
    } // 方法结束
    
}

/// 包含各类数学符号解析转换的结构体
public struct SUF_MathAnalyze {
    /// 数学表达式中各种符号类型
    public enum mathSymbolType: String {
        case number
        case plus
        case minus
        case multiply
        case divide
        case square
        case leftParenthesis
        case rightParenthesis
        case sin
        case cos
        case undefined
    }
    
    
    /// 数学表达式无效的错误类型
    ///
    /// - undefinedSymbol: 存在未定义的符号
    /// - unmatchedParenthesis: 括号数量不匹配
    public enum invalidType: Error {
        case undefinedSymbol
        case unmatchedParenthesis
    }
    
    /// 常规数学符号与内置数学运算符号系统对应表，从 U+4E00 开始编码。
    static let symbols: [String: String] = [
        "+": "\u{4E00}", // 一
        "-": "\u{4E01}", // 丁
        "*": "\u{4E02}", // 丂
        "/": "\u{4E03}", // 七
        "×": "\u{4E02}", // 丂
        "÷": "\u{4E03}", // 七
        "(": "(",
        ")": ")",
        "sin": "\u{4E04}", // 丄
        "cos": "\u{4E05}" // 丅
    ]
    
    /// 内置数学运算符号系统相关属性
    static let internalSymbols: [String: [String: Any]] = [
        "\u{4E00}": ["literal":"+", "level": 1, "operandCount": 2, "association": "left", "type": mathSymbolType.plus],
        "\u{4E01}": ["literal":"-", "level": 1, "operandCount": 2, "association": "left", "type": mathSymbolType.minus],
        "\u{4E02}": ["literal":"×", "level": 2, "operandCount": 2, "association": "left", "type": mathSymbolType.multiply],
        "\u{4E03}": ["literal":"÷", "level": 2, "operandCount": 2, "association": "left", "type": mathSymbolType.divide],
        "(":        ["literal":"(", "level": 4, "operandCount": 0, "association": "right", "type": mathSymbolType.leftParenthesis],
        ")":        ["literal":")", "level": 4, "operandCount": 0, "association": "left", "type": mathSymbolType.rightParenthesis],
        "\u{4E04}": ["literal":"sin", "level": 3, "operandCount": 1, "association": "left", "type": mathSymbolType.sin],
        "\u{4E05}": ["literal":"cos", "level": 3, "operandCount": 1, "association": "left", "type": mathSymbolType.cos]
    ]
    
    public init() {
        
    }
    
    /// 将数学表达式进行符号系统转换，转换为内置的特殊符号
    ///
    /// - Parameter mathExpression: 要转换的数学表达式
    /// - Returns: 转换后的数学表达式
    public static func mathSymbolSystemTransition(_ mathExpression: String) -> String {
        var result = mathExpression
        result = result.replacingOccurrences(of: " ", with: "" ) // 去除空格
        for (symbol, value) in symbols {
            result = result.replacingOccurrences(of: symbol, with: value )
        }
        return result
    }
    
    
    /// 将内置符号形式的数学表达，转换成方便阅读的常规字面形式。
    ///
    /// - Parameter mathExpression: 要转换的数学表达式
    /// - Returns: 可阅读的数学表达式
    public static func mathSymbolToLiteral(_ mathExpression: String) -> String {
        var result = mathExpression
        for (symbol, value) in internalSymbols {
            result = result.replacingOccurrences(of: symbol, with: value["literal"] as! String )
        }
        return result
    }
    
    /// 检查数学符号属于哪种类型
    ///
    /// - Parameter symbol: 经过 mathSymbolSystemTransition 转换的字符
    /// - Returns: 符号类型
    public static func checkSymbolType(symbol: Character) -> mathSymbolType {
        var type: mathSymbolType = .undefined
        
        // 从 [内置数学运算符号系统] 进行查找
        if SUF_MathAnalyze.internalSymbols[String(symbol)] != nil {
            type = (SUF_MathAnalyze.internalSymbols[String(symbol)])!["type"] as! mathSymbolType
        } else if [".","0","1","2","3","4","5","6","7","8","9"].contains(symbol) {
            type = .number
        }
        return type
    }
    
    
    /// 检查数学表达式是否都是合法字符
    ///
    /// - Parameter exp: 待检查的表达式（经过 mathSymbolSystemTransition 转换）
    /// - Returns: 合法则返回空字符串；如果检查不合法，则返回不合法字符组成的字符串。
    public static func isMathExpressionValid(exp: String) throws -> String {
        var undefinedStrings = ""
        // 逐个检查字符的合法性，不合法的放入 undefinedStrings 中。
        for index in exp.characters.indices {
            let type = checkSymbolType(symbol: exp[index])
            if type == .undefined {
                undefinedStrings.append(exp[index])
                throw invalidType.undefinedSymbol
            }
        }
        
        if exp.replacingOccurrences(of: "(", with: "").characters.count !=
            exp.replacingOccurrences(of: ")", with: "").characters.count {
            throw invalidType.unmatchedParenthesis
        }
        
        
        return undefinedStrings
    }
    
    /// 检查两个字符是否属于同一数学符号类型
    ///
    /// - Parameter withString: 要检查的字符
    /// - Returns: 字符类型
    public static func compareTwoSymbolType(one: Character, two: Character) -> Bool {
        var isSameType = false
        if checkSymbolType(symbol: one) != .undefined &&
            checkSymbolType(symbol: one) == checkSymbolType(symbol: two) {
            isSameType = true
        }
        return isSameType
    }
    
    /// 解析数学表达式为数组队列
    ///
    /// - Parameter expression: 数学表达式
    public static func analyzeMathExpression(expression: String) -> Queue<String>? {
        // 经过符号系统转换的数学表达式
        let exp = mathSymbolSystemTransition(expression)
        
        // 检查输入的数学表达式是否符合要求
        let isValid = try! isMathExpressionValid(exp: exp)
        
        if !(isValid.isEmpty) {
            print("给定的数学表达式不合法：\(isValid)")
            return nil
        }
        
        var output = Queue<String>() // 输出队列
        var tempElement = "" // 临时队列元素
        
        // 逐个解析字符并放入到队列中
        for index in exp.characters.indices {
            if tempElement.isEmpty {
                tempElement.append(exp[index])
            } else {
                let one = tempElement[tempElement.index(before: tempElement.endIndex)]
                let two = exp[index]
                // 判断当前读取的字符，与[临时队列元素] 中的字符是否为同一类型。类型不同则将元素放入队列。
                if compareTwoSymbolType(one: one, two: two) {
                    tempElement.append(two)
                } else {
                    output.enqueue(tempElement)
                    tempElement = String(two)
                }
            }
        }
        
        // 将剩余元素放入队列
        if !(tempElement.isEmpty) {
            output.enqueue(tempElement)
        }
        return output
        
    }
    
}

/// 栈结构，可放入任意类型对象，后进栈的永远在栈首，后进先出，通过数组实现。
public struct Stack<Element> {
    
    /// 是否为空
    public var isEmpty: Bool { return stack.isEmpty }
    /// 栈的大小
    public var size: Int { return stack.count }
    /// 栈顶元素
    public var peek: Element? {
        return stack.last
    }
    
    private var stack: [Element]
    
    /// 构造函数
    public init() {
        stack = [Element] ()
    }
    
    /// 加入一个新元素
    public mutating func push(_ obj: Element) {
        stack.append(obj)
    }
    
    /// 推出栈顶元素
    public mutating func pop() -> Element? {
        if isEmpty {
            return nil
        } else {
            return stack.removeLast()
        }
    }
    
    /// 如果栈中的元素是字符串，则将栈中的元素打印输出至一个完整字符串
    ///
    /// - Returns: 输出字符串，如果元素不是字符串类型，则为 nil。
    public static func printStack(stack: Stack<String>) -> String? {
        var stackMutatable = stack
        var unit = stackMutatable.pop() // 推出元素
        var printString = "Stack top from here:"
        
        if unit == nil {
            return nil
        } else {
            while unit != nil {
                printString += ("  " + unit!)
                unit = stackMutatable.pop()
            }
        }
        return printString
    }
}


/// 队列结构，可放入任意类型对象，先进入队列的永远在队首，先进先出，通过数组实现。
public struct Queue<Element> {
    
    /// 是否为空
    public var isEmpty: Bool { return queue.isEmpty }
    /// 队列大小
    public var size: Int { return queue.count }
    /// 队列首元素
    public var peek: Element? {
        return queue.first
    }
    
    private var queue: [Element]
    
    /// 构造函数
    public init() {
        queue = [Element]()
    }
    
    /// 加入新元素
    public mutating func enqueue(_ obj: Element) {
        queue.append(obj)
    }
    
    /// 推出队列元素
    public mutating func dequeue() -> Element? {
        if isEmpty {
            return nil
        } else {
            return queue.removeFirst()
        }
    }
    
    
    /// 如果队列中的元素是字符串，则将队列中的元素打印输出至一个完整字符串
    ///
    /// - Returns: 输出字符串，如果元素不是字符串类型，则为 nil。
    public static func printQueue(queue: Queue<String>) -> String? {
        var queueMutated = queue
        var unit = queueMutated.dequeue() // 推出元素
        var printString = "Queue start from here:"
        
        if unit == nil {
            return nil
        } else {
            while unit != nil {
                printString += ("  " + unit!)
                unit = queueMutated.dequeue()
            }
        }
        return printString
    }
    
}

