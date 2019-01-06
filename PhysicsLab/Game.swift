//
//  Game.swift
//  PhysicsLab
//
//  Created by Tomas Nyström on 06/01/2019.
//  Copyright © 2019 Tomas Nyström. All rights reserved.
//

import Foundation

struct PlayerPosition {
    var x: Int = 0,
    y: Int = 0
}

class Game {
 
    private var gameWhiteCount: Int = 0
    private var gameRedCount: Int = 0
    private var gameMoves: Int = 0
    
    var gameWorld: CharacterMatrix!
    var gameSurface: IntMatrix!
    
    var playerSpawnPosition: PlayerPosition
    
    init() {
        playerSpawnPosition = PlayerPosition()
    }

    func getPlayerSpawnPosition() -> PlayerPosition {
        return playerSpawnPosition
    }
    
    func setPlayerSpawnPosition(x: Int, y: Int) {
        playerSpawnPosition.x = x
        playerSpawnPosition.y = y
    }
    
    func getMoves() -> Int {
        return gameMoves
    }
    
    func getWhiteCount() -> Int {
        return gameWhiteCount
    }
    
    func getRedCount() -> Int {
        return gameRedCount
    }
    
    func addMove() {
        gameMoves += 1
    }
    
    func addBox() {
        gameWhiteCount += 1
    }
    
    func boxHit() {
        gameWhiteCount -= 1
        gameRedCount += 1
    }
}
