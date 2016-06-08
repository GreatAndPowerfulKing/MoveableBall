//
//  MoveableBallScene.swift
//  Moveable ball
//
//  Created by iKing on 11.07.15.
//  Copyright (c) 2015 iKing. All rights reserved.
//

import SpriteKit

class MoveableBallScene: SKScene {
    
    enum GameState {
        case Play, Pause, GameOver
    }
    
    struct Constants {
        static let BallNodeName = "ballNode"
        static let PauseButtonNodeName = "pauseButton"
        static let PipesAppearanceInterval = 1.2
    }
    
    var gameState: GameState {
        didSet {
            switch gameState {
            case .Play:
                paused = false
                messageLayer?.removeFromParent()
                messageLayer = nil
            case .Pause:
                paused = true
                showMessage("Tap anywhere to continue...")
            case .GameOver:
                paused = true
                showMessage("Tap anywhere to start new game...")
            }
        }
    }
    
    let ballTexture = SKTexture(imageNamed: "Spaceship")
    let pipeTexture = SKTexture(imageNamed: "pipe")
    
    let ballNode: SKSpriteNode
    let scoreLabelNode = SKLabelNode()
    let pauseButton = SKLabelNode()
    
    var tap: UITapGestureRecognizer!
    var swipeUp: UISwipeGestureRecognizer!
    var swipeDown: UISwipeGestureRecognizer!
    
    let positions: [CGFloat]
    let defaultXPosition = CGFloat(0)
    var currentPositionIndex: Int
    
    let pipesLayer = SKNode()
    var messageLayer: SKSpriteNode!
    
    var pipesAppearanceInterval = 1.2
    let pipesAppearanceIntervalDecrement = 0.02
    
    var pipesMovingTime = 3.0
    let pipesMovingTimeDecrement = 0.05
    
    var score = 0
        
