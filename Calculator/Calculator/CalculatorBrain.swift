//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Elizabeth Wei on 3/9/15.
//  Copyright (c) 2015 Elizabeth Wei. All rights reserved.
//

import Foundation

class CalculatorBrain {
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case ConstantOperation(String, () -> Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let symbol):
                    return symbol
                case .ConstantOperation(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol,_):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String:Op]()
    
    private var variableValues = [String: Double]()
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.ConstantOperation("π", {M_PI}))
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("ᐩ/-", { -1 * $0}))
    }
    
    var program: AnyObject{ //guaranteed to be a PropertyList
        get {
            return opStack.map{$0.description}
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    }
                    else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    func clear() {
        variableValues = [:]
        opStack = []
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if(!ops.isEmpty) {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let symbol):
                if let operand = variableValues[symbol] {
                   return (variableValues[symbol], remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            case .ConstantOperation(_, let operation):
                return (operation(), remainingOps)
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
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    private func getDescription(ops: [Op]) -> (result: String?, remainingOps: [Op]) {
        if(!ops.isEmpty) {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Variable(let symbol):
                return (symbol, remainingOps)
            case .ConstantOperation(let operation, _):
                return (operation, remainingOps)
            case .UnaryOperation(let operation, _):
                let op = getDescription(remainingOps)
                if let operand = op.result {
                    return (operation + "(" + "\(operand))" + ")", op.remainingOps)
                }
                return (operation + "(?)", op.remainingOps)
            case .BinaryOperation(let operation, _):
                let op1 = getDescription(remainingOps)
                if let operand1 = op1.result {
                    let op2 = getDescription(op1.remainingOps)
                    if let operand2 = op2.result {
                        return ("(" + "\(operand2)" + operation + "\(operand1)" + ")", op2.remainingOps)
                    }
                    return ("(?" + operation + "\(operand1)" + ")", op2.remainingOps)
                }
                let op2 = getDescription(op1.remainingOps)
                if let operand2 = op2.result {
                    return ("(" + "\(operand2)" + operation + "?)", op2.remainingOps)
                }
                return ("(?" + operation + "?)", op2.remainingOps)
            }
        }
        
        return (nil, ops)
    }
    
    func getDescription() -> String? {
        var tempStack = opStack
        if let description = getDescription(tempStack).result {
            println("description is " + description)
            return description
        }
        else {
            return nil
        }
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(operand: String) -> Double? {
        opStack.append(Op.Variable(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func setVariable(symbol: String, value: Double) -> Double? {
        variableValues[symbol] = value
        return evaluate()
    }
    
    func getVariableValue() -> Double? {
        var val = opStack.removeLast() //todo: set variable to expression, not just latest operand
        switch val {
        case .Operand(let op):
            return op
        default:
            return nil
        }
    }
    
    var description: String {
        get {
            if let res = getDescription() {
                return res
            }
            else {
                return " "
            }
        }
    }
}