//
//  ViewController.swift
//  Calculator
//
//  Created by Dylan Walker Brown on 12/11/15.
//  Copyright © 2015 Dylan Walker Brown. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var brain = CalculatorBrain()
    var userIsInTheMiddleOfTypingANumber: Bool = false
    var operandStack: Array<Double> = []

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    @IBAction func appendDigit(sender: UIButton) {
        var digit = sender.currentTitle!
        
        // Handle entries of "." in the display.
        if "." == digit {
            if userIsInTheMiddleOfTypingANumber {
                // Return if user enters more than one "." in the display.
                if display.text!.containsString(".") {
                    return
                }
            } else {
                // If this is the first entry, append a leading zero.
                digit = "0."
            }
        }
        
        // Handle existing entries of π in the display.
        if "π" == display.text! {
            enter()
        }
        // Handle new entries of π.
        if "π" == digit {
            if userIsInTheMiddleOfTypingANumber {
                enter()
            }
            display.text = digit
        }
        
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTypingANumber = true
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0.0
            }
        }
    }
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue){
            displayValue = result
        } else {
            displayValue = 0.0
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.clear()
        userIsInTheMiddleOfTypingANumber = false
        displayValue = 0.0
    }
    
    var displayValue: Double {
        get {
            if "π" == display.text {
                return acos(-1.0)
            } else {
                return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
            }
        }
        set {
            display.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}
