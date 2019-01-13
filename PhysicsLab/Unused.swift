//
//  Unused.swift
//  PhysicsLab
//
//  Created by Tomas Nyström on 12/01/2019.
//  Copyright © 2019 Tomas Nyström. All rights reserved.
//

import Foundation

/*
// mode = 0, raise up surface around
// mode = 1, raise up only the one brick
// mode = height multiplier (default 1.0)

func createSurface(x: Int, y: Int, mul: Float) {
    
    let indices: [UInt16] = [
        0, 1, 2,
        2, 3, 0,
        3, 4, 0,
        4, 5, 0,
        5, 6, 0,
        6, 7, 0,
        7, 8, 0,
        8, 1, 0
    ]
    
    var vertices: [SCNVector3] = []
    
    
    // Debug entry
    let color: UIColor = UIColor.blue
    /*
     if (_h == 8) {
     color = UIColor.red
     }
     */
    
    var northS: Float = 0.0
    var southS: Float = 0.0
    var leftS: Float = 0.0
    var rightS: Float = 0.0
    
    // Apply smoothing to verices
    if (gameRun.surfaceMatrix[y,x].smooth ==  true) {
        
        if (y > 0) {
            if (gameRun.surfaceMatrix[y - 1,x].smooth ==  true &&
                gameRun.surfaceMatrix[y - 1,x].center == gameRun.surfaceMatrix[y,x].center) {
                northS = -0.5
            }
        }
        
        if (y < gameRun.gameSurface.rows - 1) {
            if (gameRun.surfaceMatrix[y + 1,x].smooth ==  true &&
                gameRun.surfaceMatrix[y + 1,x].center == gameRun.surfaceMatrix[y,x].center) {
                southS = -0.5
            }
            
        }
        
        if (x > 0) {
            if (gameRun.surfaceMatrix[y,x - 1].smooth ==  true &&
                gameRun.surfaceMatrix[y, x - 1].center == gameRun.surfaceMatrix[y,x].center) {
                leftS = -0.5
            }
        }
        
        if (x < gameRun.gameSurface.columns - 1) {
            
            if (gameRun.surfaceMatrix[y,x + 1].smooth ==  true &&
                gameRun.surfaceMatrix[y,x + 1].center == gameRun.surfaceMatrix[y,x].center) {
                rightS = -0.5
            }
        }
        
        vertices.append(SCNVector3(1, (gameRun.surfaceMatrix[y,x].center - 0.5) * mul, 1))
        
    } else {
        vertices.append(SCNVector3(1, gameRun.surfaceMatrix[y,x].center * mul, 1))
    }
    
    vertices.append(SCNVector3(2, gameRun.surfaceMatrix[y,x].northR * mul, 0))
    vertices.append(SCNVector3(1, (gameRun.surfaceMatrix[y,x].north + northS) * mul, 0))
    vertices.append(SCNVector3(0, gameRun.surfaceMatrix[y,x].northL * mul, 0))
    vertices.append(SCNVector3(0, (gameRun.surfaceMatrix[y,x].left + leftS) * mul, 1))
    vertices.append(SCNVector3(0, gameRun.surfaceMatrix[y,x].southL * mul, 2))
    vertices.append(SCNVector3(1, (gameRun.surfaceMatrix[y,x].south + southS) * mul, 2))
    vertices.append(SCNVector3(2, gameRun.surfaceMatrix[y,x].southR * mul, 2))
    vertices.append(SCNVector3(2, (gameRun.surfaceMatrix[y,x].right + rightS) * mul, 1))
    
    
    let source = SCNGeometrySource(vertices: vertices)
    let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
    let geometry = SCNGeometry(sources: [source], elements: [element])
    geometry.materials.first?.diffuse.contents = color
    geometry.materials.first?.locksAmbientWithDiffuse = true
    let geometryNode = SCNNode(geometry: geometry)
    geometryNode.position = SCNVector3(Float(x)*2-1, 0, Float(y)*2-1)
    geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
    geometryNode.castsShadow = false
    geometryNode.name = "Floor"
    gameBoardFloor.addChildNode(geometryNode)
}


