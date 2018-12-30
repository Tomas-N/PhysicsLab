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
}

class GameViewController: UIViewController, SCNPhysicsContactDelegate {

    var scnView: SCNView!
    var scnScene: SCNScene!
    var cameraNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        spawnShape()
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
        /*
        // add a swip gesture recognizer
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        scnView.addGestureRecognizer(swipeGesture)
        */

        // add a pan gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        scnView.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        scnView.addGestureRecognizer(pinchGesture)
        
        scnScene.physicsWorld.contactDelegate = self
  
    }
    
    /* No swipe yet
    @objc
    func handleSwipe(_ gestureRecognize: UIGestureRecognizer) {
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        
        let hitResults = scnView.hitTest(p, options: [:]) // No options
        
        // check
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // move it
            let randomX = Float.random(in: -2.00 ... 7.00)
            let randomY = Float.random(in:  1.00 ... 7.00)
            let randomZ = Float.random(in: -2.00 ... 7.00)
            
            let force = SCNVector3(randomX, randomY, randomZ)
            let position = SCNVector3(0.05, 0.05, 0.05)
            
            result.node.physicsBody?.applyForce(force, at: position, asImpulse: true)
        }
    
    }
   */
    
    /*
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //
        debugPrint("!")
        if ((contact.nodeA.name == "Box") && (contact.nodeB.name == "Box")) {
            print ("true hit")
            print (contact.collisionImpulse)
        }
    }
    */
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
    //
        let boxNode: SCNNode!
        if (contact.nodeA.name == "Box") {
            boxNode = contact.nodeA
        } else if (contact.nodeB.name == "Box") {
            boxNode = contact.nodeB
        } else {
            return
        }
    
       // if (contact.collisionImpulse > 0.2) {
            debugPrint("-----")
            debugPrint(boxNode.position)
            boxNode.scale = SCNVector3(boxNode.scale.x * 0.5, boxNode.scale.y * 0.5, boxNode.scale.y * 0.5)
            debugPrint(boxNode.position)
            
            if(boxNode.scale.x <= 0.25) {
                boxNode.removeFromParentNode()
                return
            }
            
            // boxNode.physicsBody?.clearAllForces()
            let newNode: SCNNode = boxNode.clone()
            debugPrint(boxNode.position)
            debugPrint(newNode.position)
            // boxNode.physicsBody?.applyForce(, asImpulse: <#T##Bool#>)
            newNode.physicsBody = boxNode.physicsBody?.copy() as? SCNPhysicsBody
            
            //boxNode.physicsBody?.applyForce(contact.coll, asImpulse: <#T##Bool#>)
            scnScene.rootNode.addChildNode(newNode)
        //}
    }
    
    var speed = CGPoint()
    var result = SCNHitTestResult()
    var resultFound = false
    @objc
    func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        guard gestureRecognizer.view != nil else {return}

        let piece = gestureRecognizer.view!
        let p = gestureRecognizer.location(in: scnView)
        
        if gestureRecognizer.state == .began {
            // Get the node
            let hitResults = scnView.hitTest(p, options: [:])
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                // Get the changes in X and Y
                speed = gestureRecognizer.velocity(in: piece)
                
                print(speed)
                // retrieved the first clicked object
                result = hitResults[0]
                resultFound = true
            }
        }
        if gestureRecognizer.state != .cancelled {
            if (resultFound) {
            
                let force = SCNVector3(speed.x, 0, speed.y)
                let position = SCNVector3(0.00, 0.00, 0.00)
    
                result.node.physicsBody?.applyForce(force, at: position, asImpulse: false)
    
            }
        }
        else {
            resultFound = false
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
        }
        if gestureRecognizer.state != .cancelled {
            
            pinchFactor += 0.02
            
            if (pinchStart.isLess(than: gestureRecognizer.scale)) {
                if (cameraNode.position.y - pinchFactor > 4) {
                    cameraNode.position = SCNVector3(x: 0, y: cameraNode.position.y - pinchFactor, z: 0)
                }
            }
            else {
                if (cameraNode.position.y - pinchFactor < 20) {
                    cameraNode.position = SCNVector3(x: 0, y: cameraNode.position.y + pinchFactor, z: 0)
                }
            }
            // print(gestureRecognizer.scale)
        }
        else {
            // Done
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        //let scnView = self.view as! SCNView
        
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
            
            // move it
            let randomX = Float.random(in: -2.00 ... 2.00)
            let randomY = Float.random(in:  1.00 ... 7.00)
            let randomZ = Float.random(in: -2.00 ... 2.00)

            let force = SCNVector3(randomX, randomY, randomZ)
            
            result.node.physicsBody?.applyForce(force, asImpulse: true)
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
        scnView.showsStatistics = true
        scnView.allowsCameraControl = false
        // scnView.autoenablesDefaultLighting = true
        scnView.delegate = self
    }
    
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 10, y: 10, z: 10)
        scnScene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scnScene.rootNode.addChildNode(ambientLightNode)
        
    }
    
    func setupCamera() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 15, z: 0)
        cameraNode.eulerAngles = SCNVector3Make(-Float.pi/2, 0, 0)
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    func spawnShape() {
        var geometry: SCNGeometry
        var geometryNode: SCNNode
        let gameboard: SCNNode = SCNNode()
        
        // Floor
        geometry = SCNBox(width: 10.0, height: 1.0, length: 10.0, chamferRadius: 0.0)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(0, -1, 0)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        gameboard.addChildNode(geometryNode)
        
        // Right side
        geometry = SCNBox(width: 1.0, height: 6.0, length: 12.0, chamferRadius: 0.0)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(5.5, -0.5, 0)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        gameboard.addChildNode(geometryNode)
        
        // Left side
        geometry = SCNBox(width: 1.0, height: 6.0, length: 12.0, chamferRadius: 0.0)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(-5.5, -0.5, 0)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        gameboard.addChildNode(geometryNode)
        
        // Top side
        geometry = SCNBox(width: 10.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(0, -0.5, 5.5)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        gameboard.addChildNode(geometryNode)
        
        // Bottom side
        geometry = SCNBox(width: 10.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(0, -0.5, -5.5)
        geometryNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        gameboard.addChildNode(geometryNode)
        
        // Add the board
        scnScene.rootNode.addChildNode(gameboard)
        
        
        // Add two pieces
        geometry = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(2, 2, 0)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometryNode.physicsBody?.mass = 3.0
        geometryNode.physicsBody?.restitution = 0.25
        geometryNode.physicsBody?.friction = 0.75
        geometryNode.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        
        geometryNode.name = "Box"
        
        scnScene.rootNode.addChildNode(geometryNode)
        
        geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(0, 2, 2)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometryNode.physicsBody?.mass = 1.0
        geometryNode.physicsBody?.restitution = 0.25
        geometryNode.physicsBody?.friction = 0.75
        geometryNode.physicsBody!.contactTestBitMask = CollisionTypes.player.rawValue
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        
        geometryNode.name = "Box"
        
        scnScene.rootNode.addChildNode(geometryNode)

        // Player
        geometry = SCNSphere(radius: 0.5)
        geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = SCNVector3(-2, 2, 0)
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometryNode.physicsBody?.mass = 1.0
        geometryNode.physicsBody?.restitution = 0.25
        geometryNode.physicsBody?.friction = 0.50
        geometryNode.physicsBody!.contactTestBitMask = CollisionTypes.box.rawValue
        geometryNode.physicsBody!.collisionBitMask = CollisionTypes.all.rawValue
        
        geometryNode.name = "Player"
        
        scnScene.rootNode.addChildNode(geometryNode)
        
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

}

extension GameViewController: SCNSceneRendererDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        //
    }
}
