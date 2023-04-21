//
//  GameScene.swift
//  Bejangled
//
//  Created by Tiger Nixon on 4/17/23.
//

import Foundation
import SpriteKit

class GameScene: SKScene {
    
    lazy var game: Game = {
       Game(scene: self)
    }()
    
    override init() {
        super.init()
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        game.load()
    }
    
    private var lastTime: TimeInterval?
    override func update(_ currentTime: TimeInterval) {
        if let lastTime = lastTime {
            game.update(deltaTime: CGFloat(currentTime - lastTime))
        } else {
            game.update(deltaTime: 0.0)
        }
        lastTime = currentTime
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: nil)
            game.touchBegan(touch: touch, x: point.x, y: point.y)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: nil)
            game.touchMoved(touch: touch, x: point.x, y: point.y)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: nil)
            game.touchEnded(touch: touch, x: point.x, y: point.y)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: nil)
            game.touchEnded(touch: touch, x: point.x, y: point.y)
        }
    }
    
}
