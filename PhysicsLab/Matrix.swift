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


struct IntMatrix {
    let rows: Int, columns: Int
    var grid: [Int]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: -2, count: rows * columns)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Int {
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

struct SurfaceMesh {
    var left: Float = 0.0
    var right: Float = 0.0
    var north: Float = 0.0
    var south: Float = 0.0
    
    var northR: Float = 0.0
    var northL: Float = 0.0
    var southL: Float = 0.0
    var southR: Float = 0.0
    var center: Float = 0.0
    
    var smooth: Bool = false
}

struct SurfaceMatrix {
    let rows: Int, columns: Int
    var grid: [SurfaceMesh]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        grid = Array(repeating: SurfaceMesh(), count: rows * columns)
    }
    
    func indexIsValid(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> SurfaceMesh {
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

