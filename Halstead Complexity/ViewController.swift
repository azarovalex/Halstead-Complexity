//
//  ViewController.swift
//  Halstead Complexity
//
//  Created by Alex Azarov on 28/11/2017.
//  Copyright © 2017 Alex Azarov. All rights reserved.
//

import Cocoa

func browseFile() -> String {
    let dialog = NSOpenPanel();
    dialog.title                   = "Choose a file";
    dialog.showsResizeIndicator    = true;
    dialog.showsHiddenFiles        = false;
    dialog.canCreateDirectories    = true;
    dialog.allowsMultipleSelection = false;
    
    if (dialog.runModal() == NSApplication.ModalResponse.OK) {
        let result = dialog.url
        if (result != nil) {
            return result!.path
        }
    } else { return "" }
    return ""
}

let operatorsList = ["==",">=" ,"<=" ,"+=" ,"-=" ,"++","--", "!=", "[", "until", "=", ".open", ".each", ".now", ".chomp", "when", "if ", ".nil", "+", "-", "*", "/", "<", ">", ".upto", ".length", ".new", "and", "or ", ".call", "while", ".empty?", ".size", ".dup", ".push", ".pop", ".times", ".shuffle", ".write", "puts", "exit", "break", ".capitalize", ".now", ".open", "each_line", ".each_with_index", ".each_index", "break", "case", ".min", ".call", ".empty", "|", "{", "," , "%", "exit", "puts", "begin", "?", "!",]

let blackList = ["]", "}", "def", "do", "class", "self", "File", "Time", "...", ".."]
var findedOperators = [String:Int]()
var findedOperands = [String:Int]()
var numOperators = 0
var numOperands = 0
var numOfUniqueOperators = 0
var numOfUniqueOperands = 0

class ViewController: NSViewController {
    
    @IBOutlet weak var n1: NSTextField!
    @IBOutlet weak var n2: NSTextField!
    @IBOutlet weak var n: NSTextField!
    @IBOutlet weak var bigN1: NSTextField!
    @IBOutlet weak var bigN2: NSTextField!
    @IBOutlet weak var bigN: NSTextField!
    @IBOutlet var f1: NSTextView!
    @IBOutlet var f2: NSTextView!
    @IBOutlet weak var V: NSTextField!
    @IBOutlet var code_textedit: NSTextView!
    
    var filePath = ""
    var code = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        code_textedit.font = NSFont(name: "Courier New", size: 13)
    }
    
    @IBAction func Calculate(_ sender: Any) {
        code = code_textedit.string
        
        // Delete comments, handles functions and string in quotes
        var lines = code.split(separator: "\n")
        for index in 0..<lines.count {
            if lines[index].contains("#") {
                let hashArray = lines[index].split(separator: "#")
                if hashArray.count > 1 {
                    lines[index] = hashArray[0]
                } else { lines[index] = "" }
            }
            
            if lines[index].contains("\"") {
                let quotesArray = lines[index].split(separator: "\"")
                lines[index] = quotesArray[0]
                if quotesArray.count > 1 {
                    let operand = String(quotesArray[1])
                    numOperands += 1
                    if findedOperands[operand] != nil {
                        findedOperands[operand]! += 1
                    } else { findedOperands[operand] = 1 }
                    if quotesArray.count > 2 {
                        lines[index] += quotesArray[2]
                    }
                }
            }
            
            if lines[index].contains("=") == false && lines[index].contains("(") {
                var newline = lines[index].split(separator: "(").joined(separator: " ")
                newline = newline.split(separator: ",").joined(separator: " ")
                newline = newline.split(separator: ")").joined(separator: " ")
                let newnewline = newline.split(separator: "≠")
                lines[index] = newnewline[0]
            }
            
            if lines[index].contains("=") && lines[index].contains("(") {
                var newline = String(lines[index])
                let parenthPos = Array(newline).index(of: "(")!
                if Array(newline)[parenthPos - 1] != " " {
                    newline = lines[index].split(separator: "(").joined(separator: " ")
                    newline = newline.split(separator: ",").joined(separator: " ")
                    newline = newline.split(separator: ")").joined(separator: " ")
                    let newnewline = newline.split(separator: "≠")
                    lines[index] = newnewline[0]
                } else {
                    var newline = lines[index].split(separator: "(").joined(separator: " ")
                    newline = newline.split(separator: ")").joined(separator: " ")
                    let newnewline = newline.split(separator: "≠")
                    lines[index] = newnewline[0]
                    numOperators += 1
                    if findedOperators["(...)"] != nil {
                        findedOperators["(...)"]! += 1
                    } else { findedOperators["(...)"] = 1 }
                }
            }
        }
        code = lines.joined(separator: "\n")
        
        // Delete all black list crap
        for str in blackList {
            code = code.replacingOccurrences(of: str, with: " ")
        }
        

        
        // Count operators
        code = code.replacingOccurrences(of: "else", with: "")
        code = code.replacingOccurrences(of: "end", with: "")
        for op in operatorsList {
            if code.contains(op) {
                let numOfOper = code.components(separatedBy: op).count - 1
                findedOperators[op] = numOfOper
                numOperators = numOperators + numOfOper
                code = code.replacingOccurrences(of: op, with: " ")
            }
        }
        
        
        // Count Operands
        let variables = code.split(separator: "\n").joined(separator: " ").split(separator: " ")
        for index in 0..<variables.count {
            let operand = String(variables[index])
            numOperands += 1
            if findedOperands[operand] != nil {
                findedOperands[operand]! += 1
            } else { findedOperands[operand] = 1 }
        }
        
        numOfUniqueOperands = findedOperands.count
        numOfUniqueOperators = findedOperators.count
        
        // Display counted numbers
        n1.stringValue = "\(numOfUniqueOperators)"
        n2.stringValue = "\(numOfUniqueOperands)"
        bigN1.stringValue = "\(numOperators)"
        bigN2.stringValue = "\(numOperands)"
        
        // Display list of operator and operands
        var operatorsDisplay = findedOperators.description.components(separatedBy: ", ").joined(separator: "\n")
        operatorsDisplay.remove(at: operatorsDisplay.startIndex)
        operatorsDisplay = operatorsDisplay.substring(to: operatorsDisplay.index(before: operatorsDisplay.endIndex))
        f1.string = operatorsDisplay
        var operandsDisplay = findedOperands.description.components(separatedBy: ", ").joined(separator: "\n")
        operandsDisplay.remove(at: operandsDisplay.startIndex)
        operandsDisplay = operandsDisplay.substring(to: operandsDisplay.index(before: operandsDisplay.endIndex))
        f2.string = operandsDisplay
        
        n.stringValue = "\(numOfUniqueOperators + numOfUniqueOperands)"
        bigN.stringValue = "\(numOperators + numOperands)"
        V.stringValue = "\(Double(numOperators + numOperands) * log2(Double(numOfUniqueOperators + numOfUniqueOperands)))"
        
        findedOperands.removeAll()
        findedOperators.removeAll()
        numOfUniqueOperators = 0
        numOfUniqueOperands = 0
        numOperators = 0
        numOperands = 0
    }
    
    @IBAction func OpenFile(_ sender: Any) {
        filePath = browseFile()
        guard FileManager.default.fileExists(atPath: filePath) else {
            return
        }
        try! code_textedit.string = String.init(contentsOf: URL.init(fileURLWithPath: filePath), encoding: .ascii)
    }
}

