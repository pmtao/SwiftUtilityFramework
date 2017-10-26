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
    /// 算法参考链接： https://zh.wikipedia.org/wiki/%E8%B0%83%E5%BA%A6%E5%9C%BA%E7%AE%97%E6%B3%95
    /// - Parameter exp: 待转换的数学表达式，如："12 + 34 * (56 * (78 + 90) + 110) * (120  + 130) + sin(90)"
    public static func ShuntingYardTransform(exp: String) -> Queue<[String: Any]>? {
        // 先检查括号是否匹配
        let check = SUF_MathAnalyze.parenthesisCheck(expression: exp)
        if !check {
            return nil
        }
        /// 将表达式解析为队列（已进行内部运算符号系统转换）
        var expQueue = SUF_MathAnalyze.analyzeMathExpression(expression: exp)
        var symbolStack = Stack<String>() // 符号栈
        var resultQueue = Queue<String>() // 输出队列
        var detailedResultQueue = Queue<[String: Any]>() // 带类型标识的输出队列
        
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
                detailedResultQueue.enqueue(["type": SUF_RPNSymbolType.number, "value": SUF_stringToNumber(with: expUnit)!])
            case .plus, .minus, .multiply, .divide,.square, .sin, .cos:
                  /*  如果队列中取出的元素表示一个操作符，记做o1，那么：
                                        只要存在另一个记为o2的操作符（注意如果是括号，则无需比较直接压栈）位于栈的顶端，并且
                                                如果o1是左结合性的并且它的运算符优先级要小于或者等于o2的优先级，或者
                                                如果o1是右结合性的并且它的运算符优先级比o2的要低，那么
                                            将o2从栈的顶端弹出并且放入输出队列中（循环直至以上条件不满足为止）；
                                        然后，将o1压入栈的顶端。*/
                
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
                        let symbol = (symbolStack.pop())!
                        resultQueue.enqueue(symbol)
                        detailedResultQueue.enqueue(["type": SUF_RPNSymbolType.mathSymbol, "value": symbol])
                    } else if association == "right" && unitLevel < stacklevel {
                        let symbol = (symbolStack.pop())!
                        resultQueue.enqueue(symbol)
                        detailedResultQueue.enqueue(["type": SUF_RPNSymbolType.mathSymbol, "value": symbol])
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
                    let symbol = (symbolStack.pop())!
                    resultQueue.enqueue(symbol)
                    detailedResultQueue.enqueue(["type": SUF_RPNSymbolType.mathSymbol, "value": symbol])
                    peek = symbolStack.peek
                }
                
                if peek != nil && (peek!) == "(" {
                    let _ = symbolStack.pop()
                    peek = symbolStack.peek 
                    if peek == nil {
                        print("表达式中可能存在不匹配的括号数量")
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
                    print("表达式中可能存在不匹配的括号数量")
                default:
                    let symbol = (symbolStack.pop())!
                    resultQueue.enqueue(symbol)
                    detailedResultQueue.enqueue(["type": SUF_RPNSymbolType.mathSymbol, "value": symbol])
                }
                peek = symbolStack.peek
            }
        }
        
        return detailedResultQueue
    } // 方法结束
    
}


/// 计算逆波兰表达式
/// 算法参考链接：https://zh.wikipedia.org/wiki/%E9%80%86%E6%B3%A2%E5%85%B0%E8%A1%A8%E7%A4%BA%E6%B3%95
/// - Parameter RPNQueue: 将操作数和操作符分解后的逆波兰表达式队列。
/// 操作符需经过 mathSymbolSystemTransition() 方法转换
/// - Returns: 计算结果
public func SUF_RPNEvaluate(RPNQueue: Queue<[String: Any]>) -> Double? {
    var queue = RPNQueue // 将操作数和操作符分解后的逆波兰表达式队列
    var operandStack = Stack<Double>() // 要计算的操作数栈
    var calcResult: Double? // 声明计算结果
    
    while !(queue.isEmpty) {
        let element = (queue.dequeue())!
        let elementType = element["type"] as! SUF_RPNSymbolType
        let elementValue = element["value"]
        
        if elementType == SUF_RPNSymbolType.number {
            operandStack.push(elementValue as! Double)
        }
        
        if elementType == SUF_RPNSymbolType.mathSymbol {
            let operandCount = (SUF_MathAnalyze.internalSymbols[
                elementValue as! String]?["operandCount"])! as! Int
            if operandStack.size < operandCount {
                print("计算符号需要的操作数个数不足，" +
                    "计算符号是：\(elementValue as! String)，" +
                    "需要的操作数个数是:\(operandCount)")
                return nil
            } else {
                // 取操作数
                if operandCount == 2 {
                    // 先弹出右操作数，再弹出左操作数(顺序不能颠倒)。
                    let operandRight = (operandStack.pop())!
                    let operandLeft = (operandStack.pop())!
                    // 进行计算
                    let result = SUF_mathCalculate.calc(
                        symbol: elementValue as! String,
                        operandLeft: operandLeft,
                        operandRight: operandRight)
                    operandStack.push(result)
                    
                }
                
                if operandCount == 1 {
                    let operand = (operandStack.pop())!
                    // 进行计算
                    let result = SUF_mathCalculate.calc(
                        symbol: elementValue as! String,
                        operand: operand)
                    operandStack.push(result)
                    
                }
            }
        }
    }
    
    
    if operandStack.size == 1 {
        calcResult = (operandStack.pop())!
    } else {
        print("操作数多了")
    }
    
    return calcResult
}

