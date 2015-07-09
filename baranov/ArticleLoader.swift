//
//  ArticleLoader.swift
//  baranov
//
//  Created by Ivan on 07/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

import Foundation

// 'Query' (w/o 'A') is already taken by SQLite.Swift
// so...
enum AQuery: Equatable {
    case Like(String)
    case Exact(String)
    case Root(String)
    case RootByNr(Int)
    case None
}

func ==(lhs: AQuery, rhs:AQuery) -> Bool {
    switch (lhs, rhs) {
    case let (.Like(lls), .Like(rls)):
        return lls == rls
    case let (.Exact(les), .Exact(res)):
        return les == res
    case let (.Root(lrs), .Root(rrs)):
        return lrs == rrs
    case let (.RootByNr(lrnr), .RootByNr(rrnr)):
        return lrnr == rrnr
    case let (.None, .None):
        return true
    default:
        return false
    }
}

struct QueryResult {
    let query: AQuery
    let articles: [Article]
    let sections: [SectionInfo]
}

protocol ArticleLoaderDelegate {
    func loaderWillLoad()
    func loaderDidLoad(queryResult: QueryResult)
}

class ArticleLoader {
    
    let myDatabase = MyDatabase.sharedInstance
    let delegate: ArticleLoaderDelegate
    
    var query: AQuery?
    var queryResult: QueryResult?
    
    
    init(delegate: ArticleLoaderDelegate) {
        self.delegate = delegate
    }
    
    func loadArticlesByQuery(query: AQuery) {
        self.delegate.loaderWillLoad()
        self.query = query
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            self.queryResult = self.myDatabase.fillInArticles(self.query!)
            
            dispatch_async(dispatch_get_main_queue()) {
                // make sure we get results for last submitted query
                // otherwise just ignore the result
                if (self.queryResult?.query == self.query) {
                    self.delegate.loaderDidLoad(self.queryResult!)
                }
            }
        }
        
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



