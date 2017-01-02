//
//  ViewController.swift
//  EMDataStreamDemo
//
//  Created by 郑宇琦 on 2017/1/2.
//  Copyright © 2017年 Enum. All rights reserved.
//

import UIKit
import EMDataStream

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        do {
            let student = Student.init(name: "Sark", age: 20, source: 78.9, memo: "Memo..........")
            
            let stream = EMDataStream.init()
            try stream.write(object: student)
            
            let streamOut = EMDataStream.init(data: stream.toData())
            let stundentOut: Student = try streamOut.readObject()
            
            print(stundentOut)
        } catch {
            print(error)
        }
    }

}

