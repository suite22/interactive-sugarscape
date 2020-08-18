import Foundation

/// Pure swift with no visuals to view any of the changes.
/// I'm going to update a 2D array with grow rates for suger.
/// I also want to get the basic objects talking to each other to manage that.

/// I've got the sugar growing, now let's add one agent who eats it

/// They mention in the book that there's a Population object which handles mass agent analysis

struct Environment {
    var cells: [Cell] = []
    var agents: [Agent] = []
    // maximum number of cells in each dimension
    let maxWidth: Int = 4
    let maxHeight: Int = 4

    mutating func setup() {
        // pretend cell width and height is just 1
        for x in 0..<maxWidth {
            for y in 0..<maxHeight {
                cells.append(Cell(x: x, y: y))
            }
        }

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
        guard sugar < 4 else {
            sugar = 0
            return
        }

        sugar += 1
        //print("Sugar level \(sugar): ", x, y)
    }

    var debugDescription: String {
        "\(x),\(y) sugar: \(sugar)"
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

var environ = Environment()
environ.setup()
environ.update()

Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
    environ.update()
})
