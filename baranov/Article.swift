//
//  Article.swift
//  MyData
//
//  Created by Ivan on 03/07/15.
//  Copyright (c) 2015 Ivan. All rights reserved.
//

import UIKit

struct SectionInfo {
    var name : String
    var rows : Int
    var articles: [Article]
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
        self.translation = NSMutableAttributedString(string: translation)
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
        
        var opts = bidiWrap(opt, ltr: true)
        if (!opts.isEmpty) {
            opts += " "
        }
        opts += bidiWrap(mn1, ltr: true)
        if (opts.length > 0 && opts[opts.endIndex.predecessor()] != " ") {
            opts += " "
        }
        opts += bidiWrap(ar1, ltr: false)
        if (opts.length > 0 && opts[opts.endIndex.predecessor()] != " ") {
            opts += " "
        }
        opts += bidiWrap(mn2, ltr: true)
        if (opts.length > 0 && opts[opts.endIndex.predecessor()] != " ") {
            opts += " "
        }
        opts += bidiWrap(ar2, ltr: false)
        if (opts.length > 0 && opts[opts.endIndex.predecessor()] != " ") {
            opts += " "
        }
        opts += bidiWrap(mn3, ltr: true)
        if (opts.length > 0 && opts[opts.endIndex.predecessor()] != " ") {
            opts += " "
        }
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
