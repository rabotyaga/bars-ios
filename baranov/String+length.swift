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
    
    // default is rtl
    func bidiWrapped() -> String {
        return self.bidiWrapped(false)
    }
    
    func bidiWrapped(ltr: Bool) -> String {
        if (!self.isEmpty) {
            if (ltr) {
                return "\u{202A}" + self + "\u{202C}"
            } else {
                return "\u{202B}" + self + "\u{202C}"
            }
        }
        return self
    }
}