//
//  GameScene.swift
//  Sugarscape Shared
//
//  Created by Ben Goertz on 8/24/20.
//  Copyright © 2020 Ben Goertz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    private var environment = Environment()
    private let agentsNode: SKNode = SKNode()
    private let sugarsNode: SKNode = SKNode()
    private let gridNode: SKNode = SKNode()
    static private let environmentSize: (x: Int, y: Int) = (100, 100)
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFit
        scene.backgroundColor = .white
        let sceneSize = CGSize(width: environmentSize.x, height: environmentSize.y)
        scene.size = sceneSize
        
        return scene
    }
    
    func setUpScene() {
        environment.setup(size: GameScene.environmentSize)
//        environment.update()

        // keep them seperate from the landscape nodes
        agentsNode.name = "agents"
        addChild(agentsNode)

        for agent in environment.agents {
            let rect = CGSize(width: 10, height: 10)
            let node = SKShapeNode(rectOf: rect)
            node.fillColor = .red
            node.name = agent.uniqueID.description
            agentsNode.addChild(node)
            let agentStart = CGPoint(x: agent.x, y: agent.y)
            let initialMove = SKAction.move(to: agentStart, duration: 0)
            node.run(initialMove)
        }

        // grid lines
        gridNode.name = "gridLines"
        addChild(gridNode)

        for gridLine in environment.gridLines {
            var rect: CGSize
            var positionLine: CGPoint

            switch gridLine.direction {
            case .horizontal:
                rect = CGSize(width: GameScene.environmentSize.x, height: 1)
                positionLine = CGPoint(x: 0, y: gridLine.startingPoint)
            case .vertical:
                rect = CGSize(width: 1, height: GameScene.environmentSize.y)
                positionLine = CGPoint(x: gridLine.startingPoint, y: 0)
            }

            let node = SKShapeNode(rectOf: rect)
            node.fillColor = .lightGray
            gridNode.addChild(node)
            let initialPosition = SKAction.move(to: positionLine, duration: 0)
            node.run(initialPosition)
        }
    }

    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
//        environment.update()


    }
}

class Environment {
    var cells: [Cell] = []
    var agents: [Agent] = []
    var gridLines: [GridLine] = []
    // maximum number of cells in each dimension
    let maxAgents: Int = 1
    let scalingFactor: Int = 10
    var size: (x: Int, y: Int) = (500, 500)

    private let colorGradiants: Set<UIColor> = [.black, .darkGray, .darkGray, .lightGray]

    func setup(size: (x: Int, y: Int)) {
        self.size = size

        setupGridLines()
//        setupCells()

        // just one agent for now, placed randomly
        let startingX = Int.random(in: 0 ..< size.x)
        let startingY = Int.random(in: 0 ..< size.y)
        agents.append(Agent(x: startingX, y: startingY))
    }

    func setupGridLines() {
        // draw grid lines
        // the center of the SKView is 0,0
        var x: Int = -(size.x / 2) + scalingFactor
        var y: Int = -(size.y / 2) + scalingFactor

        while x < (size.x / 2) {
            gridLines.append(GridLine(startingPoint: x, direction: .horizontal))
            x += scalingFactor
        }

        while y < (size.y / 2) {
            gridLines.append(GridLine(startingPoint: y, direction: .vertical))
            y += scalingFactor
        }
    }

    func setupCells() {
        // build up cells
        for var x in 0 ..< size.x {
            for var y in 0 ..< size.y {
                cells.append(Cell(x: x, y: y))
                x += scalingFactor
                y += scalingFactor
            }
        }
        print("Setup cells", cells)
    }

    // basically the run loop call
    func update() {
        moveAgents()
        grow()
    }

    // agents move and then eat what's on the given cell
    private func moveAgents() {
        for agent in agents {
            agent.move(maxWidth: size.x, maxHeight: size.y)
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

class GridLine {
    let startingPoint: Int
    let direction: Direction

    enum Direction {
        case horizontal
        case vertical
    }

    init(startingPoint: Int, direction: Direction) {
        self.startingPoint = startingPoint
        self.direction = direction
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
    let uniqueID: UUID
    var x: Int
    var y: Int
    var storedSugar = 0

    init(x: Int, y: Int) {
        self.uniqueID = UUID()
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
