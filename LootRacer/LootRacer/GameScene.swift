import SpriteKit

class GameScene: SKScene {

    // MARK: - Tuning knobs
    // These control how the car feels. Ask me to adjust any of them.
    private let maxSpeed: CGFloat = 300        // top speed, in points per second
    private let acceleration: CGFloat = 260    // how quickly the car speeds up
    private let coastFriction: CGFloat = 420   // how quickly it slows when you let go
    private let turnRate: CGFloat = 3.2        // how sharply it turns at full speed

    // MARK: - Car state
    private var car = SKNode()
    private var carSpeed: CGFloat = 0
    private var heading: CGFloat = .pi / 2     // direction of travel; π/2 = straight up

    // MARK: - Input state
    private var steerInput: CGFloat = 0        // +1 = turning left, -1 = right, 0 = straight
    private var isAccelerating = false

    // MARK: - Misc
    private var lastUpdateTime: TimeInterval = 0
    private let speedLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    // MARK: - Scene setup

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.18, green: 0.18, blue: 0.20, alpha: 1.0)

        buildCar()
        car.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(car)

        // Speed readout at the bottom of the screen
        speedLabel.fontSize = 28
        speedLabel.fontColor = .white
        speedLabel.position = CGPoint(x: frame.midX, y: 60)
        speedLabel.text = "0 mph"
        addChild(speedLabel)

        // Control hint at the top
        let hint = SKLabelNode(fontNamed: "AvenirNext-Medium")
        hint.fontSize = 16
        hint.fontColor = SKColor(white: 1.0, alpha: 0.6)
        hint.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        hint.text = "Hold to drive  •  Left / right side to steer"
        addChild(hint)
    }

    private func buildCar() {
        let bodySize = CGSize(width: 44, height: 80)
        let body = SKShapeNode(rectOf: bodySize, cornerRadius: 10)
        body.fillColor = SKColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1.0)
        body.strokeColor = .black
        body.lineWidth = 2
        car.addChild(body)

        let windshield = SKShapeNode(rectOf: CGSize(width: 30, height: 16), cornerRadius: 4)
        windshield.fillColor = SKColor(red: 0.55, green: 0.75, blue: 0.95, alpha: 1.0)
        windshield.strokeColor = .clear
        windshield.position = CGPoint(x: 0, y: 18)
        car.addChild(windshield)

        let spoiler = SKShapeNode(rectOf: CGSize(width: 40, height: 8), cornerRadius: 3)
        spoiler.fillColor = .black
        spoiler.strokeColor = .clear
        spoiler.position = CGPoint(x: 0, y: -38)
        car.addChild(spoiler)

        let wheelSize = CGSize(width: 10, height: 20)
        let wheelPositions = [
            CGPoint(x: -25, y: 24), CGPoint(x: 25, y: 24),
            CGPoint(x: -25, y: -24), CGPoint(x: 25, y: -24)
        ]
        for position in wheelPositions {
            let wheel = SKShapeNode(rectOf: wheelSize, cornerRadius: 4)
            wheel.fillColor = .black
            wheel.strokeColor = .clear
            wheel.position = position
            wheel.zPosition = -1
            car.addChild(wheel)
        }
    }

    // MARK: - Touch input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateInput(from: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateInput(from: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateInput(from: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateInput(from: event)
    }

    /// Looks at every finger currently on the screen and decides:
    /// - Any finger down = accelerate
    /// - Finger on left half = steer left, right half = steer right
    /// - One finger on each side = go straight
    private func updateInput(from event: UIEvent?) {
        let activeTouches = (event?.allTouches ?? []).filter {
            $0.phase != .ended && $0.phase != .cancelled
        }

        isAccelerating = !activeTouches.isEmpty

        var steer: CGFloat = 0
        for touch in activeTouches {
            let x = touch.location(in: self).x
            steer += (x < frame.midX) ? 1 : -1
        }
        steerInput = max(-1, min(1, steer))
    }

    // MARK: - Game loop (runs ~60 times per second)

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime }
        let dt = CGFloat(min(currentTime - lastUpdateTime, 1.0 / 30.0))
        lastUpdateTime = currentTime

        // Speed up while touching, coast down when not
        if isAccelerating {
            carSpeed = min(carSpeed + acceleration * dt, maxSpeed)
        } else {
            carSpeed = max(carSpeed - coastFriction * dt, 0)
        }

        // Steering only works when the car is actually moving
        let speedFactor = min(carSpeed / 120, 1)
        heading += steerInput * turnRate * speedFactor * dt

        // Move the car along its heading and rotate the sprite to match
        car.position.x += cos(heading) * carSpeed * dt
        car.position.y += sin(heading) * carSpeed * dt
        car.zRotation = heading - .pi / 2

        wrapAroundEdges()

        speedLabel.text = "\(Int(carSpeed / 3)) mph"
    }

    /// Until we have a track, let the car loop around the screen edges
    private func wrapAroundEdges() {
        let margin: CGFloat = 50
        if car.position.x < -margin { car.position.x = frame.maxX + margin }
        if car.position.x > frame.maxX + margin { car.position.x = -margin }
        if car.position.y < -margin { car.position.y = frame.maxY + margin }
        if car.position.y > frame.maxY + margin { car.position.y = -margin }
    }
}
