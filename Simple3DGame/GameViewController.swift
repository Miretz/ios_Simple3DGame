//
//  GameViewController.swift
//  Simple3DGame
//
//  Created by Miretz Dev on 20/12/2017.
//  Copyright © 2017 Miretz. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import SpriteKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {

    var gameView: SCNView!
    var gameScene: SCNScene!
    var cameraNode: SCNNode!
    var targetCreationTime:TimeInterval = 0
    var overlayScene: SKScene!
    var scoreLabel: SKLabelNode!
    var score: Int = 0 {
        didSet {
            scoreLabel?.text = "Score: \(score)"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        initScene()
        initCamera()
        initHud()
    }
    
    func initView() {
        gameView = self.view as! SCNView
        gameView.allowsCameraControl = false
        gameView.autoenablesDefaultLighting = true
        
        gameView.delegate = self
    }
    
    func initScene(){
        gameScene = SCNScene()
        gameView.scene = gameScene
        gameView.isPlaying = true
    }
    
    func initCamera(){
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y:5, z:10)
        
        gameScene.rootNode.addChildNode(cameraNode)
    }
    
    func initHud(){
        overlayScene = SKScene(fileNamed: "OverlayScene")
        overlayScene.isUserInteractionEnabled = false
        scoreLabel = overlayScene.childNode(withName: "ScoreLabel") as? SKLabelNode
        gameView.overlaySKScene = overlayScene
    }
    
    func createRandomGeometry() -> SCNGeometry {
        let randomShape = 6.arc4random
        switch randomShape {
        case 0: return SCNPyramid(width: 1, height: 1, length: 1)
        case 1: return SCNSphere(radius: 0.5)
        case 2: return SCNCone(topRadius: 0.0, bottomRadius: 0.5, height: 1)
        case 3: return SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        case 4: return SCNCylinder(radius: 0.5, height: 1)
        default: return SCNTorus(ringRadius: 0.25, pipeRadius: 0.25)
        }
        
    }
    
    func createTarget(){
        let geometry: SCNGeometry = createRandomGeometry()
        
        let randomColor = 2.arc4random==0 ? UIColor.red : UIColor.green
        geometry.materials.first?.diffuse.contents = randomColor
        let geometryNode = SCNNode(geometry: geometry)
        
        geometryNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        geometryNode.name = randomColor == UIColor.red ? "enemy" : "friend"
        
        gameScene.rootNode.addChildNode(geometryNode)
        
        let randomDirection:Float = 4.arc4random==0 ? -1.0 : 1.0
        let force = SCNVector3(x: randomDirection, y: 15, z:0)
        geometryNode.physicsBody?.applyForce(force, at: SCNVector3(x: 0.05, y: 0.05, z: 0.05), asImpulse: true)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if time > targetCreationTime {
            createTarget()
            targetCreationTime = time + 0.6
        }
        cleanup()
    }
    
    func cleanup(){
        for node in gameScene.rootNode.childNodes {
            if node.presentation.position.y < -2.0 {
                if node.name == "friend" { score -= 1 }
                node.removeFromParentNode()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: gameView)
        let hitList = gameView.hitTest(location, options: nil)
        if let hitObject = hitList.first {
            let node = hitObject.node
            if node.name == "friend" {
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.black
                score += 1
            }
            else if node.name == "enemy" {
                node.removeFromParentNode()
                self.gameView.backgroundColor = UIColor.red
                score -= 1
            }
            
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}

