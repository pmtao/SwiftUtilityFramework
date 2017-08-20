//
//  SwiftUtilityFrameworkTests.swift
//  SwiftUtilityFrameworkTests
//
//  Created by 阿涛 on 17-8-18.
//  Copyright © 2017年 SinkingSoul. All rights reserved.
//

import XCTest
import SwiftUtilityFramework

class SwiftUtilityFrameworkTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // SUF_MathAnalyze_test ()
        
        SUF_ShuntingYard_test()


//         Stack_test()
        
        
    }
    
    func  SUF_MathAnalyze_test () {
        let string = "123+457"
        let exp = SUF_MathAnalyze.mathSymbolSystemTransition(string)
        let valid = try! SUF_MathAnalyze.isMathExpressionValid(exp: exp)
        XCTAssertEqual(valid, "", "测试不通过")
        var queue = SUF_MathAnalyze.analyzeMathExpression(expression: string)
        _ = queue?.dequeue()
        XCTAssertEqual((queue?.peek)! , "\u{4E00}", "测试不通过")
    }
    
    func SUF_ShuntingYard_test() {
        let string = "12 + 34 * (56 * (78 + 90) + 110) * (120  + 130) + sin(90)"
        let resultQueue = SUF_ShuntingYard.ShuntingYardTransform(exp: string)
        var printString = Queue<String>.printQueue(queue: resultQueue)
        printString = SUF_MathAnalyze.mathSymbolToLiteral(printString!)
        print("\(printString!)")
    }
    
    func Stack_test() {
        var stack = Stack<String>()
        stack.push("1")
        stack.push("2")
        stack.push("3")
        let printString = Stack<String>.printStack(stack: stack)
        XCTAssertEqual(printString!, "Stack top from here:  3  2  1", "测试不通过")
    }
    
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