/// 逆波兰表达式中的符号类型
public enum SUF_RPNSymbolType: Int {
    case number = 0
    case mathSymbol = 1
}

/// 常规数学表达式中各种符号类型
public enum SUF_MathSymbolType: String {
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

/// 包含各类数学符号解析转换的结构体
public struct SUF_MathAnalyze {
    /// 数学表达式无效的错误类型
    ///
    /// - undefinedSymbol: 存在未定义的符号
    /// - unmatchedParenthesis: 括号数量不匹配
    public enum InvalidType: Error {
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
        "\u{4E00}": ["literal":"+", "level": 1, "operandCount": 2, "association": "left", "type": SUF_MathSymbolType.plus],
        "\u{4E01}": ["literal":"-", "level": 1, "operandCount": 2, "association": "left", "type": SUF_MathSymbolType.minus],
        "\u{4E02}": ["literal":"×", "level": 2, "operandCount": 2, "association": "left", "type": SUF_MathSymbolType.multiply],
        "\u{4E03}": ["literal":"÷", "level": 2, "operandCount": 2, "association": "left", "type": SUF_MathSymbolType.divide],
        "(":        ["literal":"(", "level": 4, "operandCount": 0, "association": "right", "type": SUF_MathSymbolType.leftParenthesis],
        ")":        ["literal":")", "level": 4, "operandCount": 0, "association": "left", "type": SUF_MathSymbolType.rightParenthesis],
        "\u{4E04}": ["literal":"sin", "level": 3, "operandCount": 1, "association": "left", "type": SUF_MathSymbolType.sin],
        "\u{4E05}": ["literal":"cos", "level": 3, "operandCount": 1, "association": "left", "type": SUF_MathSymbolType.cos]
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
    public static func checkSymbolType(symbol: Character) -> SUF_MathSymbolType {
        var type: SUF_MathSymbolType = .undefined
        
        // 从 [内置数学运算符号系统] 进行查找
        if SUF_MathAnalyze.internalSymbols[String(symbol)] != nil {
            type = (SUF_MathAnalyze.internalSymbols[String(symbol)])!["type"] as! SUF_MathSymbolType
        } else if [".","0","1","2","3","4","5","6","7","8","9"].contains(symbol) {
            type = .number
        }
        return type
    }
    
    
    /// 获取数学符号的计算优先级
    ///
    /// - Parameter symbol: 数学计算符号：+ - * ／ 等
    /// - Returns: 优先级
    public static func getMathSymbolLevel(symbol: String) -> Int? {
        guard let internalSymbol = symbols[symbol] else {
            return nil
        }
        let level = internalSymbols[internalSymbol]?["level"] as? Int
        
        return level
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
                throw InvalidType.undefinedSymbol
            }
        }
        