    override init(size: CGSize) {
        
        ballNode = SKSpriteNode(texture: ballTexture)
        ballNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        ballNode.zRotation = CGFloat(-M_PI / 2)
        ballNode.size = CGSize(width: 50, height: 50)
        
        positions = [-size.height / 4, 0, size.height / 4]
        currentPositionIndex = 1
        
        gameState = .Play
        
        super.init(size: size)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = SKColor.blueColor()
        self.scaleMode = .AspectFit
        ballNode.name = Constants.BallNodeName
        ballNode.position = CGPoint(x: defaultXPosition, y: positions[currentPositionIndex])
        
        scoreLabelNode.position = CGPoint(x: -size.width / 2 + 20, y: size.height / 2 - 50)
        scoreLabelNode.fontName = "Helvetica"
        scoreLabelNode.fontSize = 18
        scoreLabelNode.horizontalAlignmentMode = .Left
        scoreLabelNode.text = "Score: 0"
        
        pauseButton.name = Constants.PauseButtonNodeName
        pauseButton.position = CGPoint(x: size.width / 2 - 20, y: size.height / 2 - 50)
        pauseButton.fontName = "Helvetica"
        pauseButton.fontSize = 18
        pauseButton.horizontalAlignmentMode = .Right
        pauseButton.text = "Pause"
        
        self.addChild(ballNode)
        self.addChild(pipesLayer)
        self.addChild(scoreLabelNode)
        self.addChild(pauseButton)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp(_:)))
        swipeUp.direction = .Up
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown(_:)))
        swipeDown.direction = .Down
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeUp)
        view.addGestureRecognizer(swipeDown)
        
        addPipe()
    }
    
    override func willMoveFromView(view: SKView) {
        view.removeGestureRecognizer(tap)
        view.removeGestureRecognizer(swipeUp)
        view.removeGestureRecognizer(swipeDown)
    }
    
    func updatePosition(animated: Bool = true) {
        let destination = CGPoint(x: defaultXPosition, y: positions[currentPositionIndex])
        if animated {
            ballNode.removeAllActions()
            ballNode.runAction(SKAction.moveTo(destination, duration: 0.8, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1))
        } else {
            ballNode.position = destination
        }
    }
    
    func tap(sender: UITapGestureRecognizer) {
        switch gameState {
        case .Play:
            let tapLocation = sender.locationInView(view)
            if let name = nodeAtPoint(CGPoint(x: tapLocation.x - size.width / 2, y: size.height / 2 - tapLocation.y)).name
                where name == Constants.PauseButtonNodeName {
                gameState = .Pause
            }
        case .Pause:
            gameState = .Play
        case .GameOver:
            startNewGame()
        }
    }
    
    func swipedUp(sender: UISwipeGestureRecognizer) {
        if currentPositionIndex < positions.count - 1 {
            currentPositionIndex += 1
            updatePosition()
        }
    }
    
    func swipedDown(sender: UISwipeGestureRecognizer) {
        if currentPositionIndex > 0 {
            currentPositionIndex -= 1
            updatePosition()
        }
    }
    
    func addPipe() {
        addPipeAtPosition(Int.random(positions.count))
        let addingPipes = SKAction.sequence([SKAction.waitForDuration(pipesAppearanceInterval), SKAction.performSelector(#selector(addPipe), onTarget: self)])
        self.runAction(addingPipes)
    }
    
    func addPipeAtPosition(positionIndex: Int) {
        
        guard (0 ..< positions.count).contains(positionIndex) else {
            return
        }
        
        let pipe = SKSpriteNode()
        let upPipePart = SKSpriteNode(texture: pipeTexture)
        let downPipePart = SKSpriteNode(texture: pipeTexture)
        upPipePart.zRotation = CGFloat(M_PI)
        upPipePart.anchorPoint = CGPoint(x: 0.5, y: 1)
        downPipePart.anchorPoint = CGPoint(x: 0.5, y: 1)
        upPipePart.position = CGPoint(x: 0, y: 50)
        downPipePart.position = CGPoint(x: 0, y: -50)
        
        pipe.addChild(upPipePart)
        pipe.addChild(downPipePart)
        pipe.position = CGPoint(x: size.width / 2 + downPipePart.size.width, y: positions[positionIndex])
        pipe.userData = ["passed": false]
        
        pipesLayer.addChild(pipe)
        
        pipe.runAction(SKAction.sequence([
            SKAction.moveTo(CGPoint(x: -(size.width / 2 + downPipePart.size.width), y: positions[positionIndex]), duration: pipesMovingTime),
            SKAction.removeFromParent()]))
        
        if pipesMovingTime > 1.5 {
            pipesAppearanceInterval -= pipesAppearanceIntervalDecrement
            pipesMovingTime -= pipesMovingTimeDecrement
        }
    }
    
    override func update(currentTime: NSTimeInterval) {
        var pipes = pipesLayer.children
        if !pipes.isEmpty {
            pipes.sortInPlace({ abs($0.position.x) < abs($1.position.x) })
//            for i in 0..<min(2, pipes.count) {
            for i in 0..<pipes.count {
            
                let pipeParts = pipes[i].children
                
                for part in pipeParts as! [SKSpriteNode] {
                    if part.intersectsNode(ballNode) {
                        part.color = SKColor.redColor()
                        part.colorBlendFactor = 1
                        pipes[i].userData = ["passed": true]
                        
                        gameState = .GameOver
                    }
                }
                
                if pipes[i].position.x < ballNode.position.x - ballNode.size.width && !(pipes[i].userData!["passed"] as! Bool) {
                    pipes[i].userData = ["passed": true]
                    score += 1
                    scoreLabelNode.text = "Score: \(score)"
                }
            }
        }
    }
    
    func startNewGame() {
        if let skView = self.view {
            skView.presentScene(MoveableBallScene(size: skView.bounds.size))
            self.removeFromParent()
        }
    }
    
    func showMessage(message: String) {
        messageLayer = SKSpriteNode()
        let label = SKLabelNode(text: message)
        label.fontName = "Helvetica"
        label.fontSize = 22
        messageLayer.addChild(label)
        addChild(messageLayer)
    }
    
    func screenShot() -> UIImage {
        //        UIGraphicsBeginImageContext(CGSizeMake(view!.frame.size.width, view!.frame.size.height))
        UIGraphicsBeginImageContext(CGSizeMake(view!.frame.size.width * 2, view!.frame.size.height * 2))
        
        UIGraphicsGetCurrentContext()
        //        self.view?.drawViewHierarchyInRect(view!.frame, afterScreenUpdates: true)
        self.view?.drawViewHierarchyInRect(CGRect(origin: view!.frame.origin, size: CGSize(width: view!.frame.size.width * 2, height: view!.frame.size.height * 2)), afterScreenUpdates: true)
        
        let screenShot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return screenShot
    }
}