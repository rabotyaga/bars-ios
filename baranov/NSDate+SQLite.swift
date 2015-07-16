//
//  NSDate+SQLite.swift
//  baranov
//
//  Created by Ivan on 16/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import Foundation
import SQLite

extension NSDate: Value {
    public class var declaredDatatype: String {
        return Int.declaredDatatype
    }
    public class func fromDatatypeValue(intValue: Int) -> Self {
        return self(timeIntervalSince1970: NSTimeInterval(intValue))
    }
    public var datatypeValue: Int {
        return Int(timeIntervalSince1970)
    }
}