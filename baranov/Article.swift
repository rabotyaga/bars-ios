//
//  Article.swift
//  MyData
//
//  Created by Ivan on 03/07/15.
//  Copyright (c) 2015 Ivan. All rights reserved.
//

import UIKit

struct SectionInfo {
    var name: String
    var rows: Int
    var articles: [Article]
    var matchScore: Int
}

class Article {
    var nr: Int64
    var ar_inf: NSMutableAttributedString
    var ar_inf_wo_vowels: String
    var transcription: String
    var translation: NSMutableAttributedString
    var root: String
    var form: String
    var vocalization: String?
    var homonym_nr: Int64?
    var opts: NSMutableAttributedString
    /*
    var opt: String
    var ar1: String
    var ar2: String
    var ar3: String
    var mn1: String
    var mn2: String
    var mn3: String
    */
    
    init(nr:Int64, ar_inf:String, ar_inf_wo_vowels:String, transcription:String, translation:String, root:String, form:String, vocalization: String?, homonym_nr:Int64?, opt:String, ar1:String, ar2:String, ar3:String, mn1:String, mn2:String, mn3:String) {
        self.nr = nr
        self.ar_inf = NSMutableAttributedString(string: ar_inf)
        self.ar_inf_wo_vowels = ar_inf_wo_vowels
        self.transcription = transcription
        self.translation = NSMutableAttributedString(string: translation.stringByReplacingOccurrencesOfString("\\n", withString: "\n"))
        self.root = root
        self.form = form
        
        // seems there is some bug in SQLite.swift
        // it returns "\N" for NULL in vocalization
        // so here is workaround
        if (vocalization != "\\N") {
            self.vocalization = vocalization
        }
        
        self.homonym_nr = homonym_nr
        
        self.opts = NSMutableAttributedString()
        
        var opts = bidiWrapWithTrailingSpace(opt, ltr: true)
        opts += bidiWrapWithTrailingSpace(mn1, ltr: true)
        opts += bidiWrapWithTrailingSpace(ar1, ltr: false)
        opts += bidiWrapWithTrailingSpace(mn2, ltr: true)
        opts += bidiWrapWithTrailingSpace(ar2, ltr: false)
        opts += bidiWrapWithTrailingSpace(mn3, ltr: true)
        opts += bidiWrap(ar3, ltr: false)
        opts = bidiWrap(opts, ltr: true)
        
        self.opts = NSMutableAttributedString(string: opts)
        
        /*
        self.opt = opt
        self.ar1 = ar1
        self.ar2 = ar2
        self.ar3 = ar3
        self.mn1 = mn1
        self.mn2 = mn2
        self.mn3 = mn3
        */
    }
    
    private func bidiWrapWithTrailingSpace(string: String, ltr: Bool) -> String {
        var bidiWrapped = bidiWrap(string, ltr: ltr)
        if (!bidiWrapped.isEmpty) {
            bidiWrapped = bidiWrapped + " "
        }
        return bidiWrapped
    }
    
    private func bidiWrap(string: String, ltr: Bool) -> String {
        var bidiWrapped = string
        if (!bidiWrapped.isEmpty) {
            if (ltr) {
                bidiWrapped = "\u{202A}" + string + "\u{202C}"
            } else {
                bidiWrapped = "\u{202B}" + string + "\u{202C}"
            }
        }
        return bidiWrapped
    }
}
