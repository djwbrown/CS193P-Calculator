//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Dylan Walker Brown on 12/18/15.
//  Copyright © 2015 Dylan Walker Brown. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: CustomStringConvertible {
        case Operand(Double)
        case Constant(String)
        case Variable(String)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)

        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Constant(let symbol):
                    return symbol
                case .Variable(let symbol):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    private var knownOps = [String:Op]()
    private var constantValues = [String:Double]()
    var variableValues = [String:Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        func learnConstant(constant: String, withValue cValue: Double) {
            constantValues[constant] = cValue
        }
        
        learnConstant("π", withValue: M_PI)
        
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
    }
    
    typealias PropertyList = AnyObject
    var program: PropertyList { // Guaranteed to be a property list.
        get {
            return opStack.map({$0.description})
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else {
                        if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                            newOpStack.append(.Operand(operand))
                        }
                    }
                }
                opStack = newOpStack
            }
            
        }
    }
    
    var description: String {
        // Display the contents of the stack with human-readable infix notation.
        return ""
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Constant(let symbol):
                return (constantValues[symbol], remainingOps)
            case .Variable(let symbol):
                return (variableValues[symbol], remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func clear() {
        opStack = [Op]()
        variableValues = [String:Double]()
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        let isConstant = constantValues.keys.contains(symbol)
        if isConstant {
            opStack.append(Op.Constant(symbol))
        } else {
            opStack.append(Op.Variable(symbol))
        }
        
        let result = evaluate()
        
        if !isConstant {
            variableValues[symbol] = result
        }
        return result
    }
        
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}