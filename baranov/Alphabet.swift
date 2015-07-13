//
//  Alphabet.swift
//  baranov
//
//  Created by Ivan on 13/07/15.
//  Copyright (c) 2015 Rabotyaga. All rights reserved.
//

struct Letter {
    let nr: Int
    let nv: Int
    let letter: Character
    let notes: String
    let has_nr: Bool
    let has_all_writings: Bool
    
    init(nr: Int, nv: Int, letter: Character, notes: String, has_all_writings: Bool, has_nr: Bool) {
        self.nr = nr
        self.nv = nv
        self.letter = letter
        self.notes = notes
        self.has_nr = has_nr
        self.has_all_writings = has_all_writings
    }
    
    init(nr: Int, nv: Int, letter: Character, notes: String, has_all_writings: Bool) {
        self.init(nr: nr, nv: nv, letter: letter, notes: notes, has_all_writings: has_all_writings, has_nr: true)
    }
    
    init(nr: Int, nv: Int, letter: Character, notes: String) {
        self.init(nr: nr, nv: nv, letter: letter, notes: notes, has_all_writings: true, has_nr: true)
    }
}
