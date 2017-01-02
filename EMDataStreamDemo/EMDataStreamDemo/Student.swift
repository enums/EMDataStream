//
//  Student.swift
//  EMFileStreamDemo
//
//  Created by 郑宇琦 on 2016/12/25.
//  Copyright © 2016年 Enum. All rights reserved.
//

import Foundation
import EMDataStream

class Student: CustomStringConvertible, EMDataStreamReadable, EMDataStreamWriteable {
    
    var name: String
    var age: Int
    var source: Float
    var memo: String
    
    var description: String {
        return "name: \(name), age: \(age), source: \(source) memo: \(memo)"
    }
    
    init(name: String, age: Int, source: Float, memo: String) {
        self.name = name
        self.age = age
        self.source = source
        self.memo = memo
    }
    
    public required init(stream: EMDataStream) throws {
        self.name = try stream.readString(withSize: 20)
        self.age = try stream.readInt()
        self.source = try stream.readFloat()
        self.memo = try stream.readString(withSize: 100)
    }
    
    func emObjectWrite(withStream stream: EMDataStream) throws {
        try stream.write(string: name, writeSize: 20)
        try stream.write(int: age)
        try stream.write(float: source)
        try stream.write(string: memo, writeSize: 100)
    }
    
}
