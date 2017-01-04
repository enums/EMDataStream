//
//  EMDataStream.swift
//  EMDataStream
//
//  Created by 郑宇琦 on 2017/1/2.
//  Copyright © 2017年 Enum. All rights reserved.
//


import Foundation
import EMFileStream

open class EMDataStream: CustomStringConvertible {
    
    fileprivate var bytes: Array<UInt8>
    fileprivate var offset = 0
    open var position: Int {
        get {
            return offset
        }
    }
    open var limit: Int {
        get {
            return bytes.count
        }
    }
    
    open var mptr: UnsafeMutablePointer<UInt8> {
        get {
            var ptr: UnsafeMutablePointer<UInt8>!
            withUnsafeMutablePointer(to: &bytes[offset], { _ptr in
                ptr = _ptr
            })
            return ptr
        }
    }
    
    public var description: String {
        get {
            return bytes.reduce("EMDataStream: limit: \(limit)\ndata: ") { str, uint8 in str + "[\(uint8)]"}
        }
    }
    
    public convenience init() {
        self.init(size: 0)
    }
    
    public init(size: Int) {
        bytes = Array<UInt8>.init(repeating: 0, count: size)
    }
    
    public init(data: Data) {
        let size = data.count
        var bytes = Array<UInt8>.init(repeating: 0, count: size)
        withUnsafeMutablePointer(to: &bytes[0], { ptr in
            data.copyBytes(to: ptr, count: size)
        })
        self.bytes = bytes
    }
    
    public init(bytes: Array<UInt8>) {
        self.bytes = bytes
    }
    
    open func toData() -> Data {
        return Data.init(bytes: bytes)
    }
    
    //MARK: - Standard
    open func read(size: Int) throws -> EMMemory {
        try guardSelfNotOutOfSize(needSize: size)
        let memory = EMMemory.init(ptr: mptr, size: size)
        offset += size
        return memory
    }
    
    open func seek(byPosition position: Int) throws {
        try guardSelfNotOutOfSize(needSize: position)
        offset += position
    }
    
    open func seek(toPosition position: Int) throws {
        offset = 0
        try seek(byPosition: position)
    }
    
    open func write(dataPtr: UnsafeMutableRawPointer, size: Int) throws {
        var data = Array<UInt8>.init(repeating: 0, count: size)
        _ = withUnsafeMutablePointer(to: &data[0], { ptr in
            memcpy(ptr, dataPtr, size)
        })
        try write(bytes: bytes)
    }
    
    open func write(bytes: Array<UInt8>) throws {
        let dataSize = bytes.count
        if position + dataSize > limit {
            if limit == -1 {
                self.bytes = bytes
            } else {
                self.bytes.replaceSubrange(position..<limit, with: bytes.dropLast(limit - position))
                self.bytes.append(contentsOf: bytes.dropFirst(limit - position))
            }
        } else {
            try guardSelfNotOutOfSize(needSize: dataSize)
            self.bytes.replaceSubrange(position..<position + dataSize, with: bytes)
        }
        offset += dataSize
    }
    
    open func write(data: Data) throws {
        var bytes = Array<UInt8>.init(repeating: 0, count: data.count)
        data.copyBytes(to: &bytes[0], count: data.count)
        try write(bytes: bytes)
    }
    
    //MARK: - Extension Seek
    open func seekInt() throws {
        try seek(byPosition: EM_SIZE_INT)
    }
    
    open func seekUInt() throws {
        try seek(byPosition: EM_SIZE_UINT)
    }
    
    open func seekUInt8() throws {
        try seek(byPosition: EM_SIZE_UINT8)
    }
    
    open func seekFloat() throws {
        try seek(byPosition: EM_SIZE_FLOAT)
    }
    
    open func seekDouble() throws {
        try seek(byPosition: EM_SIZE_DOUBLE)
    }

    //MARK: - Extension Read
    open func readInt() throws -> Int {
        let memory = try read(size: EM_SIZE_INT)
        return Int.gen(ptr: memory.mptr)
    }
    
    open func readUInt() throws -> UInt {
        let memory = try read(size: EM_SIZE_UINT)
        return UInt.gen(ptr: memory.mptr)
    }
    
    open func readUInt8() throws -> UInt8 {
        let memory = try read(size: EM_SIZE_UINT8)
        return UInt8.gen(ptr: memory.mptr)
    }
    
    open func readFloat() throws -> Float {
        let memory = try read(size: EM_SIZE_FLOAT)
        return Float.gen(ptr: memory.mptr)
    }
    
    open func readDouble() throws -> Double {
        let memory = try read(size: EM_SIZE_DOUBLE)
        return Double.gen(ptr: memory.mptr)
    }
    
    open func readString(withSize size: Int) throws -> String {
        let memory = try read(size: EM_SIZE_CHAR * size)
        return String.gen(ptr: memory.mptr)
    }
    
    open func readObject<T: EMDataStreamReadable>() throws -> T {
        return try T.init(stream: self)
    }

    //MARK: - Extension Write
    open func write(int: Int) throws {
        var _int = int
        try write(dataPtr: &_int, size: EM_SIZE_INT)
    }
    
    open func write(uint: UInt) throws {
        var _uint = uint
        try write(dataPtr: &_uint, size: EM_SIZE_UINT)
    }
    
    open func write(uint8: UInt8) throws {
        var _uint8 = uint8
        try write(dataPtr: &_uint8, size: EM_SIZE_UINT8)
    }
    
    open func write(float: Float) throws {
        var _float = float
        try write(dataPtr: &_float, size: EM_SIZE_FLOAT)
    }
    
    open func write(double: Double) throws {
        var _double = double
        try write(dataPtr: &_double, size: EM_SIZE_DOUBLE)
    }
    
    open func write(string: String, writeSize: Int? = nil) throws {
        guard var cStr = string.cString(using: .utf8) else {
            throw EMError.init(type: .fileWriteFailed, detail: "String encoding failed!")
        }
        if let size = writeSize {
            if size > cStr.count {
                for _ in cStr.count..<size {
                    cStr.append(0)
                }
            } else if size < cStr.count {
                throw EMError.init(type: .fileWriteFailed, detail: "Length of string is more than writeSize!")
            }
        }
        try write(dataPtr: &cStr, size: cStr.count)
    }
    
    open func write(object: EMDataStreamWriteable) throws {
        try object.emObjectWrite(withStream: self)
    }

    
    //MARK: - Guard
    fileprivate func guardSelfNotOutOfSize(needSize: Int) throws {
        if needSize > 0 {
            guard position + needSize <= limit else {
                throw EMError.init(type: .streamOutOfLimit, detail: "position: \(position), needSize: \(needSize), but limit: \(limit)")
            }
        } else if needSize < 0 {
            guard position + needSize >= 0 else {
                throw EMError.init(type: .streamOutOfLimit, detail: "position: \(position), but needSize: \(needSize)")
            }
        }
    }
    
}
