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
import SpriteKit
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
    
    var gameBoard = SCNNode()
    var gameBoardWalls = SCNNode()
    var gameBoardFloor = SCNNode()
    var gameBoardBoxes = SCNNode()
    
    var gameHUD: SKScene!
    var gameHUDWhiteLabel: SKLabelNode!
    var gameHUDRedLabel: SKLabelNode!
    var gameHUDMovesLabel: SKLabelNode!
    
    var gameWhiteCount: Int = 0
    var gameRedCount: Int = 0
    var gameMoves: Int = 0
    
    var gameWorld: CharacterMatrix!

    var gameHUDInvalid: Bool = false
    
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
    
    var lightConstraint: SCNTransformConstraint! // A bit on the side of the player
    var playerXYZConstraint: SCNTransformConstraint! // Exactly on top of player, constant Y
    
    var hitBoxes: [SCNNode] = [] // The nodes hit during the physics simulation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupConstraints()
        setupHUD(height: scnView.bounds.height, width: scnView.bounds.width)
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
        
        if (contact.nodeA.name == "Box" && contact.nodeB.name == "Player") {
            if (hitBoxes.contains(contact.nodeA) == false) {
                hitBoxes.append(contact.nodeA)
            }
        } else if (contact.nodeB.name == "Box" && contact.nodeA.name == "Player") {
            if (hitBoxes.contains(contact.nodeB) == false) {
                hitBoxes.append(contact.nodeB)
            }
        } else {
            return
        }
    
        /*
        // Boom effect
        let particleSystem = SCNParticleSystem(named: "Fire1", inDirectory: nil)
        let particleNode = SCNNode()
        particleNode.addParticleSystem(particleSystem!)
        particleNode.position = contact.nodeA.presentation.position
        scnScene.rootNode.addChildNode(particleNode)
        */
        
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
        
        if (gestureRecognizer.state == .began && gestureRecognizer.numberOfTouches == 1){
            movePlayer = true
            panGameBoard = false
            startPosition = p
            
            // Add the touch marker and direction nodes
            scnScene.rootNode.addChildNode(touchMarkerNode)
            scnScene.rootNode.addChildNode(touchDirectionNode)
    
        } else if (gestureRecognizer.state == .began && gestureRecognizer.numberOfTouches > 1) {
            movePlayer = false
            panGameBoard = true
            startPosition = p
            cameraNode.position = cameraNode.presentation.position
            cameraNode.constraints?.removeAll()
        } else if (gestureRecognizer.state != .cancelled && gestureRecognizer.state != .ended) {
          
            // Pan the board or set up the player move
            
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
                movePlayer = false
                
                // But only if there is force
                if(applyForce > 0.0) {
                    let position = SCNVector3(0, 0, 0)
                    playerNode.physicsBody?.applyForce(forceVector, at: position, asImpulse: true)

                    gameMoves += 1
                    gameHUDInvalid = true
                }
            } else if (panGameBoard) {
                panGameBoard = false
                cameraNode.constraints = [cameraConstraint]
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
        debugPrint(cameraNode.camera?.focalLength)
        debugPrint(cameraNode.camera?.fieldOfView)
        debugPrint(cameraNode.camera?.sensorHeight)
        debugPrint(cameraNode.scale)
        debugPrint(scnView.bounds.height)
        debugPrint(scnView.bounds.width)
        
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
        lightNode.light!.spotInnerAngle = 20
        lightNode.light!.spotOuterAngle = 80
        lightNode.light!.intensity = 1000
        lightNode.light!.castsShadow = true
        lightNode.light!.shadowBias = 2
        lightNode.light!.shadowMode = SCNShadowMode.modulated
        lightNode.light!.shadowSampleCount = 2
        //lightNode.light!.shadowMapSize = CGSize(width: 128, height: 128)
        lightNode.position = SCNVector3(x: playerNode.presentation.position.x, y: 10, z: playerNode.presentation.position.z)
        lightNode.eulerAngles = SCNVector3(-Float.pi/2, 0.0, 0.0)
        
        lightNode.constraints = [lightConstraint]
        scnScene.rootNode.addChildNode(lightNode)

    }

    func setupHUD(height: CGFloat, width: CGFloat) {
        
        // Create the overlay
        gameHUD = SKScene(size: CGSize(width: width, height: height))
        gameHUD.anchorPoint = CGPoint(x: 0.0,y: 1.0)
        gameHUD.scaleMode = .aspectFill
        /*
        let miniScene = SCNScene()
        let geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        let boxNode = SCNNode(geometry:  geometry)
        miniScene.rootNode.addChildNode(boxNode)
        let node = SK3DNode(viewportSize: CGSize(width: 50, height: 50))
        node.scnScene = miniScene
        node.position = CGPoint(x: 100, y: -100)
        gameHUD.addChild(node)
        */
        
        gameHUDWhiteLabel = SKLabelNode(fontNamed: "Avenir Next")
        gameHUDRedLabel = SKLabelNode(fontNamed: "Avenir Next")
        gameHUDMovesLabel = SKLabelNode(fontNamed: "Avenir Next")
        
        gameHUDWhiteLabel.text = "0"
        gameHUDWhiteLabel.fontSize = 20
        gameHUDWhiteLabel.horizontalAlignmentMode = .left
        gameHUDWhiteLabel.fontColor = SKColor.white
        gameHUDWhiteLabel.position = CGPoint(x: 20, y: -30)
        gameHUD.addChild(gameHUDWhiteLabel)
        
        gameHUDRedLabel.text = "0"
        gameHUDRedLabel.fontSize = 20
        gameHUDRedLabel.horizontalAlignmentMode = .left
        gameHUDRedLabel.fontColor = SKColor.red
        gameHUDRedLabel.position = CGPoint(x: 20, y: -60)
        gameHUD.addChild(gameHUDRedLabel)
       
        gameHUDMovesLabel.text = "0"
        gameHUDMovesLabel.fontSize = 20
        gameHUDMovesLabel.horizontalAlignmentMode = .left
        gameHUDMovesLabel.fontColor = SKColor.green
        gameHUDMovesLabel.position = CGPoint(x: 20, y: -90)
        gameHUD.addChild(gameHUDMovesLabel)
        
        scnView.overlaySKScene = gameHUD
        
    }
 
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
        
        gameHUDInvalid = true
        
        if let filepath = Bundle.main.path(forResource: "1", ofType: "world") {
            do {
                let contents = try String(contentsOfFile: filepath)
                debugPrint(contents)
                world = contents.components(separatedBy: "\n")
                debugPrint(world.count)
                
                // Add the nodes for the gameboard
                scnScene.rootNode.addChildNode(gameBoard)
                gameBoard.addChildNode(gameBoardBoxes)
                gameBoard.addChildNode(gameBoardFloor)
                gameBoard.addChildNode(gameBoardWalls)
                
                gameWorld = CharacterMatrix(rows: world.count, columns: (world.max()?.count)!)
                
                debugPrint(world.max()?.count)
                debugPrint(world.count)
                
                var xG: Int = 0
                var yG: Int = 0
                for row in world {
                    for col in row {
                        gameWorld![yG,xG] = col
                        xG += 1
                    }
                    xG = 0
                    yG += 1
                }
                
                debugPrint(gameWorld)
                
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
                            gameWhiteCount += 1
                        case "B":
                            createWall(x: x, y: y)
                            spawnBoxA(x: x, y: y)
                            gameWhiteCount += 1
                        default:
                            debugPrint("Nothing to add... \(x) \(y)")
                        }
                        x += 1.0 // Move one to the right
                    }
                    y += 1.0 // Move one down
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
        let geometry = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.0)
        
        
        
        
        geometry.materials.first?.diffuse.contents = UIColor.darkGray
        geometry.materials.first?.locksAmbientWithDiffuse = true
        geometry.materials.first?.blendMode = SCNBlendMode.max
        
        //geometry.materials.first?.diffuse.contents = "spark.png"
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x*2, 0.0, y*2)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        geometryNode.castsShadow = false
        geometryNode.name = "Wall"
        gameBoardWalls.addChildNode(geometryNode)
    }
    
    func createFloor(x: Float, y: Float) {
        
        /*
        let geometry = SCNPlane(width: 2.0, height: 2.0)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x*2, -1.0, y*2)
        geometryNode.eulerAngles = SCNVector3(-Float.pi/2,0,0)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        geometryNode.castsShadow = false
        */
        
        let geometryNode = createPlane(x: x, y: y, angles: SCNVector3(-Float.pi/2,0,0), color: UIColor.blue)
        geometryNode.name = "Floor"
    
        gameBoardFloor.addChildNode(geometryNode)
 
    }
    func createPlane(x: Float, y: Float, angles: SCNVector3, color: UIColor) -> SCNNode {
        let geometry = SCNPlane(width: 2.0, height: 2.0)
        geometry.materials.first?.diffuse.contents = color
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x*2, -1.0, y*2)
        geometryNode.eulerAngles = angles
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        geometryNode.castsShadow = false
        return geometryNode
    }

    func createRaisedFloor(x: Float, y: Float) {
        let geometry = SCNPyramid(width: 2.0, height: 2.0, length: 1.9)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x*2, -1.0, y*2)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        geometryNode.castsShadow = false
        geometryNode.name = "Floor"
        
        gameBoardFloor.addChildNode(geometryNode)
    }
    
    func spawnBoxA(x: Float, y: Float) {
        createFloor(x: x, y: y)
        
        let geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        geometry.materials.first?.diffuse.contents = UIColor.white
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(x*2, 1.5, y*2)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometryNode.physicsBody?.mass = 1.0
        geometryNode.physicsBody?.restitution = 0.25
        geometryNode.physicsBody?.friction = 0.75
        geometryNode.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        geometryNode.castsShadow = false
        
        geometryNode.name = "Box"
        
        gameBoardBoxes.addChildNode(geometryNode)
        
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
            geometry.materials.first?.locksAmbientWithDiffuse = true
            //geometry.materials.first?.reflective.contents = UIColor.green
            geometry.materials.first?.writesToDepthBuffer = true
            
            playerNode = SCNNode(geometry: geometry)
            playerNode.position = SCNVector3(x*2, 15, y*2)
            playerNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            playerNode.physicsBody?.mass = 1.0
            playerNode.physicsBody?.restitution = 0.25
            playerNode.physicsBody?.friction = 0.50
            playerNode.physicsBody!.contactTestBitMask = CollisionTypes.box.rawValue
            playerNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
            playerNode.castsShadow = true
            //playerNode.physicsBody!.allowsResting = false
            playerNode.name = "Player"
            
            gameBoard.addChildNode(playerNode)
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
        
        // Touch marker - not added to scene
        geometry = SCNTorus(ringRadius: 0.5, pipeRadius: 0.2)
        geometry.materials.first?.diffuse.contents = UIColor.red
        touchMarkerNode = SCNNode(geometry: geometry)
        touchMarkerNode.position.y = 3.0
        touchMarkerNode.constraints = [playerXYZConstraint]
        touchMarkerNode.castsShadow = false
        
        // Tuch direction node hierarchy
        touchDirectionNode = SCNNode()
        touchDirectionNode.position.y = 3.0
        touchDirectionNode.constraints = [playerXYZConstraint]
        touchDirectionNode.castsShadow = false
        
        geometry = SCNCone(topRadius: 0.4, bottomRadius: 0.6, height: 0.4)
        geometry.materials.first?.diffuse.contents = UIColor.red
        touchD1 = SCNNode(geometry: geometry)
        touchD1.position = SCNVector3(0.0, 0.0, 1.0)
        touchD1.eulerAngles = SCNVector3(Double.pi / 2,0,0)
        touchD1.castsShadow = false
        
        geometry = SCNCone(topRadius: 0.2, bottomRadius: 0.4, height: 0.4)
        geometry.materials.first?.diffuse.contents = UIColor.red
        touchD2 = SCNNode(geometry: geometry)
        touchD2.position = SCNVector3(0.0, 0.0, 1.4)
        touchD2.eulerAngles = SCNVector3(Double.pi / 2,0,0)
        touchD2.castsShadow = false
        
        geometry = SCNCone(topRadius: 0.0, bottomRadius: 0.2, height: 0.4)
        geometry.materials.first?.diffuse.contents = UIColor.red
        touchD3 = SCNNode(geometry: geometry)
        touchD3.position = SCNVector3(0.0, 0.0, 1.8)
        touchD3.eulerAngles = SCNVector3(Double.pi / 2,0,0)
        touchD3.castsShadow = false
        
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
        lightConstraint = SCNTransformConstraint(inWorldSpace: true, with: { (node, matrix) in
            
            let diffX: Float = self.playerNode.presentation.position.x - 1.5 - node.presentation.position.x
            let diffZ = self.playerNode.presentation.position.z - 1.5 -  node.presentation.position.z
            
            let newMatrix = SCNMatrix4Translate(matrix, diffX, 0, diffZ)
            
            return newMatrix
        })
        
        
        // Keep constrained node on top of player
        playerXYZConstraint = SCNTransformConstraint(inWorldSpace: true, with: { (node, matrix) in
            
            let diffX: Float = self.playerNode.presentation.position.x - node.presentation.position.x
            let diffY: Float = self.playerNode.presentation.position.y - node.presentation.position.y + 3.0
            let diffZ: Float = self.playerNode.presentation.position.z - node.presentation.position.z
            
            let newMatrix = SCNMatrix4Translate(matrix, diffX, diffY, diffZ)
            
            return newMatrix
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setupHUD(height: size.height, width: size.width)
        gameHUDInvalid = true
        let aspect: Float = Float(size.height / scnView.bounds.height)
        let currentCameraY: Float = cameraNode.presentation.position.y
        cameraNode.position.y =  currentCameraY * aspect
        super.viewWillTransition(to: size, with: coordinator)
    }
}

extension GameViewController: SCNSceneRendererDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if(playerNode.presentation.position.y < -8) {
            // Player dropped below sufrace, respawn
            spawnPlayer(x: playerSpawnX, y: playerSpawnY)
            
        }
        
        for node in hitBoxes {
            let color: UIColor = node.geometry?.materials.first?.diffuse.contents as! UIColor
            if (color != UIColor.red) {
                node.geometry?.materials.first?.diffuse.contents = UIColor.red
                gameWhiteCount -= 1
                gameRedCount += 1
                gameHUDInvalid = true
            }
        }
        hitBoxes = []
        
        // Make sure the scene keeps running if the camera is out of bounds
        if(cameraOutOfBounds) {
            scnView.isPlaying = true
        } else {
            scnView.isPlaying = false
        }
        
        if (gameHUDInvalid) {
            gameHUDInvalid = false
            gameHUDWhiteLabel.text = String(gameWhiteCount)
            gameHUDRedLabel.text = String(gameRedCount)
            gameHUDMovesLabel.text = String(gameMoves)
            
        }
    }
}
