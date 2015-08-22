//
//  MyDatabase.swift
//  baranov
//
//  Created by Ivan on 07/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit
import SQLite

class MyDatabase {
    
    static let sharedInstance = MyDatabase()
    
    let dbFilename = "articles.db"
    
    let db: Database
    let articles_table: Query
    var search_history_table: Query
    
    let articles_table_name = "articles"
    let search_history_table_name = "search_history"
    
    let nr = Expression<Int64>("nr")
    let ar_inf = Expression<String>("ar_inf")
    let ar_inf_wo_vowels = Expression<String>("ar_inf_wo_vowels")
    let transcription = Expression<String>("transcription")
    let translation = Expression<String>("translation")
    let root = Expression<String>("root")
    let form = Expression<String>("form")
    let vocalization = Expression<String?>("vocalization")
    let homonym_nr = Expression<Int64?>("homonym_nr")
    let opt = Expression<String>("opt")
    let ar1 = Expression<String>("ar1")
    let ar2 = Expression<String>("ar2")
    let ar3 = Expression<String>("ar3")
    let mn1 = Expression<String>("mn1")
    let mn2 = Expression<String>("mn2")
    let mn3 = Expression<String>("mn3")
    
    let updated_at = Expression<NSDate>("updated_at")
    let search_string = Expression<String>("search_string")
    let details_string = Expression<String>("details_string")
    
    let matchAttr = [NSBackgroundColorAttributeName : UIColor.matchBg()]
    let translationSizeAttr = [NSFontAttributeName : UIFont.translationFont()]
    let arabicAttr = [NSForegroundColorAttributeName : UIColor.arabicText()]
    
    static let arabicVowels = "[\\u064b\\u064c\\u064d\\u064e\\u064f\\u0650\\u0651\\u0652\\u0653\\u0670]"
    let arabicVowelsPattern = "\(arabicVowels)*"
    static let arabicTextPattern = "[\\p{Arabic}]+((\\s*~)*(\\s*[\\p{Arabic}]+)+)*"
    let arabicTextRegex = NSRegularExpression(pattern: arabicTextPattern, options: nil, error: nil)!
    
    static let anyAlifPattern = "[\\u0622\\u0623\\u0625\\u0627]" //alif-madda, alif-hamza, hamza-alif, alif
    static let anyWawPattern = "[\\u0624\\u0648]" //waw-hamza, waw
    static let anyYehPattern = "[\\u0626\\u0649]" //yeh-hamza, yeh
    let anyAlifRegex = NSRegularExpression(pattern: anyAlifPattern, options: nil, error: nil)!
    let anyWawRegex = NSRegularExpression(pattern: anyWawPattern, options: nil, error: nil)!
    let anyYehRegex = NSRegularExpression(pattern: anyYehPattern, options: nil, error: nil)!
    
    let lastArticleNr: Int64?
    
