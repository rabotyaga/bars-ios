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
        return self.utf16.count
    }
    
    // should filter out: \ * ( ) ? [ ] { } %
    func stripForbiddenCharacters() -> String {
        let s = self.stringByReplacingOccurrencesOfString("[\\\\\\*\\?\\$\\(\\)\\[\\]\\{\\}\\%]", withString: "", options: .RegularExpressionSearch, range: nil)
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
    
    func removeVowelsNHamza() -> String {
        var s = self.stringByReplacingOccurrencesOfString("[\\u064b\\u064c\\u064d\\u064e\\u064f\\u0650\\u0651\\u0652\\u0653\\u0670]*", withString: "", options: .RegularExpressionSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("[\\u0622\\u0623\\u0625]", withString: "\\u0627", options: .RegularExpressionSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("\\u0624", withString: "\\u0648", options: .RegularExpressionSearch, range: nil)
        s = s.stringByReplacingOccurrencesOfString("\\u0626", withString: "\\u0649", options: .RegularExpressionSearch, range: nil)
        return s
    }
    
    func format_for_query() -> String {
        return self.lowercaseString.stripForbiddenCharacters().removeVowelsNHamza()
    }
}