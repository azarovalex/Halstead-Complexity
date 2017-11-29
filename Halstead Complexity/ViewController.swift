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

let operatorsList = ["==",">=" ,"<=" ,"+=" ,"-=" ,"++","--", "!=", "[", "until", "=", ".open", ".each", ".now", ".chomp", "when", "if ", ".nil", "+", "-", "*", "/", "<", ">", ".upto", ".length", ".new", "and", "or ", ".call", "while", ".empty?", ".size", ".dup", ".push", ".pop", ".times", ".shuffle", ".write", "puts", "exit", "break", ".capitalize", ".now", ".open", "each_line", ".each_with_index", ".each_index", "break", "case", ".min", ".call", ".empty", "|", "{", "," , "%", "exit", "puts", "begin", "?", "!", ]

let blackList = ["]", "}", "def", "do", "class", "self", "File", "Time", "...", ".."]
var findedOperators = [String:Int]()
var findedOperands = [String:Int]()
var numOperators = 0
var numOperands = 0

class ViewController: NSViewController {
    
    @IBOutlet weak var n1: NSTextField!
    @IBOutlet weak var n2: NSTextField!
    @IBOutlet weak var bigN1: NSTextField!
    @IBOutlet weak var bigN2: NSTextField!
    @IBOutlet var f1: NSTextView!
    @IBOutlet var f2: NSTextView!
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
                code = code.replacingOccurrences(of: op, with: " ")
            }
        }
        code_textedit.string = code
        
        // Count Operands
        let variables = code.split(separator: "\n").joined(separator: " ").split(separator: " ")
        for index in 0..<variables.count {
            let operand = String(variables[index])
            if findedOperands[operand] != nil {
                findedOperands[operand]! += 1
            } else { findedOperands[operand] = 1 }
        }
        
        print(findedOperators.description)
        print(findedOperands.description)
        findedOperands.removeAll()
        findedOperators.removeAll()
    }
    
    @IBAction func OpenFile(_ sender: Any) {
        filePath = browseFile()
        guard FileManager.default.fileExists(atPath: filePath) else {
            return
        }
        try! code_textedit.string = String.init(contentsOf: URL.init(fileURLWithPath: filePath), encoding: .ascii)
    }
}

