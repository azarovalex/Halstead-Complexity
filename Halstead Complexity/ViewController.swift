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

class ViewController: NSViewController {

    
    @IBOutlet weak var n1: NSTextField!
    @IBOutlet weak var n2: NSTextField!
    @IBOutlet weak var bigN1: NSTextField!
    @IBOutlet weak var bigN2: NSTextField!
    @IBOutlet var f1: NSTextView!
    @IBOutlet var f2: NSTextView!
    @IBOutlet var code: NSTextView!
    var filePath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        code.font = NSFont(name: "Courier New", size: 13)
    }
    
    @IBAction func Calculate(_ sender: Any) {
    }
    
    @IBAction func OpenFile(_ sender: Any) {
        filePath = browseFile()
        guard FileManager.default.fileExists(atPath: filePath) else {
            return
        }
        try! code.string = String.init(contentsOf: URL.init(fileURLWithPath: filePath), encoding: .ascii)
    }
}

