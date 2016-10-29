//
//  ArticleLoader.swift
//  baranov
//
//  Created by Ivan on 07/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


// 'Query' (w/o 'A') is already taken by SQLite.Swift
// so...
enum AQuery: Equatable {
    case like(String)
    case exact(String)
    case root(String)
    case rootByNr(Int)
    case none
}

func ==(lhs: AQuery, rhs:AQuery) -> Bool {
    switch (lhs, rhs) {
    case let (.like(lls), .like(rls)):
        return lls == rls
    case let (.exact(les), .exact(res)):
        return les == res
    case let (.root(lrs), .root(rrs)):
        return lrs == rrs
    case let (.rootByNr(lrnr), .rootByNr(rrnr)):
        return lrnr == rrnr
    case (.none, .none):
        return true
    default:
        return false
    }
}

func getStringFromQuery(_ query: AQuery) -> String {
    switch (query) {
    case let .like(string):
        return string
    case let .exact(string):
        return string
    case let .root(string):
        return string
    default:
        return ""
    }
}

struct QueryResult {
    let query: AQuery
    let articles: [Article]
    let sections: [SectionInfo]
}

protocol ArticleLoaderDelegate {
    func loaderWillLoad()
    func loaderDidLoad(_ queryResult: QueryResult)
}

class ArticleLoader {
    
    let myDatabase = MyDatabase.sharedInstance
    let delegate: ArticleLoaderDelegate
    
    var query: AQuery?
    var queryResult: QueryResult?
    
    
    init(delegate: ArticleLoaderDelegate) {
        self.delegate = delegate
    }
    
    func loadArticlesByQuery(_ query: AQuery) {
        self.delegate.loaderWillLoad()
        self.query = query
        
        DispatchQueue.global().async {
            
            self.queryResult = self.myDatabase.fillInArticles(self.query!)
            
            DispatchQueue.main.async(execute: {
                // make sure we get results for last submitted query
                // otherwise just ignore the result
                if (self.queryResult?.query == self.query) {
                    self.delegate.loaderDidLoad(self.queryResult!)
                }
            })
        }
    }
    
    func loadPreviousRoot() throws {
        if let q = queryResult {
            if let nr = q.articles.first?.nr, let current_root = q.articles.first?.root {
                if nr > 1 {
                    let previousRoot = try myDatabase.getPreviousRootByNr(nr, current_root: current_root)
                    loadArticlesByQuery(AQuery.root(previousRoot))
                }
            }
        }
    }
    
    func loadNextRoot() throws {
        if let q = queryResult {
            if let last_nr = q.articles.last?.nr, let first_nr = q.articles.first?.nr, let current_root = q.articles.first?.root {
                if last_nr < lastArticleNr() {
                    let nextRoot = try myDatabase.getNextRootByNr(first_nr, current_root: current_root)
                    loadArticlesByQuery(AQuery.root(nextRoot))
                }
            }
        }
    }
    
    func lastArticleNr() -> Int64? {
        return myDatabase.lastArticleNr
    }
    
    /*
     * Only for development needs
     *
     *
    func makeTranscriptionsForAll() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.myDatabase.makeTranscriptionsForAll()
            dispatch_async(dispatch_get_main_queue()) {
                println("Finish!")
            }
        }
        
    }*/
}



