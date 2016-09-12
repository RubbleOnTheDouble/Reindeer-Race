//
//  GameScene.swift
//  Reindeer Race
//
//  Created by Colleen Prescod on 2016-09-03.
//  Copyright (c) 2016 Colleen Prescod. All rights reserved.
//

import SpriteKit


struct GamePhysics {
    static let Reindeer : UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Reindeer = SKSpriteNode()
    
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    var gameStarted = Bool()
    
    var score = Int()
    var scoreLabel = SKLabelNode()
    
    var died = Bool()
    var restartBtn = SKSpriteNode()
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
    }
    
    func createScene(){
        
        self.physicsWorld.contactDelegate = self
        
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "bgsnow")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background"
            background.size = (self.view?.bounds.size)!
    
            self.addChild(background)
        }
        
        
        
        scoreLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLabel.text = "\(score)"
        scoreLabel.fontName = "Candy Cane (Unregistered)"
        scoreLabel.zPosition = 6
        scoreLabel.fontSize = 80
        
        self.addChild(scoreLabel)
        
        
        
        Ground = SKSpriteNode(imageNamed: "groundsnow")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = GamePhysics.Ground
        Ground.physicsBody?.collisionBitMask = GamePhysics.Reindeer
        Ground.physicsBody?.contactTestBitMask = GamePhysics.Reindeer
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        
        
        Reindeer = SKSpriteNode(imageNamed: "reindeer1")
        Reindeer.size = CGSize(width: 60, height: 70)
        Reindeer.position = CGPoint(x: self.frame.width / 2 - Reindeer.frame.width, y: self.frame.height / 2)
        
        Reindeer.physicsBody = SKPhysicsBody(circleOfRadius: Reindeer.frame.height / 2)
        Reindeer.physicsBody?.categoryBitMask = GamePhysics.Reindeer
        Reindeer.physicsBody?.collisionBitMask = GamePhysics.Ground | GamePhysics.Wall
        Reindeer.physicsBody?.contactTestBitMask = GamePhysics.Ground | GamePhysics.Wall | GamePhysics.Score
        Reindeer.physicsBody?.affectedByGravity = false
        Reindeer.physicsBody?.dynamic = true
        Reindeer.zPosition = 2
        
        self.addChild(Reindeer)
 
    }
    
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        createScene()
    }
    
    
    
    func createBtn(){
        restartBtn = SKSpriteNode(imageNamed: "santa")
        restartBtn.size = CGSizeMake(200, 100)
        restartBtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartBtn.zPosition = 6
        restartBtn.setScale(0)
        
        self.addChild(restartBtn)
        
        restartBtn.runAction(SKAction.scaleTo(1.0, duration: 0.3))
    }
    
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == GamePhysics.Score && secondBody.categoryBitMask == GamePhysics.Reindeer{
            score+=1
            scoreLabel.text = "\(score)"
            firstBody.node?.removeFromParent()
        }
        
        else if firstBody.categoryBitMask == GamePhysics.Reindeer && secondBody.categoryBitMask == GamePhysics.Score{
            score+=1
            scoreLabel.text = "\(score)"
            secondBody.node?.removeFromParent()
        }
        
        else if firstBody.categoryBitMask == GamePhysics.Reindeer && secondBody.categoryBitMask == GamePhysics.Wall || firstBody.categoryBitMask == GamePhysics.Wall && secondBody.categoryBitMask == GamePhysics.Reindeer{
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            }))
            
            if died == false{
            died = true
            createBtn()
            }
        }
        
        else if firstBody.categoryBitMask == GamePhysics.Reindeer && secondBody.categoryBitMask == GamePhysics.Ground || firstBody.categoryBitMask == GamePhysics.Ground && secondBody.categoryBitMask == GamePhysics.Reindeer{
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            }))
            
            if died == false{
                died = true
                createBtn()
            }
        }

}
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if gameStarted == false{
            
            gameStarted = true
            
            Reindeer.physicsBody?.affectedByGravity = true
        
            let spawn = SKAction.runBlock({
                () in
                self.createWalls()
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatActionForever(SpawnDelay)
            self.runAction(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width)
            let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval (0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Reindeer.physicsBody?.velocity = CGVectorMake (0, 0)
            Reindeer.physicsBody?.applyImpulse(CGVectorMake(0, 90))
        }
        
        else{
            
            if died == true {
            
            }
            else{
            Reindeer.physicsBody?.velocity = CGVectorMake (0, 0)
            Reindeer.physicsBody?.applyImpulse(CGVectorMake(0, 90))
            }
        }
        
        
        for touch in touches{
            let location = touch.locationInNode(self)
            
            if died == true{
                if restartBtn.containsPoint(location){
                    restartScene()
                }
                
            }
        }
}
    
    
    func createWalls(){
        
        let scoreNode = SKSpriteNode(imageNamed: "present")
        
        scoreNode.size = CGSize(width: 50, height: 50)
        scoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.dynamic = false
        scoreNode.physicsBody?.categoryBitMask = GamePhysics.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = GamePhysics.Reindeer
        scoreNode.color = SKColor.blueColor()
        
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "column")
        let bottomWall = SKSpriteNode(imageNamed: "column")
        
        topWall.position = CGPoint(x:self.frame.width + 25, y: self.frame.height / 2 + 350)
        bottomWall.position = CGPoint(x:self.frame.width + 25, y: self.frame.height / 2 - 250)
        
        topWall.setScale(0.5)
        bottomWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize: topWall.size)
        topWall.physicsBody?.categoryBitMask = GamePhysics.Wall
        topWall.physicsBody?.collisionBitMask = GamePhysics.Reindeer
        topWall.physicsBody?.contactTestBitMask = GamePhysics.Reindeer
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOfSize: bottomWall.size)
        bottomWall.physicsBody?.categoryBitMask = GamePhysics.Wall
        bottomWall.physicsBody?.collisionBitMask = GamePhysics.Reindeer
        bottomWall.physicsBody?.contactTestBitMask = GamePhysics.Reindeer
        bottomWall.physicsBody?.dynamic = false
        bottomWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        
        wallPair.zPosition = 1
        
        var randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
    }
   
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted == true{
            if died == false{
                enumerateChildNodesWithName("background", usingBlock: ({
                    (node, error) in
                    
                    var bg = node as! SKSpriteNode
                    
                    bg.position = CGPoint(x: bg.position.x - 25, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width{
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                    }
                }))
            }
        }
    }
}