    private init() {
        let sourceFilename = NSBundle.mainBundle().resourcePath!.stringByAppendingPathComponent(dbFilename)
        let destinationPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
        let destinationFilename = destinationPath.stringByAppendingPathComponent(dbFilename)
        var error: NSError?
        
        // nested func to allow code reuse in init
        // before stored properties db & articles_table are initialized
        func copyDatabase() {
            if (!NSFileManager.defaultManager().copyItemAtPath(sourceFilename, toPath: destinationFilename, error: &error)) {
                println("Couldn't copy database: \(error!.localizedDescription)")
            }
            let Url = NSURL.fileURLWithPath(destinationFilename)!
            if (!Url.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey, error: &error)) {
                println("Error excluding \(Url.lastPathComponent) from backup \(error!.localizedDescription)")
            }
        }
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(destinationFilename)) {
            copyDatabase()
        } else {
            let documentsDb = Database(destinationFilename)
            let resourcesDb = Database(sourceFilename)
            if (resourcesDb.userVersion > documentsDb.userVersion) {
                if(!NSFileManager.defaultManager().removeItemAtPath(destinationFilename, error: &error)) {
                    println("Couldn't remove old database in Documents directory: \(error!.localizedDescription)")
                }
                copyDatabase()
            }
        }
        
        db = Database(destinationFilename)
        articles_table = db[articles_table_name]
        lastArticleNr = articles_table.max(nr)
        
        search_history_table = db[search_history_table_name]
        
        db.create(table: search_history_table, ifNotExists: true) { t in
            t.column(updated_at)
            t.column(search_string)
            t.column(details_string)
        }
    }
    
    func getSearchHistory(searchString: String) -> [SearchHistory] {
        var searchHistory: [SearchHistory] = []
        var q = search_history_table.filter(like("\(searchString)%", search_string)).order(updated_at.desc).limit(100)
        for s in q {
            searchHistory.append(SearchHistory(searchString: s[search_string], details: s[details_string]))
        }
        return searchHistory
    }
    
    func saveSearchHistory(searchHistory: SearchHistory) {
        let sh = search_history_table.filter(search_string == searchHistory.searchString)
        let update = sh.update(details_string <- searchHistory.details, updated_at <- NSDate())
        if let changes = update.changes where changes > 0 {
            // updated, do nothing
            //println("updated history for \(searchHistory.searchString)")
        } else {
            // insert
            search_history_table.insert(search_string <- searchHistory.searchString, details_string <- searchHistory.details, updated_at <- NSDate())
            //println("inserted history for \(searchHistory.searchString)")
        }
    }
    
    func deleteSearchHistory(searchHistory: SearchHistory) {
        search_history_table.filter(search_string == searchHistory.searchString).delete()
    }
    
    func clearSearchHistory() {
        search_history_table.delete()
    }
    
    func searchHistoryCount() -> Int {
        return search_history_table.count
    }
    
    func fillInArticles(query: AQuery) -> QueryResult {
        var startTime = NSDate.timeIntervalSinceReferenceDate()
        var stopTime: NSTimeInterval = 0
        
        var searchingInArabic: Bool = true
        
        let queryRegex: NSRegularExpression?
        
        var articles: [Article] = []
        var sections: [SectionInfo] = []
        
        var f_articles: Query?
        
        switch(query) {
        case let .Like(query_string):
            if let match = query_string.rangeOfString("^\\p{Arabic}+$", options: .RegularExpressionSearch) {
                f_articles = articles_table.filter(like("%\(query_string.stripForbiddenCharacters())%", ar_inf_wo_vowels)).order(nr)
                queryRegex = makeRegexWithVowels(query_string.stripForbiddenCharacters())
            } else {
                f_articles = articles_table.filter(like("%\(query_string.stripForbiddenCharacters())%", translation)).order(nr)
                searchingInArabic = false
                queryRegex = NSRegularExpression(pattern: query_string.stripForbiddenCharacters(), options: nil, error: nil)
            }
        case let .Exact(query_string):
            if let match = query_string.rangeOfString("^\\p{Arabic}+$", options: .RegularExpressionSearch) {
                f_articles = articles_table.filter(query_string.stripForbiddenCharacters() == articles_table[ar_inf_wo_vowels]).order(nr)
                queryRegex = makeRegexWithVowels(query_string.stripForbiddenCharacters())
            } else {
                let qs = query_string.stripForbiddenCharacters()
                f_articles = articles_table.filter(
                    qs == translation ||
                    like("\(qs) %", translation) ||
                    like("% \(qs)", translation) ||
                    like("% \(qs);%", translation) ||
                    like("% \(qs) %", translation) ||
                    like("% \(qs)!%", translation) ||
                    like("% \(qs).%", translation) ||
                    like("% \(qs),%", translation)
                    ).order(nr)
                searchingInArabic = false
                queryRegex = NSRegularExpression(pattern: query_string.stripForbiddenCharacters(), options: nil, error: nil)
            }
        case let .Root(root_to_load):
            f_articles = articles_table.filter(root_to_load == articles_table[root]).order(nr)
            queryRegex = nil
        default:
            queryRegex = nil
            f_articles = nil
        }
        
        var i = 0
        var sa: Article
        var si = 0
        var current_section = SectionInfo(name: "", rows: 0, articles: [], matchScore: 0)
        var opts: String = ""

        var current_article_match_score = 0
        
        if let unwrapped_f_articles = f_articles {
            for a in unwrapped_f_articles {
                sa = Article.init(
                    nr: a[nr],
                    ar_inf: a[ar_inf],
                    ar_inf_wo_vowels: a[ar_inf_wo_vowels],
                    transcription: a[transcription],
                    translation: a[translation],
                    root: a[root],
                    form: a[form],
                    vocalization: a[vocalization],
                    homonym_nr: a[homonym_nr],
                    opt: a[opt],
                    ar1: a[ar1],
                    ar2: a[ar2],
                    ar3: a[ar3],
                    mn1: a[mn1],
                    mn2: a[mn2],
                    mn3: a[mn3]
                )
                
                current_article_match_score = 0
                if let qRegex = queryRegex {
                    if (searchingInArabic) {
                        for match in qRegex.matchesInString(sa.ar_inf.string, options: nil, range: NSMakeRange(0, sa.ar_inf.length)) as! [NSTextCheckingResult] {
                            sa.ar_inf.addAttributes(matchAttr, range: match.range)
                            current_article_match_score += Int(Float(match.range.length) / Float(sa.ar_inf.string.length) * 100)
                        }
                    } else {
                        for match in qRegex.matchesInString(sa.translation.string, options: nil, range: NSMakeRange(0, sa.translation.length)) as! [NSTextCheckingResult] {
                            sa.translation.addAttributes(matchAttr, range: match.range)
                            current_article_match_score += Int(Float(match.range.length) / Float(sa.translation.string.length) * 100)
                        }
                    }
                }
                
                //sa.translation = NSMutableAttributedString(string: "\(current_article_match_score) nr \(sa.nr)")

                sa.translation.addAttributes(translationSizeAttr, range: NSMakeRange(0, sa.translation.length))
                for match in arabicTextRegex.matchesInString(sa.translation.string, options: nil, range: NSMakeRange(0, sa.translation.length)) {
                    sa.translation.addAttributes(arabicAttr, range: match.range)
                }
                
                for match in arabicTextRegex.matchesInString(sa.opts.string, options: nil, range: NSMakeRange(0, sa.opts.length)) {
                    sa.opts.addAttributes(arabicAttr, range: match.range)
                }
                
                if (i == 0) {
                    current_section = SectionInfo(name: sa.root, rows: 0, articles: [sa], matchScore: current_article_match_score)
                    si++
                } else {
                    if (sa.root == current_section.name) {
                        current_section.articles.append(sa)
                        if (current_section.matchScore < current_article_match_score) {
                            current_section.matchScore = current_article_match_score
                        }
                        si++
                    } else {
                        current_section.rows = si
                        sections.append(current_section)
                        current_section = SectionInfo(name: sa.root, rows: 0, articles: [sa], matchScore: current_article_match_score)
                        si = 1
                    }
                }
                articles.append(sa)
                i++
            }
        }
        if (articles.count > 0) {
            current_section.rows = si
            sections.append(current_section)
        }
        
        sections.sort { (lhs: SectionInfo, rhs: SectionInfo) -> Bool in
            if (lhs.matchScore == rhs.matchScore) {
                return lhs.articles.first?.nr < rhs.articles.first?.nr
            }
            return lhs.matchScore > rhs.matchScore
        }
        // articles still not sorted
        // but only articles.count is used from articles
        
        stopTime = NSDate.timeIntervalSinceReferenceDate()
        var readTime: Double = stopTime - startTime
        
        //println("* time is \(Int(readTime*1000))")
        
        return QueryResult(query: query, articles: articles, sections: sections)
    }
    
    func getNextRootByNr(nr: Int64, current_root: String) -> String {
        if let root = articles_table.filter(articles_table[self.nr] > nr && articles_table[self.root] != current_root).order(self.nr).limit(1).first?.get(self.root) {
            return root
        }
        return ""
    }
    
    func getPreviousRootByNr(nr: Int64, current_root: String) -> String {
        if let root = articles_table.filter(articles_table[self.nr] < nr && articles_table[self.root] != current_root).order(self.nr.desc).limit(1).first?.get(self.root) {
            return root
        }
        return ""
    }
    
    private func makeRegexWithVowels(query: String) -> NSRegularExpression? {
        var pattern = ""

        for char in query {
            var char_str: String = "" + [char]
            
            if let match = anyAlifRegex.firstMatchInString(char_str, options: nil, range: NSMakeRange(0, char_str.length)) {
                char_str = MyDatabase.anyAlifPattern
            } else {
                if let match = anyWawRegex.firstMatchInString(char_str, options: nil, range: NSMakeRange(0, char_str.length)) {
                    char_str = MyDatabase.anyWawPattern
                } else {
                    if let match = anyYehRegex.firstMatchInString(char_str, options: nil, range: NSMakeRange(0, char_str.length)) {
                        char_str = MyDatabase.anyYehPattern
                    }
                }
            }

            pattern = pattern + char_str + arabicVowelsPattern
        }

        var queryRegex = NSRegularExpression(pattern: pattern, options: nil, error: nil)
        return queryRegex
    }
    
    
    /*
     * Only for development needs
     *
     *
    func makeTranscriptionsForAll() {
        var tr: CFMutableStringRef
        var tr_str: String
        var i = 0
        for article in articles_table.select(nr, ar_inf) {
            tr = NSMutableString(string: article[ar_inf]) as CFMutableStringRef
            CFStringTransform(tr, nil, kCFStringTransformToLatin, Boolean(0))
            tr_str = tr as String
            articles_table.filter(article[nr] == articles_table[nr]).update(transcription <- tr_str)
            i++
            println("\(i): \(tr_str)")
        }
    }*/
}
