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
        
//         SUF_MathAnalyze_test ()
        
//        SUF_ShuntingYard_test()

//        Stack_test()
//        Queue_test()
        newwork_test()

    }
    
    func  SUF_MathAnalyze_test () {
        let string = "123+457"
        let exp = SUF_MathAnalyze.mathSymbolSystemTransition(string)
        let valid = try! SUF_MathAnalyze.isMathExpressionValid(exp: exp)
        XCTAssertEqual(valid, "", "测试不通过")
        var queue = SUF_MathAnalyze.analyzeMathExpression(expression: string)
        _ = queue?.dequeue()
        XCTAssertEqual((queue?.peek)! , "\u{4E00}", "测试不通过")
        
        let level = SUF_MathAnalyze.getMathSymbolLevel(symbol: "*")
        print(level!)

    }
    
    func SUF_ShuntingYard_test() {
//        let string = "12 + 34 * (56 * (78 + 90) + 110) * (120  + 130) + sin(90)"
        let string = "((15+2+3)*5-50)*3"
        guard let resultQueue = SUF_ShuntingYard.ShuntingYardTransform(exp: string) else {
            return
        }
        guard let result = SUF_RPNEvaluate(RPNQueue: resultQueue) else {
            return
        }
        print("result:\(result)")
    }
    
    func Stack_test() {
        func filter(obj: Int) -> Bool {
            if obj % 2 == 0 {
                return true
            } else {
                return false
            }
        }
        
        var stack = Stack<Int>(sizeLimit: 4, filter: filter)
        stack.push(1)
        stack.push(2)
        stack.push(3)
        stack.push(4)
        stack.push(5)
        stack.push(6)
        stack.push(7)
        stack.push(8)
        stack.push(9)
        stack.push(10)
        print("Is stack full: \(stack.isFull)")
        print("Top element: \((stack.peek)!)")
    }
    
    func Queue_test() {
        func filter(obj: Int) -> Bool {
            if obj % 2 == 0 {
                return true
            } else {
                return false
            }
        }
        
        var queue = Queue<Int>(sizeLimit: 4, isDequeueOnFull: true, filter: filter)
        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        queue.enqueue(4)
        queue.enqueue(5)
        queue.enqueue(6)
        queue.enqueue(7)
        queue.enqueue(8)
        queue.enqueue(9)
        queue.enqueue(10)
        print("Is queue full: \(queue.isFull)")
        print("First element: \((queue.peek)!)")
    }
    
    
    func newwork_test() {
        let httpSession: HttpSession = HttpSession(sessionType: .Ephemeral, taskType: .DataTask)
        let url = "http://www.bankcomm.com/BankCommSite/zonghang/cn/whpj/foreignExchangeSearch_Cn.jsp"
        
        
//        let getString = "erectDate=\(date)&nothing=\(date)&pjname=1316"
        let completion = {(data: Data?, response: URLResponse?, error: Error?) in
            if error != nil{
                print(error.debugDescription)
            } else {
                print(data!)
            }
        }
        
        httpSession.get(url: url, completion: completion)
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
