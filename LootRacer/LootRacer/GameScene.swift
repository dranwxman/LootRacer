import SpriteKit

class GameScene: SKScene {

    // The player's car — built from simple shapes so we don't need
    // any image assets yet. We'll swap in real artwork later.
    private var car = SKNode()

    override func didMove(to view: SKView) {
        // Asphalt-gray background
        backgroundColor = SKColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1.0)

        buildCar()
        car.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(car)
    }

    private func buildCar() {
        // Car body: a rounded rectangle, nose pointing "up" the screen
        let bodySize = CGSize(width: 44, height: 80)
        let body = SKShapeNode(rectOf: bodySize, cornerRadius: 10)
        body.fillColor = SKColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1.0) // red
        body.strokeColor = .black
        body.lineWidth = 2
        car.addChild(body)

        // Windshield near the front so we can tell which way it faces
        let windshield = SKShapeNode(rectOf: CGSize(width: 30, height: 16), cornerRadius: 4)
        windshield.fillColor = SKColor(red: 0.55, green: 0.75, blue: 0.95, alpha: 1.0)
        windshield.strokeColor = .clear
        windshield.position = CGPoint(x: 0, y: 18)
        car.addChild(windshield)

        // Rear spoiler
        let spoiler = SKShapeNode(rectOf: CGSize(width: 40, height: 8), cornerRadius: 3)
        spoiler.fillColor = .black
        spoiler.strokeColor = .clear
        spoiler.position = CGPoint(x: 0, y: -38)
        car.addChild(spoiler)

        // Four wheels
        let wheelSize = CGSize(width: 10, height: 20)
        let wheelPositions = [
            CGPoint(x: -25, y: 24),  // front left
            CGPoint(x: 25, y: 24),   // front right
            CGPoint(x: -25, y: -24), // rear left
            CGPoint(x: 25, y: -24)   // rear right
        ]
        for position in wheelPositions {
            let wheel = SKShapeNode(rectOf: wheelSize, cornerRadius: 4)
            wheel.fillColor = .black
            wheel.strokeColor = .clear
            wheel.position = position
            wheel.zPosition = -1 // tuck slightly under the body
            car.addChild(wheel)
        }
    }

    override func update(_ currentTime: TimeInterval) {
        // Called once per frame (~60x per second).
        // Phase 2 will use this for driving physics.
    }
}
