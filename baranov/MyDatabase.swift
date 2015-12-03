//
//  MyDatabase.swift
//  baranov
//
//  Created by Ivan on 07/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import UIKit
import SQLite

extension Connection {
    public var userVersion: Int {
        get { return Int(scalar("PRAGMA user_version") as! Int64) }
        set { try! run("PRAGMA user_version = \(newValue)") }
    }
}

class MyDatabase {
    
    static let sharedInstance = MyDatabase()
    
    let dbFilename = "articles.db"
    
    let db: Connection
    let articles_table: Table
    let search_history_table: Table
    
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
    let arabicTextRegex = try! NSRegularExpression(pattern: arabicTextPattern, options: [])
    
    static let anyAlifPattern = "[\\u0622\\u0623\\u0625\\u0627]" //alif-madda, alif-hamza, hamza-alif, alif
    static let anyWawPattern = "[\\u0624\\u0648]" //waw-hamza, waw
    static let anyYehPattern = "[\\u0626\\u0649]" //yeh-hamza, yeh
    let anyAlifRegex = try! NSRegularExpression(pattern: anyAlifPattern, options: [])
    let anyWawRegex = try! NSRegularExpression(pattern: anyWawPattern, options: [])
    let anyYehRegex = try! NSRegularExpression(pattern: anyYehPattern, options: [])
    
    let lastArticleNr: Int64?
    
    private init() {
        let sourceFilename = (NSBundle.mainBundle().resourcePath! as NSString).stringByAppendingPathComponent(dbFilename)
        let destinationPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
        let destinationFilename = (destinationPath as NSString).stringByAppendingPathComponent(dbFilename)
        //var error: NSError?
        
        // nested func to allow code reuse in init
        // before stored properties db & articles_table are initialized
        func copyDatabase() {
            do {
                try NSFileManager.defaultManager().copyItemAtPath(sourceFilename, toPath: destinationFilename)
            } catch let error as NSError {
                print("Couldn't copy database: \(error.localizedDescription)")
            }
            let Url = NSURL.fileURLWithPath(destinationFilename)
            do {
                try Url.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
            } catch let error as NSError {
                print("Error excluding \(Url.lastPathComponent) from backup \(error.localizedDescription)")
            }

        }
        
        if (!NSFileManager.defaultManager().fileExistsAtPath(destinationFilename)) {
            copyDatabase()
        } else {
            do {
                let documentsDb = try Connection(destinationFilename)
                let resourcesDb = try Connection(sourceFilename)
                if (resourcesDb.userVersion > documentsDb.userVersion) {
                    do {
                        try NSFileManager.defaultManager().removeItemAtPath(destinationFilename)
                    } catch let error as NSError {
                        print("Couldn't remove old database in Documents directory: \(error.localizedDescription)")
                    }
                    copyDatabase()
                }
            } catch {
            }
        }
        
        
        try! db = Connection(destinationFilename)
        articles_table = Table(articles_table_name)
        lastArticleNr = db.scalar(articles_table.select(nr.max))

        search_history_table = Table(search_history_table_name)

        try! db.run(search_history_table.create(ifNotExists: true) { t in
            t.column(updated_at)
            t.column(search_string)
            t.column(details_string)
        })
        
    }
    
    func getSearchHistory(searchString: String) -> [SearchHistory] {
        var searchHistory: [SearchHistory] = []
        let q = search_history_table.filter(search_string.like("\(searchString)%")).order(updated_at.desc).limit(100)
        for s in db.prepare(q) {
            searchHistory.append(SearchHistory(searchString: s[search_string], details: s[details_string]))
        }
        return searchHistory
    }
    
    func saveSearchHistory(searchHistory: SearchHistory) {
        let sh = search_history_table.filter(search_string == searchHistory.searchString)
        let update = sh.update(details_string <- searchHistory.details, updated_at <- NSDate())
        do {
            if try db.run(update) > 0 {
                // updated, do nothing
                //print("updated history for \(searchHistory.searchString)")
            } else {
                // insert
                do {
                    try db.run(search_history_table.insert(search_string <- searchHistory.searchString, details_string <- searchHistory.details, updated_at <- NSDate()))
                    //print("inserted history for \(searchHistory.searchString)")
                } catch {
                    //print("search hist insert failed")
                }
            }
        } catch {
            //print("update failed: \(error)")
        }
    }
    
    func deleteSearchHistory(searchHistory: SearchHistory) {
        //print("delete search hist where \(searchHistory.searchString)")
        do {
            try db.run(search_history_table.filter(search_string == searchHistory.searchString).delete())
        } catch {
            //print("delete search hist where \(searchHistory.searchString) failed")
        }
    }
    
    func clearSearchHistory() {
        //print("clear Search hist")
        do {
            try db.run(search_history_table.delete())
        } catch {
            //print("clearSearchHistory failed")
        }
    }
    
    func searchHistoryCount() -> Int {
        //print("search hist count: \(db.scalar(search_history_table.count))")
        return db.scalar(search_history_table.count)
    }
    
