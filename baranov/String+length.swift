//
//  String+length.swift
//  baranov
//
//  Created by Ivan on 08/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import Foundation

extension String {
    var length: Int {
        return count(self.utf16)
    }
    
    // should filter out: \ * ( ) ? [ ] { } %
    func stripForbiddenCharacters() -> String {
        var s = self.stringByReplacingOccurrencesOfString("\\", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("*", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("?", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("%", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("(", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("{", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("}", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        return s
    }
}