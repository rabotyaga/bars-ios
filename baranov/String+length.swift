//
//  String+length.swift
//  baranov
//
//  Created by Ivan on 08/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

extension String {
    var length: Int {
        return count(self.utf16)
    }
}