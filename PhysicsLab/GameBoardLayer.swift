//
//  GameBoardLayer.swift
//  PhysicsLab
//
//  Created by Tomas Nyström on 12/01/2019.
//  Copyright © 2019 Tomas Nyström. All rights reserved.
//

import Foundation
import SceneKit

class GameBoardLayer: SCNNode {
    
    // Common
    var commmonMaterial: SCNMaterial!
    
    override init() {
        super.init()
        commmonMaterial = SCNMaterial()
        commmonMaterial.diffuse.contents = UIColor.blue
        commmonMaterial.locksAmbientWithDiffuse = true
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
