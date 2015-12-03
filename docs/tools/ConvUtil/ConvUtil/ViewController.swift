//
//  ViewController.swift
//  ConvUtil
//
//  Created by syun on 2015/10/23.
//  Copyright © 2015年 syun. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    // 実行するツールのパス
    let XLS2CSV = "/Users/syun/Desktop/TournRPG/docs/xls2csv.command"
    let BGM     = "/Users/syun/Desktop/TournRPG/docs/sounds/sndconv_bgm.command"
    let SE      = "/Users/syun/Desktop/TournRPG/docs/sounds/sndconv.command"
    let AI      = "/Users/syun/Desktop/TournRPG/docs/ai/conv_ai.command"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    // xlsをcsvにコンバートする
    @IBAction func xls2csv(sender: AnyObject) {
        exec("/bin/bash", XLS2CSV)
    }
    
    // BGMコンバート
    @IBAction func bgm(sender: AnyObject) {
        exec("/bin/bash", BGM)
    }
    
    // SEコンバート
    @IBAction func se(sender: AnyObject) {
        exec("/bin/bash", SE)
    }
    
    // AIコンバート
    @IBAction func ai(sender: AnyObject) {
        exec("/bin/bash", AI)
    }
    
    // ログのクリア
    @IBAction func clear(sender: AnyObject) {
        txtLog.string = "";
    }
    
    // コンバート実行
    func exec(sh: String, _ tool: String) {
        let task:NSTask = NSTask()
        task.launchPath = sh
        task.arguments = [tool]
        let pipe:NSPipe = NSPipe()
        task.standardOutput = pipe
        task.launch()
        let out:NSData = pipe.fileHandleForReading.readDataToEndOfFile()
        let outStr:String? = NSString(data:out, encoding:NSUTF8StringEncoding) as? String
        
        print(outStr!)
        
        // ダイアログ表示
        //let alert = NSAlert()
        //alert.messageText = outStr!
        //alert.runModal()
        
        // ログに反映
        txtLog.string = outStr!
    }

    @IBOutlet var txtLog: NSTextView!
}