        if exp.replacingOccurrences(of: "(", with: "").characters.count !=
            exp.replacingOccurrences(of: ")", with: "").characters.count {
            throw InvalidType.unmatchedParenthesis
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
    
    
    /// 检查数学表达式括号数量是否匹配，支持未经转换和转换后的表达式。
    ///
    /// - Parameter expression: 数学表达式
    /// - Returns: 检查结果
    public static func parenthesisCheck(expression: String) -> Bool {
        let leftParenthesisCount = expression.components(separatedBy: "(").count - 1
        let rightParenthesisCount = expression.components(separatedBy: ")").count - 1
        if leftParenthesisCount == rightParenthesisCount {
            return true
        } else {
            print("括号匹配检查不通过")
            return false
        }
    }
    
    /// 解析数学表达式为数组队列，运算符号将经过符号系统转换。
    /// 例如：(123+456)*789 将转换为：["(", "123", "一", "456", ")", "丂", "789"]
    /// - Parameter expression: 未经转换的原始数学表达式
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
                
                if one == "(" || one == ")" {
                    output.enqueue(tempElement)
                    tempElement = String(two)
                }
                    
                // 判断当前读取的字符，与[临时队列元素] 中的字符是否为同一类型。类型不同则将元素放入队列。
                else if compareTwoSymbolType(one: one, two: two) {
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


/// 封装常用的数学计算公式
public struct SUF_mathCalculate {
    /// 双操作数计算
    static public func calc(symbol: String, operandLeft: Double, operandRight: Double) -> Double {
        var result: Double = 0
        
        switch symbol {
        case "\u{4E00}":
            result = plus(operandLeft: operandLeft, operandRight: operandRight)
        case "\u{4E01}":
            result = minus(operandLeft: operandLeft, operandRight: operandRight)
        case "\u{4E02}":
            result = multiply(operandLeft: operandLeft, operandRight: operandRight)
        case "\u{4E03}":
            result = divide(operandLeft: operandLeft, operandRight: operandRight)
        default:
            break
        }
        
        return result
    }
    
    /// 单操作数计算
    static public func calc(symbol: String, operand: Double) -> Double {
        var result: Double = 0
        
        switch symbol {
        case "\u{4E04}":
            result = sin(operand: operand)
        default:
            break
        }
        
        return result
    }
    
    
    
    // 加法
    static func plus(operandLeft: Double, operandRight: Double) -> Double {
        return operandLeft + operandRight
    }
    
    // 减法
    static func minus(operandLeft: Double, operandRight: Double) -> Double {
        return operandLeft - operandRight
    }
    
    // 乘法
    static func multiply(operandLeft: Double, operandRight: Double) -> Double {
        return operandLeft * operandRight
    }
    
    // 除法
    static func divide(operandLeft: Double, operandRight: Double) -> Double {
        return operandLeft / operandRight
    }
    
    // 正弦计算
    static func sin(operand: Double) -> Double {
        let radian = CGFloat(Double.pi / 180 * operand) // 由度转为弧度
        return Double(CoreGraphics.sin(radian))
    }
}


/// 栈结构，可放入任意类型对象，后进栈的永远在栈首，后进先出，通过数组实现。
public struct Stack<Element> {
    // MARK: --普通属性-------------------👇
    // 栈元素个数上限
    public var sizeLimit: Int = 0
    
    /// 入栈操作的限制方法，方法返回 true 时才能入栈。
    public var filter: ((Element) -> Bool)?
    
    // 栈实例
    private var stack: [Element]
    
    // MARK: --计算属性-------------------👇
    /// 是否为空
    public var isEmpty: Bool { return stack.isEmpty }
    
    /// 是否装满了
    public var isFull: Bool {
        if self.sizeLimit <= 0 {
            return false
        } else {
            return self.stack.count >= self.sizeLimit
        }
    }
    
    /// 栈的大小
    public var size: Int { return stack.count }
    /// 栈顶元素
    public var peek: Element? {
        return stack.last
    }
    
    // MARK: --结构体方法-------------------👇
    /// 构造函数
    public init() {
        stack = [Element] ()
    }
    
    /// 加入限制条件的初始化方法
    public init(sizeLimit: Int = 0, filter: ((Element) -> Bool)? = nil) {
        self.sizeLimit = sizeLimit
        self.filter = filter
        stack = [Element] ()
    }
    
    /// 获取栈元素数组
    ///
    /// - Returns: 元素数组
    public func getStackArray() -> [Element] {
        return self.stack
    }
    
    /// 向栈内压入一个新元素，压入前需检查栈是否有大小限制、元素过滤条件限制，条件都满足才允许入栈。
    ///
    /// - Parameter obj: 待压栈的元素
    public mutating func push(_ obj: Element) {
        if !isFull {
            if filter != nil {
                let filterResult = filter!(obj)
                if filterResult { // 符合过滤条件
                    stack.append(obj)
                } else {
                    print("For this element can't meet the filter, it can't be pushing into the stack: \(String(describing: obj)).")
                }
            } else {
                stack.append(obj)
            }
        } else {
            print("Stack is full, this element can't be pushing into the stack: \(String(describing: obj)).")
        }
    }
    
    /// 推出栈顶元素
    public mutating func pop() -> Element? {
        if isEmpty {
            return nil
        } else {
            return stack.removeLast()
        }
    }
    
    /// 将队列结构体，转换为栈结构体。
    ///
    /// - Parameter queue: 待转换的队列
    /// - Returns: 转换后的栈
    public static func convertQueueToStack(queue: Queue<Element>) -> Stack<Element> {
        let queueArray = queue.getQueueArray() // 获取队列元素数组
        var stack = Stack<Element>() // 声明转换后的 Stack
        // 继承 queue 的相似属性
        stack.stack = queueArray
        stack.sizeLimit = queue.sizeLimit
        stack.filter = queue.filter
        
        return stack
    }
    
    /// 将数组转换为栈
    ///
    /// - Parameters:
    ///   - array: 待转换的数组
    ///   - sizeLimit: 栈元素个数上限
    ///   - filter: 入栈操作的限制方法
    /// - Returns: 转换后的栈
    public static func convertArrayToStack(
        array: [Element],
        sizeLimit: Int = 0,
        filter: ((Element) -> Bool)? = nil) -> Stack<Element>
    {
        var stack = Stack<Element>() // 声明转换后的 Stack
        stack.stack = array
        stack.sizeLimit = sizeLimit
        stack.filter = filter
        
        return stack
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
    // MARK: --普通属性-------------------👇
    // 队列元素个数上限
    public var sizeLimit: Int = 0
    
    /// 标志队列达到上限时，是否允许推出队首元素，再加入新元素。
    public var isDequeueOnFull: Bool = false
    
    /// 入队列操作的限制方法，方法返回 true 时才能入队列。
    public var filter: ((Element) -> Bool)?
    
    /// 队列实例
    private var queue: [Element]
    
    // MARK: --计算属性-------------------👇
    /// 是否为空
    public var isEmpty: Bool { return queue.isEmpty }
    /// 队列是否满了
    public var isFull: Bool {
        if self.sizeLimit <= 0 {
            return false
        } else {
            return self.queue.count >= self.sizeLimit
        }
    }
    
    /// 队列大小
    public var size: Int { return queue.count }
    /// 队列首元素
    public var peek: Element? {
        return queue.first
    }
    
    // MARK: --结构体方法-------------------👇
    /// 构造函数
    public init() {
        queue = [Element]()
    }
    
    /// 加入限制条件的初始化方法
    public init(
        sizeLimit: Int = 0,
        isDequeueOnFull: Bool = false,
        filter: ((Element) -> Bool)? = nil)
    {
        self.sizeLimit = sizeLimit
        self.isDequeueOnFull = isDequeueOnFull
        self.filter = filter
        queue = [Element] ()
    }
    
    /// 获取队列元素数组
    ///
    /// - Returns: 元素数组
    public func getQueueArray() -> [Element] {
        return self.queue
    }
    
    /// 向队列中添加一个新元素，添加前需检查队列是否有大小限制、元素过滤条件限制，条件都满足才允许入队列。
    ///
    /// - Parameter obj: 待入队列的元素
    public mutating func enqueue(_ obj: Element) {
        // 队列未满的情况。如果有过滤条件，先判断；没有则直接加入。
        if !isFull {
            if filter != nil {
                let filterResult = filter!(obj)
                if filterResult { // 符合过滤条件
                    queue.append(obj)
                } else {
                    print("For this element can't meet the filter, it can't  join the queue: \(String(describing: obj)).")
                }
            } else {
                queue.append(obj)
            }
        }
            
        // 队列已满
        else {
            // 判断标志：队列已满时是否可以放入新元素
            if isDequeueOnFull {
                // 判断过滤条件
                if filter != nil {
                    let filterResult = filter!(obj)
                    if filterResult {
                        // 符合过滤条件
                        if !isEmpty {
                            queue.removeFirst()
                            queue.append(obj)
                        }
                    } else {
                        print("For this element can't meet the filter, it can't  join the queue: \(String(describing: obj)).")
                    }
                }
                // 无过滤条件
                else {
                    if !isEmpty {
                        queue.removeFirst()
                        queue.append(obj)
                    }
                }
            } else {
                print("Queue is full, this element can't join the queue: \(String(describing: obj)).")
            }
        }
    }
    
    /// 推出队列元素
    public mutating func dequeue() -> Element? {
        if isEmpty {
            return nil
        } else {
            return queue.removeFirst()
        }
    }
    
    /// 将栈结构体，转换为队列结构体。
    ///
    /// - Parameter stack: 待转换的栈
    /// - Returns: 转换后的队列
    public static func convertStackToQueue(stack: Stack<Element>) -> Queue<Element> {
        let stackArray = stack.getStackArray() // 获取栈元素数组
        var queue = Queue<Element>() // 声明转换后的 Queue
        // 继承 stack 的相似属性
        queue.queue = stackArray
        queue.sizeLimit = stack.sizeLimit
        queue.filter = stack.filter
        
        return queue
    }
    
    /// 将数组转换为队列
    ///
    /// - Parameters:
    ///   - array: 待转换的数组
    ///   - sizeLimit: 队列元素个数上限
    ///   - isDequeueOnFull: 标志队列达到上限时，是否允许推出队首元素，再加入新元素。
    ///   - filter: 入队列操作的限制方法
    /// - Returns: 转换后的队列
    public static func convertArrayToQueue(
        array: [Element],
        sizeLimit: Int = 0,
        isDequeueOnFull: Bool = false,
        filter: ((Element) -> Bool)? = nil) -> Queue<Element>
    {
        var queue = Queue<Element>() // 声明转换后的 Queue
        queue.queue = array
        queue.sizeLimit = sizeLimit
        queue.filter = filter
        
        return queue
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

