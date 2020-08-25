//
//  GameScene.swift
//  Sugarscape Shared
//
//  Created by Ben Goertz on 8/24/20.
//  Copyright © 2020 Ben Goertz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    fileprivate var label : SKLabelNode?
    private var environment = Environment()
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
    
    func setUpScene() {
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }

        environment.setup()
        environment.update()
    }

    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        environment.update()
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
    }
}
#endif

class Environment {
    var cells: [Cell] = []
    var agents: [Agent] = []
    // maximum number of cells in each dimension
    let maxWidth: Int = 5
    let maxHeight: Int = 5

    func setup() {
        // pretend cell width and height is just 1
        for x in 0..<maxWidth {
            for y in 0..<maxHeight {
                cells.append(Cell(x: x, y: y))
            }
        }
        print("Setup cells", cells)

        // just one agent for now, placed randomly
        let startingX = Int.random(in: 0..<maxWidth)
        let startingY = Int.random(in: 0..<maxHeight)
        agents.append(Agent(x: startingX, y: startingY))
    }

    // basically the run loop call
    func update() {
        moveAgents()
        grow()
    }

    // agents move and then eat what's on the given cell
    private func moveAgents() {
        for agent in agents {
            agent.move(maxWidth: maxWidth, maxHeight: maxHeight)
            // find the cell that the agent is currently on
            let currentCell = cells.first { cell in
                cell.x == agent.x && cell.y == agent.y
            }
            guard let cell = currentCell else {
                break
            }
            print("Getting ready to eat \(cell.sugar) at: \(cell.x):\(cell.y)")
            agent.eat(availableSugar: cell.sugar)
            // harvest
            cell.sugar = 0
        }
    }

    private func grow() {
        for cell in cells {
            cell.updateSugar()
        }
        print(cells)
        print(agents)
    }
}

class Cell: CustomDebugStringConvertible {
    // fake location for now, but helps debug
    let x: Int
    let y: Int
    var sugar: Int
    // potentially don't need this, but might impact growth
    var occupyingAgent: Agent?

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
        // Distributing the sugar randomly at first
        // they have the two cute hills which can be setup later
        self.sugar = Int.random(in: 0...4)
    }

    func updateSugar() {
        // maximum growth
        guard sugar != 4 else {
            return
        }

        sugar += 1
        //print("Sugar level \(sugar): ", x, y)
    }

    var debugDescription: String {
        "\(x):\(y) sugar: \(sugar)"
    }
}

// blindly wander around and eat the sugar on a cell
class Agent: CustomDebugStringConvertible {
    var x: Int
    var y: Int
    var storedSugar = 0

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    // only move one space for now, blindly
    // passing in the edges of world to know where to wrap
    func move(maxWidth: Int, maxHeight: Int) {
        // cells x and y start at index 0
        let xBoundary = maxWidth - 1
        let yBoundary = maxHeight - 1
        let xMove = Float.random(in: 0...1)
        let yMove = Float.random(in: 0...1)

        // keeping this simple for now
        if xMove > 0.5 {
            x += 1
            // simple way to wrap
            if x > xBoundary {
                x = 0
            }
        } else {
            x -= 1
            if x < 0 {
                x = xBoundary
            }
        }

        if yMove > 0.5 {
            y += 1
            if y > yBoundary {
                y = 0
            }
        } else {
            y -= 1
            if y < 0 {
                y = yBoundary
            }
        }
    }

    // eat everything that's on the cell space
    func eat(availableSugar: Int) {
        storedSugar += availableSugar
    }

    var debugDescription: String {
        "At \(x), \(y) with \(storedSugar) sugar."
    }
}
