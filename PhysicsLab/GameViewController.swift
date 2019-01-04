//
//  GameViewController.swift
//  PhysicsLab
//
//  Created by Tomas Nyström on 28/12/2018.
//  Copyright © 2018 Tomas Nyström. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Foundation
import CoreGraphics

enum CollisionTypes: Int {
    case none = 0
    case box = 1
    case wall = 2
    case player = 4
    case all = 7
    case button = 8 // Exclude button from interaction
}

class GameViewController: UIViewController, SCNPhysicsContactDelegate {

    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    var lightNode: SCNNode!
    var gameBoard: SCNNode!
    var touchMarkerNode: SCNNode!
    var playerNode: SCNNode!
    var touchDirectionNode: SCNNode!
    var touchD1: SCNNode!
    var touchD2: SCNNode!
    var touchD3: SCNNode!
    
    var playerSpawnX: Float!
    var playerSpawnY: Float!
    
    var cameraConstraint: SCNTransformConstraint! // Exactly on top, changing Y
    var cameraOutOfBounds: Bool = false
    
    var playerConstraint: SCNTransformConstraint! // Exactly on top of player, constant Y
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupConstraints()
        setupWorld()
        setupToucMarker()
        setupLight()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        // add a swipe gesture recognizer
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        scnView.addGestureRecognizer(swipeGesture)

        // add a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)

        // add a pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        scnView.addGestureRecognizer(pinchGesture)
        
