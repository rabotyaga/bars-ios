//
//  Article.swift
//  MyData
//
//  Created by Ivan on 03/07/15.
//  Copyright (c) 2015 Ivan. All rights reserved.
//

import Foundation
import CoreData

@objc(Article)

class Article: NSManagedObject {

    @NSManaged var ar_inf: String
    @NSManaged var translation: String
    @NSManaged var nr: NSNumber
    @NSManaged var ar_inf_wo_vowels: String
    @NSManaged var form: String
    @NSManaged var root: String
    @NSManaged var opt: String
    @NSManaged var mn1: String
    @NSManaged var mn2: String
    @NSManaged var mn3: String
    @NSManaged var ar1: String
    @NSManaged var ar2: String
    @NSManaged var ar3: String

}
