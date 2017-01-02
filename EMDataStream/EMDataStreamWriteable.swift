//
//  EMDataStreamWriteable.swift
//  EMDataStream
//
//  Created by 郑宇琦 on 2017/1/2.
//  Copyright © 2017年 Enum. All rights reserved.
//

import Foundation

public protocol EMDataStreamWriteable {
    func emObjectWrite(withStream stream: EMDataStream) throws
}