        // ad a physics contact handler
        scnScene.physicsWorld.contactDelegate = self
  
    }
    
    @objc
    func handleSwipe(_ gestureRecognizer: UISwipeGestureRecognizer) {
        
        debugPrint("swipe")
        guard gestureRecognizer.view != nil else {return}
        
        if gestureRecognizer.state == .began {
    
            //
            
        } else if (gestureRecognizer.state != .cancelled) {
            
            debugPrint(gestureRecognizer.direction)
        }
        else {
            //
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    //
        let boxNode: SCNNode!
        if (contact.nodeA.name == "Box") {
            boxNode = contact.nodeA
        } else if (contact.nodeB.name == "Box") {
            boxNode = contact.nodeB
        } else {
            return
        }
    
        // Boom effect
        let particleSystem = SCNParticleSystem(named: "Fire1", inDirectory: nil)
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particleSystem!)
        particleNode.position = contact.nodeA.presentation.position
        scnScene.rootNode.addChildNode(particleNode)

        // Kill box
        boxNode.removeFromParentNode()
        
        /*
        // Reduce size
        boxNode.scale = SCNVector3(boxNode.scale.x * 0.5, boxNode.scale.y * 0.5, boxNode.scale.y * 0.5)
        if(boxNode.scale.x <= 0.25) {
            boxNode.removeFromParentNode()
            return
        }
    
        // Split into two
        let newNode: SCNNode = boxNode.clone()
        newNode.position = boxNode.presentation.position
        newNode.physicsBody = boxNode.physicsBody?.copy() as? SCNPhysicsBody
        scnScene.rootNode.addChildNode(newNode)
 */
    }
    
    var startPosition = CGPoint()
    var result = SCNHitTestResult()
    var movePlayer = false
    var panGameBoard = false
    
    // The force we will push the player with
    var applyForce: Float = 0.0
    // The direction wwe will pysh the player in
    var forceVector: SCNVector3 = SCNVector3(0,0,0)
    
    @objc
    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else {return}

        let p = gestureRecognizer.location(in: scnView)
        
        if gestureRecognizer.state == .began {
            // Get the node
            let hitResults = scnView.hitTest(p, options: [:])
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                
                 // retrieved the first clicked object
                result = hitResults[0]
                
                // Check type of node touhed
                if (result.node.name == "Player"){
                    movePlayer = true
                    panGameBoard = false
                    startPosition = p
                    
                    // Add the touch marker and direction nodes
                    //touchMarkerNode.position = playerNode.presentation.worldPosition
                    //touchMarkerNode.position.y = 3.0
                    //touchMarkerNode.constraints = [playerConstraint]
                    scnScene.rootNode.addChildNode(touchMarkerNode)
                    //touchDirectionNode.position = playerNode.presentation.worldPosition
                    //touchDirectionNode.position.y = 3.0
                    //touchDirectionNode.constraints = [playerConstraint]
                    scnScene.rootNode.addChildNode(touchDirectionNode)
                
                } else if(result.node.name == "Box"){
                    movePlayer = true
                    panGameBoard = false
                  
                } else {
                    // Pan on the game board
                    movePlayer = false
                    panGameBoard = true
                    startPosition = p
                }
            } else {
                // Pan on the background
                movePlayer = false
                panGameBoard = true
                startPosition = p
            }
        }
        if (gestureRecognizer.state != .cancelled && gestureRecognizer.state != .ended) {
            if (movePlayer) {
                
                touchMarkerNode.runAction(SCNAction.rotate(toAxisAngle: SCNVector4(1,1,1,  touchMarkerNode.rotation.w + Float.pi), duration: 1.0))
                
                // Get the diff between touch point and the player
                let pos: SCNVector3 = playerNode.presentation.worldPosition
                let diffx = Float(p.x) - scnView.projectPoint(pos).x
                let diffz = Float(p.y) - scnView.projectPoint(pos).y
                
                // Se the force based on the distance
                let diffmax = Float.maximum(abs(diffx), abs(diffz))
                
                if (diffmax > 160.0) {
                    applyForce = 20.0
                    
                    touchD1.opacity = 1.0
                    touchD2.opacity = 1.0
                    touchD3.opacity = 1.0
                    
                } else if (diffmax > 120) {
                    applyForce = 10.0
                    
                    touchD1.opacity = 1.0
                    touchD2.opacity = 1.0
                    touchD3.opacity = 0.0
                    
                } else if (diffmax > 80) {
                    applyForce = 5.0
                    
                    touchD1.opacity = 1.0
                    touchD2.opacity = 0.0
                    touchD3.opacity = 0.0
                    
                } else {
                    applyForce = 0.0
                    
                    touchD1.opacity = 0.0
                    touchD2.opacity = 0.0
                    touchD3.opacity = 0.0
                
                }
                
                // Set the force vector
                forceVector = SCNVector3(diffx/diffmax * applyForce,0,diffz/diffmax * applyForce)
                
                // Get player position
                let playerX: Float = playerNode.presentation.worldPosition.x
                let playerY: Float = playerNode.presentation.worldPosition.y
                
                // Set the touch indicator to look at the negative force vector
                touchDirectionNode.look(at: SCNVector3(-(playerX + diffx) , 0, -(playerY + diffz)), up: SCNVector3(0,1,0), localFront: SCNVector3(0,0,-1))
                
            } else if (panGameBoard) {
                
                let deltaX = startPosition.x - gestureRecognizer.location(in: scnView).x
                let deltaZ = startPosition.y - gestureRecognizer.location(in: scnView).y
                
                var newX: Float = cameraNode.presentation.position.x
                var newZ: Float = cameraNode.presentation.position.z
                
                if (abs(deltaX) > abs(deltaZ)) {
                    if deltaX > 0 { newX += 0.2}
                    if deltaX < 0 { newX -= 0.2}
                } else {
                    if deltaZ > 0 { newZ += 0.2}
                    if deltaZ < 0 { newZ -= 0.2}
                }
                cameraNode.position = SCNVector3(x: newX, y: cameraNode.presentation.position.y, z: newZ)
                
            }
        }
        else {
            // End the pan and kick the cube
            if (movePlayer) {
                
                self.touchMarkerNode.removeFromParentNode()
                self.touchDirectionNode.removeFromParentNode()
            
                let position = SCNVector3(0, 0, 0)
                playerNode.physicsBody?.applyForce(forceVector, at: position, asImpulse: true)
                
                movePlayer = false
            } else if (panGameBoard) {
                panGameBoard = false
            }
            
            
        }
    }
    
    var pinchStart = CGFloat()
    var pinchFactor: Float = 0.0
    
    @objc
    func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else {return}
        
        // let piece = gestureRecognizer.view!
        if gestureRecognizer.state == .began {
            // Starting point
            pinchStart = gestureRecognizer.scale
            pinchFactor = 0
            // Free camera
            cameraNode.position = cameraNode.presentation.position
            cameraNode.constraints?.removeAll()
        }
        if (gestureRecognizer.state != .cancelled && gestureRecognizer.state != .ended) {
            
            pinchFactor += 0.02
            
            if (pinchStart.isLess(than: gestureRecognizer.scale)) {
                if (cameraNode.position.y - pinchFactor > 4) {
                    cameraNode.position = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y - pinchFactor, z: cameraNode.position.z)
                }
            }
            else {
                if (cameraNode.position.y - pinchFactor < 40) {
                    cameraNode.position = SCNVector3(x: cameraNode.position.x, y: cameraNode.position.y + pinchFactor, z: cameraNode.position.z)
                }
            }
        } else {
            // Return the camera constraint
            cameraNode.constraints = [cameraConstraint]
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                material.emission.contents = UIColor.black
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            material.emission.intensity = 10.00
            SCNTransaction.commit()
            
            if (result.node.name == "Box" || result.node.name == "Player") {
                // move it
                let randomX = Float.random(in: -2.00 ... 2.00)
                let randomY = Float.random(in:  1.00 ... 7.00)
                let randomZ = Float.random(in: -2.00 ... 2.00)

                let force = SCNVector3(randomX, randomY, randomZ)
                
                result.node.physicsBody?.applyForce(force, asImpulse: true)
            } else if (result.node.name == "Button") {
                // rotate it
                
                result.node.runAction(SCNAction.rotate(toAxisAngle: SCNVector4(1,1,1, result.node.rotation.w + Float.pi), duration: 1.0))
                
                var geometry: SCNGeometry
                var geometryNode: SCNNode
                
                let randomX = Float.random(in: -1.00 ... 1.00)
                let randomY = Float.random(in:  1.00 ... 7.00)
                let randomZ = Float.random(in: -1.00 ... 1.00)
                
                geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                geometryNode = SCNNode(geometry: geometry)
                geometryNode.position = SCNVector3(randomX, randomY, randomZ)
                geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
                geometryNode.physicsBody?.mass = 1.0
                geometryNode.physicsBody?.restitution = 0.25
                geometryNode.physicsBody?.friction = 0.75
                geometryNode.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue
                geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
                
                geometryNode.name = "Box"
                
                scnScene.rootNode.addChildNode(geometryNode)
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setupView()  {
        scnView = (self.view as! SCNView)
        scnView.showsStatistics = false
        scnView.allowsCameraControl = false
        scnView.delegate = self
        scnView.antialiasingMode = .multisampling4X
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
    }
    
    func setupLight() {
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scnScene.rootNode.addChildNode(ambientLightNode)
        
        // Add a spotlight
        lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.spot
        lightNode.light!.color = UIColor.white
        lightNode.light!.spotInnerAngle = 10
        lightNode.light!.spotOuterAngle = 30
        //lightNode.light!.castsShadow = true
        //lightNode.light!.shadowBias = 1000.0
        lightNode.position = SCNVector3(x: playerNode.presentation.position.x, y: 40, z: playerNode.presentation.position.z)
        lightNode.eulerAngles = SCNVector3(-Float.pi/2, 0.0, 0.0)
        
        lightNode.constraints = [playerConstraint]
        scnScene.rootNode.addChildNode(lightNode)

    }
   /*
    func spawnShape() {
        var geometry: SCNGeometry
        var geometryNode: SCNNode

        // Add menu button
        geometry = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(-0.8,1.5,-3)
        geometry.materials.first?.diffuse.contents = UIColor.white

        geometryNode.name = "Button"
        
        cameraNode.addChildNode(geometryNode)
    
    }
 */
    /*
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    */
    
    func setupWorld() {
        
        var world: [String]!
        if let filepath = Bundle.main.path(forResource: "1", ofType: "world") {
            do {
                let contents = try String(contentsOfFile: filepath)
                debugPrint(contents)
                world = contents.components(separatedBy: "\n")
                debugPrint(world.count)
                
                // Create the node for the gameboard
                gameBoard = SCNNode()
                scnScene.rootNode.addChildNode(gameBoard)
                
                // Create the word by cycling through each character
                var x: Float = 0.0
                var y: Float = 0.0
                for row in world {
                    for col in row {
                        switch col {
                        case "0":
                            createWall(x: x, y: y)
                        case "1":
                            createFloor(x: x, y: y)
                        case "2":
                            createRaisedFloor(x: x, y: y)
                        case "X":
                            createFloor(x: x, y: y)
                            spawnPlayer(x: x, y: y)
                        case "A":
                            createFloor(x: x, y: y)
                            spawnBoxA(x: x, y: y)
                        default:
                            debugPrint("Nothing to add... \(x) \(y)")
                        }
                        x += 2.0 // Move one to the right
                    }
                    y += 2.0 // Move one down
                    x = 0.0 // And to the start of the line
                }
                
            } catch {
                // contents could not be loaded
            }
        } else {
            // example.txt not found!
        }
        
    }
    
    func createWall(x: Float, y: Float) {
        var geometry: SCNGeometry
        var geometryNode: SCNNode
        // Black box
        geometry = SCNBox(width: 1.9, height: 1.9, length: 1.9, chamferRadius: 0.0)
        geometry.materials.first?.diffuse.contents = UIColor.darkGray

        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x, 0.0, y)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        gameBoard.addChildNode(geometryNode)
    }
    
    func createFloor(x: Float, y: Float) {
        var geometry: SCNGeometry
        var geometryNode: SCNNode
        // Blue box
        //geometry = SCNBox(width: 1.9, height: 1.0, length: 1.9, chamferRadius: 0.0)
        geometry = SCNPlane(width: 1.9, height: 1.9)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x, -1.0, y)
        geometryNode.eulerAngles = SCNVector3(-Float.pi/2,0,0)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        gameBoard.addChildNode(geometryNode)
 
    }

    func createRaisedFloor(x: Float, y: Float) {
        var geometry: SCNGeometry
        var geometryNode: SCNNode
        // Blue box
        geometry = SCNPyramid(width: 1.9, height: 1.0, length: 1.9)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x, -1.0, y)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        gameBoard.addChildNode(geometryNode)
    }
    
    func spawnBoxA(x: Float, y: Float) {
        var geometry: SCNGeometry
        var geometryNode: SCNNode
        
        createFloor(x: x, y: y)
        
        geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        geometry.materials.first?.diffuse.contents = UIColor.white
        
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x, 0.5, y)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometryNode.physicsBody?.mass = 1.0
        geometryNode.physicsBody?.restitution = 0.25
        geometryNode.physicsBody?.friction = 0.75
        geometryNode.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        
        geometryNode.name = "Box"
        
        scnScene.rootNode.addChildNode(geometryNode)
        
        /*
        let action = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 5))
        geometryNode.runAction(action)
        */
    }
    
    func spawnPlayer(x: Float, y: Float) {
        
        playerSpawnX = x
        playerSpawnY = y
        
        // Add player if player does not exist
        if(scnScene.rootNode.childNode(withName: "Player", recursively: false) == nil) {
            
            let geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
            geometry.materials.first?.diffuse.contents = UIColor.green
            
            playerNode = SCNNode(geometry: geometry)
            playerNode.position = SCNVector3(x, 15, y)
            playerNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            playerNode.physicsBody?.mass = 1.0
            playerNode.physicsBody?.restitution = 0.25
            playerNode.physicsBody?.friction = 0.50
            playerNode.physicsBody!.contactTestBitMask = CollisionTypes.box.rawValue
            playerNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
            playerNode.name = "Player"
            
            scnScene.rootNode.addChildNode(playerNode)
        } else {
            // Reset player
            playerNode.physicsBody?.clearAllForces()
            playerNode.position = SCNVector3(x, 15, y)
        }
        
        if(scnScene.rootNode.childNode(withName: "Camera", recursively: false) == nil) {
            // Add the camera
            cameraNode = SCNNode()
            cameraNode.camera = SCNCamera()
            cameraNode.camera?.zFar = 50
            cameraNode.camera?.zNear = 0
            cameraNode.position = SCNVector3(x: 0, y: 40, z: 0)
            cameraNode.eulerAngles = SCNVector3Make(-Float.pi/2, 0, 0)
            cameraNode.name = "Camera"
            
            cameraNode.constraints = [cameraConstraint]
            scnScene.rootNode.addChildNode(cameraNode)
        }
    }
    
    func setupToucMarker() {
        var geometry: SCNGeometry
        var geometryNode: SCNNode
        
        // Touch marker - not added to scene
        geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.2)
        geometryNode = SCNNode(geometry: geometry)
        geometry.materials.first?.diffuse.contents = UIColor.red
        touchMarkerNode = geometryNode
        touchMarkerNode.position.y = 3.0
        touchMarkerNode.constraints = [playerConstraint]
        
        // Tuch direction node hierarchy
        geometryNode = SCNNode()
        touchDirectionNode = geometryNode
        touchDirectionNode.position.y = 3.0
        touchDirectionNode.constraints = [playerConstraint]
        
        geometry = SCNCone(topRadius: 0.4, bottomRadius: 0.6, height: 0.4)
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(0.0, 0.0, 1.0)
        geometryNode.eulerAngles = SCNVector3(Double.pi / 2,0,0)
        geometry.materials.first?.diffuse.contents = UIColor.red
        touchD1 = geometryNode
        
        geometry = SCNCone(topRadius: 0.2, bottomRadius: 0.4, height: 0.4)
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(0.0, 0.0, 1.4)
        geometryNode.eulerAngles = SCNVector3(Double.pi / 2,0,0)
        geometry.materials.first?.diffuse.contents = UIColor.red
        touchD2 = geometryNode
        
        
        geometry = SCNCone(topRadius: 0.0, bottomRadius: 0.2, height: 0.4)
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(0.0, 0.0, 1.8)
        geometryNode.eulerAngles = SCNVector3(Double.pi / 2,0,0)
        geometry.materials.first?.diffuse.contents = UIColor.red
        touchD3 = geometryNode
        
        touchDirectionNode.addChildNode(touchD1)
        touchDirectionNode.addChildNode(touchD2)
        touchDirectionNode.addChildNode(touchD3)
    }
    
    func setupConstraints() {
        
        // Constraint for keeping camera in a certain range from the player
        cameraConstraint = SCNTransformConstraint(inWorldSpace: true, with: { (node, matrix) in
            
            let diffX: Float = self.playerNode.presentation.position.x - node.presentation.position.x
            var diffY: Float = node.presentation.position.y - self.playerNode.presentation.position.y
            let diffZ = self.playerNode.presentation.position.z - node.presentation.position.z
            
            if (diffY > 20) {
                // Move a bit closer
                diffY = -0.2
                self.cameraOutOfBounds = true
            } else if (diffY < 4) {
                // Too close, push up
                diffY = 0.2
                self.cameraOutOfBounds = true
            } else {
                // In range do nothing
                diffY = 0
                self.cameraOutOfBounds = false
            }
            let newMatrix = SCNMatrix4Translate(matrix, diffX, diffY, diffZ)
            
            return newMatrix
        })
        
        // Keep constrained node on top of player
        playerConstraint = SCNTransformConstraint(inWorldSpace: true, with: { (node, matrix) in
            
            let diffX: Float = self.playerNode.presentation.position.x - node.presentation.position.x
            let diffZ = self.playerNode.presentation.position.z - node.presentation.position.z
            
            let newMatrix = SCNMatrix4Translate(matrix, diffX, 0, diffZ)
            
            return newMatrix
        })
        
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if(playerNode.presentation.position.y < -8) {
            // Player dropped below sufrace, respawn
            spawnPlayer(x: playerSpawnX, y: playerSpawnY)
            
        }
        
        // Make sure the scene keeps running if the camera is out of bounds
        if(cameraOutOfBounds) {
            scnView.isPlaying = true
        } else {
            scnView.isPlaying = false
        }
    }
}