func createPlane(x: Int, y: Int, xOff: Float, yOff: Float, zOff: Float, angles: SCNVector3, color: UIColor) -> SCNNode {
    let geometry = SCNPlane(width: 2.0, height: 2.0)
    geometry.materials.first?.diffuse.contents = color
    let geometryNode = SCNNode(geometry: geometry)
    geometryNode.position = SCNVector3(Float(x)*2 + xOff, yOff, Float(y)*2 + zOff)
    geometryNode.eulerAngles = angles
    geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
    geometryNode.castsShadow = false
    return geometryNode
}

func createRaisedFloor(x: Int, y: Int) {
    let geometry = SCNPyramid(width: 2.0, height: 2.0, length: 2.0)
    geometry.materials.first?.diffuse.contents = UIColor.blue
    let geometryNode = SCNNode(geometry: geometry)
    geometryNode.position = SCNVector3(Float(x)*2, 0.0, Float(y)*2)
    geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
    geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
    geometryNode.castsShadow = false
    geometryNode.name = "Floor"
    
    gameBoardFloor.addChildNode(geometryNode)
}

 
 func createFloor(x: Int, y: Int) {
 let geometryNode = createPlane(x: x, y: y, xOff: 0.0, yOff: 0.0, zOff: 0.0, angles: SCNVector3(-Float.pi/2,0,0), color: UIColor.blue)
 geometryNode.name = "Floor"
 gameBoardFloor.addChildNode(geometryNode)
 }
 
 
 func smoothSurfaceMatrix(x: Int, y: Int) {
 
 // look for three in a row in x-direction
 if(gameRun.surfaceMatrix.rows > x + 2) {
 
 // Look for a width of 2 at min
 if(gameRun.surfaceMatrix.columns > y + 2) {
 
 // Is there a parallel one row down at the same level?
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y+1,x].center){
 
 // Left to Right
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y,x+1].center - 1) {
 
 // One higher
 if (gameRun.surfaceMatrix[y,x+1].center == gameRun.surfaceMatrix[y,x+2].center - 1) {
 
 // Second row
 if (gameRun.surfaceMatrix[y+1,x].center == gameRun.surfaceMatrix[y+1,x+1].center - 1) {
 
 // One higher
 if (gameRun.surfaceMatrix[y+1,x+1].center == gameRun.surfaceMatrix[y+1,x+2].center - 1) {
 
 // 3x * 2y slope found
 
 // Smooth second set of mid points
 gameRun.surfaceMatrix[y,x+1].smooth = true
 gameRun.surfaceMatrix[y,x+2].smooth = true
 gameRun.surfaceMatrix[y+1,x+1].smooth = true
 gameRun.surfaceMatrix[y+1,x+2].smooth = true
 
 
 }
 }
 }
 }
 
 // Right to left
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y,x+1].center + 1) {
 
 // One more
 if (gameRun.surfaceMatrix[y,x+1].center == gameRun.surfaceMatrix[y,x+2].center + 1) {
 
 // And second row
 if (gameRun.surfaceMatrix[y+1,x].center == gameRun.surfaceMatrix[y+1,x+1].center + 1) {
 
 // And last one
 if (gameRun.surfaceMatrix[y+1,x+1].center == gameRun.surfaceMatrix[y+1,x+2].center + 1) {
 
 // 3x * 2y slope found
 // Smooth first set of mid points
 gameRun.surfaceMatrix[y,x].smooth = true
 gameRun.surfaceMatrix[y,x+1].smooth = true
 gameRun.surfaceMatrix[y+1,x].smooth = true
 gameRun.surfaceMatrix[y+1,x+1].smooth = true
 
 }
 }
 }
 }
 
 }
 
 // Is there a parallel one column down?
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y,x+1].center) {
 
 // North to south
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y+1,x].center + 1) {
 
 // Next one is one down
 if (gameRun.surfaceMatrix[y+1,x].center == gameRun.surfaceMatrix[y+2,x].center + 1) {
 
 // Second column
 if (gameRun.surfaceMatrix[y,x+1].center == gameRun.surfaceMatrix[y+1,x+1].center + 1) {
 
 // And last one
 if (gameRun.surfaceMatrix[y+1,x+1].center == gameRun.surfaceMatrix[y+2,x+1].center + 1) {
 
 // 3x * 2y slope found
 // Smooth first set of mid points
 gameRun.surfaceMatrix[y,x].smooth = true
 gameRun.surfaceMatrix[y,x+1].smooth = true
 gameRun.surfaceMatrix[y+1,x].smooth = true
 gameRun.surfaceMatrix[y+1,x+1].smooth = true
 
 }
 }
 }
 }
 
 // South to North
 
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y+1,x].center - 1) {
 
 // Next one is one down
 if (gameRun.surfaceMatrix[y+1,x].center == gameRun.surfaceMatrix[y+2,x].center - 1) {
 
 // Second column
 if (gameRun.surfaceMatrix[y,x+1].center == gameRun.surfaceMatrix[y+1,x+1].center - 1) {
 
 // And last one
 if (gameRun.surfaceMatrix[y+1,x+1].center == gameRun.surfaceMatrix[y+2,x+1].center - 1) {
 
 // 3x * 2y slope found
 // Smooth first set of mid points
 gameRun.surfaceMatrix[y+1,x].smooth = true
 gameRun.surfaceMatrix[y+1,x+1].smooth = true
 gameRun.surfaceMatrix[y+2,x].smooth = true
 gameRun.surfaceMatrix[y+2,x+1].smooth = true
 
 }
 }
 }
 }
 }
 
 }
 
 }
 }
 
 // mode = 0, raise up surface around
 // mode = 1, raise up only the one brick
 // mode = height multiplier (default 1.0)
 
 func createSurfaceMatrix(x: Int, y: Int, mode: Int) {
 
 
 let gameSurface: IntMatrix! = gameRun.gameSurface
 
 let _h: Float = Float(gameSurface![y,x])
 
 // Check if any surrounding area is one higher
 var diffN: Float = 0.0
 var diffS: Float = 0.0
 var diffL: Float = 0.0
 var diffR: Float = 0.0
 
 var diffNL: Float = 0.0
 var diffSL: Float = 0.0
 var diffSR: Float = 0.0
 var diffNR: Float = 0.0
 
 // North side
 if(y > 0) { diffN = Float(gameSurface[y-1,x]) - _h }
 
 // Left side
 if(x > 0) { diffL = Float(gameSurface [y,x-1]) - _h }
 
 // South side
 if(gameSurface.rows > y) { diffS = Float(gameSurface[y+1,x]) - _h}
 
 // Right side
 if(x < (gameSurface.columns - 1)) { diffR = Float(gameSurface[y,x+1]) - _h }
 
 // North left side
 if(y > 0 && x > 0) { diffNL = Float(gameSurface[y-1,x-1]) - _h }
 
 // South left side
 if(gameSurface.rows > y && x > 0) { diffSL = Float(gameSurface[y+1,x-1]) - _h }
 
 // South right side
 if(gameSurface.rows > y && x < (gameSurface.columns - 1)) { diffSR = Float(gameSurface[y+1,x+1]) - _h }
 
 // North right side
 if(y > 0 && x < (gameSurface.columns - 1)) { diffNR = Float(gameSurface[y-1,x+1]) - _h }
 
 var left: Float = 0.0
 var right: Float = 0.0
 var north: Float = 0.0
 var south: Float = 0.0
 
 var northR: Float = 0.0
 var northL: Float = 0.0
 var southL: Float = 0.0
 var southR: Float = 0.0
 
 var diff: Float = 0.0 // Center point - renme to center
 
 if (mode == 1) {
 
 if (diffL <= 0) {
 if ([diffN, diffNL, diffSL, diffS].max()! > 0) {
 left = ([diffN, diffNL, diffSL, diffS].max()!) / 2
 } else {
 left = 0.0
 }
 } else {
 if  ([diffN, diffNL, diffSL, diffS].max()! > diffL) {
 left = ([diffN, diffNL, diffSL, diffS].max()! - diffL) / 2 + diffL
 } else {
 left = diffL
 }
 }
 
 if (diffR <= 0) {
 if ([diffN, diffNR, diffSR, diffS].max()! > 0) {
 right = ([diffN, diffNR, diffSR, diffS].max()!) / 2
 } else {
 right = 0.0
 }
 } else {
 if ([diffN, diffNR, diffSR, diffS].max()! > diffR) {
 right = ([diffN, diffNR, diffSR, diffS].max()! - diffR) / 2 + diffR
 } else {
 right = diffR
 }
 }
 
 
 if (diffN <= 0) {
 if ([diffL, diffNL, diffR, diffNR].max()! > 0) {
 north = ([diffL, diffNL, diffR, diffNR].max()!) / 2
 } else {
 north = 0.0
 }
 } else {
 if ([diffL, diffNL, diffR, diffNR].max()! > diffN) {
 north = ([diffL, diffNL, diffR, diffNR].max()! - diffN) / 2 + diffN
 } else {
 north = diffN
 }
 }
 
 if (diffS <= 0) {
 if ([diffL, diffSL, diffR, diffSR].max()! > 0) {
 south = ([diffL, diffSL, diffR, diffSR].max()!) / 2
 } else {
 south = 0.0
 }
 } else {
 if ([diffL, diffSL, diffR, diffSR].max()! > diffS) {
 south = ([diffL, diffSL, diffR, diffSR].max()! - diffS) / 2 + diffS
 } else {
 south = diffS
 }
 
 }
 
 // Center point
 
 let diffMax: Float = [diffN, diffS, diffR, diffL, diffNL, diffSL, diffSR, diffNR].max()!
 
 if(diffMax != 0) { diff = diffMax / 2 }
 if(diffMax < 0) { diff = -diffMax / 2 } // Pointy end to highest peak
 
 northR = [diffN, diffR, diffNR, 0].max()!
 northL = [diffN, diffL, diffNL, 0].max()!
 southL = [diffS, diffL, diffSL, 0].max()!
 southR = [diffS, diffR, diffSR, 0].max()!
 
 } else if (mode == 2) {
 
 diff = 0.0
 
 // Corner needs to be the lowest
 northR = [diffN, diffR, diffNR, 0].min()!
 northL = [diffN, diffL, diffNL, 0].min()!
 southL = [diffS, diffL, diffSL, 0].min()!
 southR = [diffS, diffR, diffSR, 0].min()!
 
 
 // Go down and meet the lower level
 if (diffR < 0) {right = diffR}
 if (diffL < 0) {left = diffL}
 if (diffN < 0) {north = diffN}
 if (diffS < 0) {south = diffS}
 
 }
 
 gameRun.surfaceMatrix[y,x].center = (_h + diff)
 gameRun.surfaceMatrix[y,x].northR = (_h + northR)
 gameRun.surfaceMatrix[y,x].north = (_h + north)
 gameRun.surfaceMatrix[y,x].northL = (_h + northL)
 gameRun.surfaceMatrix[y,x].left = (_h + left)
 gameRun.surfaceMatrix[y,x].southL = (_h + southL)
 gameRun.surfaceMatrix[y,x].south = (_h + south)
 gameRun.surfaceMatrix[y,x].southR = (_h + southR)
 gameRun.surfaceMatrix[y,x].right = (_h + right)
 
 }
 
 
 func createFloor(x: Int, y: Int) {
 let geometryNode = createPlane(x: x, y: y, xOff: 0.0, yOff: 0.0, zOff: 0.0, angles: SCNVector3(-Float.pi/2,0,0), color: UIColor.blue)
 geometryNode.name = "Floor"
 gameBoardFloor.addChildNode(geometryNode)
 }
 
 
 func smoothSurfaceMatrix(x: Int, y: Int) {
 
 // look for three in a row in x-direction
 if(gameRun.surfaceMatrix.rows > x + 2) {
 
 // Look for a width of 2 at min
 if(gameRun.surfaceMatrix.columns > y + 2) {
 
 // Is there a parallel one row down at the same level?
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y+1,x].center){
 
 // Left to Right
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y,x+1].center - 1) {
 
 // One higher
 if (gameRun.surfaceMatrix[y,x+1].center == gameRun.surfaceMatrix[y,x+2].center - 1) {
 
 // Second row
 if (gameRun.surfaceMatrix[y+1,x].center == gameRun.surfaceMatrix[y+1,x+1].center - 1) {
 
 // One higher
 if (gameRun.surfaceMatrix[y+1,x+1].center == gameRun.surfaceMatrix[y+1,x+2].center - 1) {
 
 // 3x * 2y slope found
 
 // Smooth second set of mid points
 gameRun.surfaceMatrix[y,x+1].smooth = true
 gameRun.surfaceMatrix[y,x+2].smooth = true
 gameRun.surfaceMatrix[y+1,x+1].smooth = true
 gameRun.surfaceMatrix[y+1,x+2].smooth = true
 
 
 }
 }
 }
 }
 
 // Right to left
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y,x+1].center + 1) {
 
 // One more
 if (gameRun.surfaceMatrix[y,x+1].center == gameRun.surfaceMatrix[y,x+2].center + 1) {
 
 // And second row
 if (gameRun.surfaceMatrix[y+1,x].center == gameRun.surfaceMatrix[y+1,x+1].center + 1) {
 
 // And last one
 if (gameRun.surfaceMatrix[y+1,x+1].center == gameRun.surfaceMatrix[y+1,x+2].center + 1) {
 
 // 3x * 2y slope found
 // Smooth first set of mid points
 gameRun.surfaceMatrix[y,x].smooth = true
 gameRun.surfaceMatrix[y,x+1].smooth = true
 gameRun.surfaceMatrix[y+1,x].smooth = true
 gameRun.surfaceMatrix[y+1,x+1].smooth = true
 
 }
 }
 }
 }
 
 }
 
 // Is there a parallel one column down?
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y,x+1].center) {
 
 // North to south
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y+1,x].center + 1) {
 
 // Next one is one down
 if (gameRun.surfaceMatrix[y+1,x].center == gameRun.surfaceMatrix[y+2,x].center + 1) {
 
 // Second column
 if (gameRun.surfaceMatrix[y,x+1].center == gameRun.surfaceMatrix[y+1,x+1].center + 1) {
 
 // And last one
 if (gameRun.surfaceMatrix[y+1,x+1].center == gameRun.surfaceMatrix[y+2,x+1].center + 1) {
 
 // 3x * 2y slope found
 // Smooth first set of mid points
 gameRun.surfaceMatrix[y,x].smooth = true
 gameRun.surfaceMatrix[y,x+1].smooth = true
 gameRun.surfaceMatrix[y+1,x].smooth = true
 gameRun.surfaceMatrix[y+1,x+1].smooth = true
 
 }
 }
 }
 }
 
 // South to North
 
 if (gameRun.surfaceMatrix[y,x].center == gameRun.surfaceMatrix[y+1,x].center - 1) {
 
 // Next one is one down
 if (gameRun.surfaceMatrix[y+1,x].center == gameRun.surfaceMatrix[y+2,x].center - 1) {
 
 // Second column
 if (gameRun.surfaceMatrix[y,x+1].center == gameRun.surfaceMatrix[y+1,x+1].center - 1) {
 
 // And last one
 if (gameRun.surfaceMatrix[y+1,x+1].center == gameRun.surfaceMatrix[y+2,x+1].center - 1) {
 
 // 3x * 2y slope found
 // Smooth first set of mid points
 gameRun.surfaceMatrix[y+1,x].smooth = true
 gameRun.surfaceMatrix[y+1,x+1].smooth = true
 gameRun.surfaceMatrix[y+2,x].smooth = true
 gameRun.surfaceMatrix[y+2,x+1].smooth = true
 
 }
 }
 }
 }
 }
 
 }
 
 }
 }
 
 // mode = 0, raise up surface around
 // mode = 1, raise up only the one brick
 // mode = height multiplier (default 1.0)
 
 func createSurfaceMatrix(x: Int, y: Int, mode: Int) {
 
 
 let gameSurface: IntMatrix! = gameRun.gameSurface
 
 let _h: Float = Float(gameSurface![y,x])
 
 // Check if any surrounding area is one higher
 var diffN: Float = 0.0
 var diffS: Float = 0.0
 var diffL: Float = 0.0
 var diffR: Float = 0.0
 
 var diffNL: Float = 0.0
 var diffSL: Float = 0.0
 var diffSR: Float = 0.0
 var diffNR: Float = 0.0
 
 // North side
 if(y > 0) { diffN = Float(gameSurface[y-1,x]) - _h }
 
 // Left side
 if(x > 0) { diffL = Float(gameSurface [y,x-1]) - _h }
 
 // South side
 if(gameSurface.rows > y) { diffS = Float(gameSurface[y+1,x]) - _h}
 
 // Right side
 if(x < (gameSurface.columns - 1)) { diffR = Float(gameSurface[y,x+1]) - _h }
 
 // North left side
 if(y > 0 && x > 0) { diffNL = Float(gameSurface[y-1,x-1]) - _h }
 
 // South left side
 if(gameSurface.rows > y && x > 0) { diffSL = Float(gameSurface[y+1,x-1]) - _h }
 
 // South right side
 if(gameSurface.rows > y && x < (gameSurface.columns - 1)) { diffSR = Float(gameSurface[y+1,x+1]) - _h }
 
 // North right side
 if(y > 0 && x < (gameSurface.columns - 1)) { diffNR = Float(gameSurface[y-1,x+1]) - _h }
 
 var left: Float = 0.0
 var right: Float = 0.0
 var north: Float = 0.0
 var south: Float = 0.0
 
 var northR: Float = 0.0
 var northL: Float = 0.0
 var southL: Float = 0.0
 var southR: Float = 0.0
 
 var diff: Float = 0.0 // Center point - renme to center
 
 if (mode == 1) {
 
 if (diffL <= 0) {
 if ([diffN, diffNL, diffSL, diffS].max()! > 0) {
 left = ([diffN, diffNL, diffSL, diffS].max()!) / 2
 } else {
 left = 0.0
 }
 } else {
 if  ([diffN, diffNL, diffSL, diffS].max()! > diffL) {
 left = ([diffN, diffNL, diffSL, diffS].max()! - diffL) / 2 + diffL
 } else {
 left = diffL
 }
 }
 
 if (diffR <= 0) {
 if ([diffN, diffNR, diffSR, diffS].max()! > 0) {
 right = ([diffN, diffNR, diffSR, diffS].max()!) / 2
 } else {
 right = 0.0
 }
 } else {
 if ([diffN, diffNR, diffSR, diffS].max()! > diffR) {
 right = ([diffN, diffNR, diffSR, diffS].max()! - diffR) / 2 + diffR
 } else {
 right = diffR
 }
 }
 
 
 if (diffN <= 0) {
 if ([diffL, diffNL, diffR, diffNR].max()! > 0) {
 north = ([diffL, diffNL, diffR, diffNR].max()!) / 2
 } else {
 north = 0.0
 }
 } else {
 if ([diffL, diffNL, diffR, diffNR].max()! > diffN) {
 north = ([diffL, diffNL, diffR, diffNR].max()! - diffN) / 2 + diffN
 } else {
 north = diffN
 }
 }
 
 if (diffS <= 0) {
 if ([diffL, diffSL, diffR, diffSR].max()! > 0) {
 south = ([diffL, diffSL, diffR, diffSR].max()!) / 2
 } else {
 south = 0.0
 }
 } else {
 if ([diffL, diffSL, diffR, diffSR].max()! > diffS) {
 south = ([diffL, diffSL, diffR, diffSR].max()! - diffS) / 2 + diffS
 } else {
 south = diffS
 }
 
 }
 
 // Center point
 
 let diffMax: Float = [diffN, diffS, diffR, diffL, diffNL, diffSL, diffSR, diffNR].max()!
 
 if(diffMax != 0) { diff = diffMax / 2 }
 if(diffMax < 0) { diff = -diffMax / 2 } // Pointy end to highest peak
 
 northR = [diffN, diffR, diffNR, 0].max()!
 northL = [diffN, diffL, diffNL, 0].max()!
 southL = [diffS, diffL, diffSL, 0].max()!
 southR = [diffS, diffR, diffSR, 0].max()!
 
 } else if (mode == 2) {
 
 diff = 0.0
 
 // Corner needs to be the lowest
 northR = [diffN, diffR, diffNR, 0].min()!
 northL = [diffN, diffL, diffNL, 0].min()!
 southL = [diffS, diffL, diffSL, 0].min()!
 southR = [diffS, diffR, diffSR, 0].min()!
 
 
 // Go down and meet the lower level
 if (diffR < 0) {right = diffR}
 if (diffL < 0) {left = diffL}
 if (diffN < 0) {north = diffN}
 if (diffS < 0) {south = diffS}
 
 }
 
 gameRun.surfaceMatrix[y,x].center = (_h + diff)
 gameRun.surfaceMatrix[y,x].northR = (_h + northR)
 gameRun.surfaceMatrix[y,x].north = (_h + north)
 gameRun.surfaceMatrix[y,x].northL = (_h + northL)
 gameRun.surfaceMatrix[y,x].left = (_h + left)
 gameRun.surfaceMatrix[y,x].southL = (_h + southL)
 gameRun.surfaceMatrix[y,x].south = (_h + south)
 gameRun.surfaceMatrix[y,x].southR = (_h + southR)
 gameRun.surfaceMatrix[y,x].right = (_h + right)
 
 }
 
 
 


