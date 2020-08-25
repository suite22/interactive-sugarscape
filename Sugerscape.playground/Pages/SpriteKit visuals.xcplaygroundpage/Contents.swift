//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit

class Sugerscape: SKScene {
    private var agentNode: SKShapeNode!
    
    override func didMove(to view: SKView) {
        agentNode = SKShapeNode(rectOf: CGSize(width: 10, height: 10))
        agentNode.fillColor = .red
        addChild(agentNode)
    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 300, height: 300))
if let scene = Sugerscape(fileNamed: "GameScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    
    // Present the scene
    sceneView.presentScene(scene)
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
