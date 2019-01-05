//
//  Matrix.swift
//  PhysicsLab
//
//  Created by Tomas Nyström on 05/01/2019.
//  Copyright © 2019 Tomas Nyström. All rights reserved.
//

import Foundation

struct CharacterMatrix {
    let rows: Int, columns: Int
    var grid: [Character]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: " ", count: rows * columns)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Character {
        get {
            assert(indexIsValid(row: row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValid(row: row, column: column), "Index out of range")
                grid[(row * columns) + column] = newValue
        }
    }
}