func setupSurface_OLD(surfaceN: String) {
    
    var surface: [String]!
    
    // Add the nodes for the gameboard
    scnScene.rootNode.addChildNode(gameBoard)
    gameBoard.addChildNode(gameBoardFloor)
    
    if let filepath = Bundle.main.path(forResource: surfaceN, ofType: "surface") {
        do {
            let contents = try String(contentsOfFile: filepath)
            debugPrint(contents)
            surface = contents.components(separatedBy: "\n")
            debugPrint(surface.count)
            
            // Add the nodes for the gameboard)
            
            gameRun.gameSurface = IntMatrix(rows: 100, columns: 100)
            gameRun.surfaceMatrix = SurfaceMatrix(rows: 100, columns: 100)
            
            
            // Store the world in the gameWorld matrix
            var x: Int = 0
            var y: Int = 0
            for row in surface {
                for col in row {
                    if (col != Character(" ")) {
                        gameRun.gameSurface![y,x] = Int(String(col))!
                    }
                    x += 1
                }
                x = 0
                y += 1
            }
            
            // Create the surface matrix by cycling through each surface point
            x = 0
            y = 0
            for row in surface {
                for _ in row {
                    if(gameRun.gameSurface![y,x] > -1) {
                        createSurfaceMatrix(x: x, y: y, mode: 2)
                    }
                    x += 1 // Move one to the right
                }
                y += 1 // Move one down
                x = 0 // And to the start of the line
            }
            
            // Create the surface matrix by cycling through each surface point
            x = 0
            y = 0
            for row in surface {
                for _ in row {
                    if(gameRun.gameSurface![y,x] > -1) {
                        smoothSurfaceMatrix(x: x, y: y)
                    }
                    x += 1 // Move one to the right
                }
                y += 1 // Move one down
                x = 0 // And to the start of the line
            }
            
            
            
            // Create the word by cycling through each surface point
            x = 0
            y = 0
            for row in surface {
                for _ in row {
                    if(gameRun.gameSurface![y,x] > -1) {
                        createSurface(x: x, y: y, mul: 1.0)
                    }
                    x += 1 // Move one to the right
                }
                y += 1 // Move one down
                x = 0 // And to the start of the line
            }
            
        } catch {
            // contents could not be loaded
        }
    } else {
        // example.txt not found!
    }
    
}

*/
