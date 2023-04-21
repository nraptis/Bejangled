//
//  Tile.swift
//  Bejangled
//
//  Created by Tiger Nixon on 4/17/23.
//

import Foundation
import SpriteKit

class Tile {
    
    var spriteNode: SKSpriteNode!
    
    static let width: CGFloat = 64.0
    static let height: CGFloat = 64.0
    
    var index: Int
    var gridX: Int
    var gridY: Int
    
    var isFalling = false
    var fallTargetY: CGFloat = 0.0
    var fallSpeed: CGFloat = 0.0
    
    var isMatching = false
    
    let board: Board
    
    required init(board: Board, index: Int, gridX: Int, gridY: Int) {
        self.board = board
        self.index = index
        self.gridX = gridX
        self.gridY = gridY
    }
    
    func spawn() {
        
        if index == 0 {
            spriteNode = SKSpriteNode(texture: board.game.tileTexture0)
        }
        if index == 1 {
            spriteNode = SKSpriteNode(texture: board.game.tileTexture1)
        }
        if index == 2 {
            spriteNode = SKSpriteNode(texture: board.game.tileTexture2)
        }
        if index == 3 {
            spriteNode = SKSpriteNode(texture: board.game.tileTexture3)
        }
        
        let x = board.tileX(gridX: gridX)
        let y = board.tileY(gridY: gridY)
        let width = board.game.tileWidth
        let height = board.game.tileHeight
        
        spriteNode.position = CGPoint(x: x, y: y)
        spriteNode.size = CGSize(width: width, height: height)
        
        board.game.scene.addChild(spriteNode)
        
    }
    
    func fall(to y: CGFloat) {
        isFalling = true
        
        fallTargetY = y
        
        fallSpeed = board.game.tileHeight * 0.025
        
        
    }
    
    func update(deltaTime: CGFloat) {
        if isFalling {
            fallSpeed += deltaTime * board.game.tileHeight * 0.25
            spriteNode.position.y -= fallSpeed
            if spriteNode.position.y <= fallTargetY {
                spriteNode.position.y = fallTargetY
                isFalling = false
            }
        }
    }
    
}