    func fillInArticles(query: AQuery) -> QueryResult {
        //var startTime = NSDate.timeIntervalSinceReferenceDate()
        //var stopTime: NSTimeInterval = 0
        
        var searchingInArabic: Bool = true
        
        let queryRegex: NSRegularExpression?
        
        var articles: [Article] = []
        var sections: [SectionInfo] = []
        
        var f_articles: Table?
        
        switch(query) {
        case let .Like(query_string):
            if let _ = query_string.rangeOfString("^\\p{Arabic}+$", options: .RegularExpressionSearch) {
                f_articles = articles_table.filter(ar_inf_wo_vowels.like("%\(query_string.stripForbiddenCharacters())%")).order(nr)
                queryRegex = makeRegexWithVowels(query_string.stripForbiddenCharacters())
            } else {
                f_articles = articles_table.filter(translation.like("%\(query_string.stripForbiddenCharacters())%")).order(nr)
                searchingInArabic = false
                queryRegex = try? NSRegularExpression(pattern: query_string.stripForbiddenCharacters(), options: [])
            }
        case let .Exact(query_string):
            if let _ = query_string.rangeOfString("^\\p{Arabic}+$", options: .RegularExpressionSearch) {
                f_articles = articles_table.filter(query_string.stripForbiddenCharacters() == articles_table[ar_inf_wo_vowels]).order(nr)
                queryRegex = makeRegexWithVowels(query_string.stripForbiddenCharacters())
            } else {
                let qs = query_string.stripForbiddenCharacters()
                f_articles = articles_table.filter(
                    qs == translation ||
                    translation.like("\(qs) %") ||
                    translation.like("% \(qs)") ||
                    translation.like("% \(qs);%") ||
                    translation.like("% \(qs) %") ||
                    translation.like("% \(qs)!%") ||
                    translation.like("% \(qs).%") ||
                    translation.like("% \(qs),%")
                    ).order(nr)
                searchingInArabic = false
                queryRegex = try? NSRegularExpression(pattern: query_string.stripForbiddenCharacters(), options: [])
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
        //var opts: String = ""

        var current_article_match_score = 0
        
        if let unwrapped_f_articles = f_articles {
            for a in db.prepare(unwrapped_f_articles) {
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
                        for match in qRegex.matchesInString(sa.ar_inf.string, options: [], range: NSMakeRange(0, sa.ar_inf.length)) {
                            sa.ar_inf.addAttributes(matchAttr, range: match.range)
                            current_article_match_score += Int(Float(match.range.length) / Float(sa.ar_inf.string.length) * 100)
                        }
                    } else {
                        for match in qRegex.matchesInString(sa.translation.string, options: [], range: NSMakeRange(0, sa.translation.length)) {
                            sa.translation.addAttributes(matchAttr, range: match.range)
                            current_article_match_score += Int(Float(match.range.length) / Float(sa.translation.string.length) * 100)
                        }
                    }
                }
                
                //sa.translation = NSMutableAttributedString(string: "\(current_article_match_score) nr \(sa.nr)")

                sa.translation.addAttributes(translationSizeAttr, range: NSMakeRange(0, sa.translation.length))
                for match in arabicTextRegex.matchesInString(sa.translation.string, options: [], range: NSMakeRange(0, sa.translation.length)) {
                    sa.translation.addAttributes(arabicAttr, range: match.range)
                }
                
                for match in arabicTextRegex.matchesInString(sa.opts.string, options: [], range: NSMakeRange(0, sa.opts.length)) {
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
        
        sections.sortInPlace { (lhs: SectionInfo, rhs: SectionInfo) -> Bool in
            if (lhs.matchScore == rhs.matchScore) {
                return lhs.articles.first?.nr < rhs.articles.first?.nr
            }
            return lhs.matchScore > rhs.matchScore
        }
        // articles still not sorted
        // but only articles.count is used from articles
        
        //stopTime = NSDate.timeIntervalSinceReferenceDate()
        //let readTime: Double = stopTime - startTime
        
        //print("* time is \(Int(readTime*1000))")
        
        return QueryResult(query: query, articles: articles, sections: sections)
    }
    
    func getNextRootByNr(nr: Int64, current_root: String) -> String {
        if let root = db.pluck(articles_table.filter(articles_table[self.nr] > nr && articles_table[self.root] != current_root).order(self.nr).limit(1))?.get(self.root) {
            return root
        }
        return ""
    }
    
    func getPreviousRootByNr(nr: Int64, current_root: String) -> String {
        if let root = db.pluck(articles_table.filter(articles_table[self.nr] < nr && articles_table[self.root] != current_root).order(self.nr.desc).limit(1))?.get(self.root) {
            return root
        }
        return ""
    }
    
    private func makeRegexWithVowels(query: String) -> NSRegularExpression? {
        var pattern = ""

        for char in query.characters {
            var char_str: String = String([char])
            
            if let _ = anyAlifRegex.firstMatchInString(char_str, options: [], range: NSMakeRange(0, char_str.length)) {
                char_str = MyDatabase.anyAlifPattern
            } else {
                if let _ = anyWawRegex.firstMatchInString(char_str, options: [], range: NSMakeRange(0, char_str.length)) {
                    char_str = MyDatabase.anyWawPattern
                } else {
                    if let _ = anyYehRegex.firstMatchInString(char_str, options: [], range: NSMakeRange(0, char_str.length)) {
                        char_str = MyDatabase.anyYehPattern
                    }
                }
            }

            pattern = pattern + char_str + arabicVowelsPattern
        }

        let queryRegex = try? NSRegularExpression(pattern: pattern, options: [])
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
