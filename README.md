# EMDataStream

A memory stream tool developed by Swift 3 working on iOS, macOS and Linux.

#  中文介绍

你可以在[「这里」](http://enumsblog.com/post?pid=17001)找到中文介绍。

# Integration

EMDataStream depend on [「EMFileStream」](https://github.com/trmbhs/EMFileStream).

Clone EMFileStream and this repo and copy the framework to your project.

# Usage

Import the framework

```swift
import EMDataStream
```

## Write Data:

Create a stream like this:

```swift
let stream = try EMDataStream.init(size: 10)
//let stream = try EMDataStream.init() means size = 0
//let stream = try EMDataStream.init(data: Data)
```

Write some data:

```swift
try stream.write(string: name, writeSize: 20)
try stream.write(int: age)
try stream.write(float: source)
try stream.write(string: memo, writeSize: 100)
```

Seek to some position:

```swift
try stream.seek(toPosition: 10)
//Absolute deviation
try stream.seek(byPosition: 10)
//Relative deviation
```

To Data

```swift
let data = stream.toData()
```

## Read file:

Create a stream like this:

```swift
let stream = try EMDataStream.init(size: 10)
```

Read some data:

```swift
let name = try stream.readString(withSize: 20)
let age = try stream.readInt()
let source = try stream.readFloat()
let memo = try stream.readString(withSize: 100)
```

## Archive Your Object:

Use this two protocols:

```swift
public protocol EMDataStreamReadable {
    init(stream: EMDataStream) throws
}
public protocol EMDataStreamWriteable {
    func emObjectWrite(withStream stream: EMDataStream) throws
}
```

Then you can archive your own object to Data with EMDataStream!

There is a Demo:

```swift
class Student: EMDataStreamReadable, EMDataStreamWriteable {
    
    var name: String
    var age: Int
    var source: Float
    var memo: String
    
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
```

Then you can archive and unarchive your object like this

```swift
let student = Student.init(name: "Sark", age: 20, source: 78.9, memo: "Memo..........")

do {
	//archive your object
    let stream = EMDataStream.init()
    try stream.write(object: student)

	//unarchive your object
    let streamOut = EMDataStream.init(data: stream.toData())
    let stundentOut: Student = try streamOut.readObject()
	//!!!The type of `studentOut` have to be specified
	
    print(stundentOut)
} catch {
    print(error)
}
```

# HAVE FUN :)



