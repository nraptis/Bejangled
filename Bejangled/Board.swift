//
//  Board.swift
//  Bejangled
//
//  Created by Tiger Nixon on 4/17/23.
//

import Foundation
import SpriteKit
import AVFAudio

class Board: NSObject {
    
    static let paddingLeft: CGFloat = 24.0
    static let paddingRight: CGFloat = 24.0
    
    static let gridWidth = 8
    static let gridHeight = 8
    
    var isToppling = false
    var landSoundTime: CGFloat = 0.0
    
    var isMatching = false
    var matchTime = 0.0
    
    var matchAnimationNodes = [SKNode]()
    
    var grid = [[Tile?]](repeating: [Tile?](repeating: nil, count: gridWidth), count: gridHeight)
    var matched = [[Bool]](repeating: [Bool](repeating: false, count: gridWidth), count: gridHeight)
    
    let game: Game
    let scene: GameScene
    init(game: Game, scene: GameScene) {
        self.game = game
        self.scene = scene
    }
    
    func getGridX(mouseX: CGFloat) -> Int? {
        var x = mouseX
        x -= game.boardX / game.sceneSizeFactor
        let gridX = Int(x / (game.tileWidth / game.sceneSizeFactor))
        if gridX >= 0 && gridX < Board.gridWidth {
            return gridX
        } else {
            return nil
        }
    }
    func getGridY(mouseY: CGFloat) -> Int? {
        var y = mouseY
        y = (game.window.bounds.size.height - y)
        y -= game.boardY / game.sceneSizeFactor
        y = -y
        let gridY = Int(y / (game.tileHeight / game.sceneSizeFactor))
        if gridY >= 0 && gridY < Board.gridHeight {
            return gridY
        } else {
            return nil
        }
    }
    
    func nodeX(gridX: Int) -> CGFloat {
        game.boardX + game.tileWidth * CGFloat(gridX)
    }
    
    func nodeY(gridY: Int) -> CGFloat {
        game.boardY - game.tileHeight * CGFloat(gridY)
    }
    
    func tileX(gridX: Int) -> CGFloat {
        game.boardX + game.tileWidth * CGFloat(gridX) + game.tileWidth * 0.5
    }
    
    func tileY(gridY: Int) -> CGFloat {
        game.boardY - game.tileHeight * CGFloat(gridY) - game.tileHeight * 0.5
    }
    
    func load() {
        spawn()
    }
    
    func spawn() {
        
        var reloop = true
        
        for gridX in 0..<Self.gridWidth {
            for gridY in 0..<Self.gridHeight {
                grid[gridX][gridY] = Tile(board: self,
                                          index: -1,
                                          gridX: gridX,
                                          gridY: gridY)
            }
        }
        
        while reloop {
            reloop = false
            
            for gridX in 0..<Self.gridWidth {
                for gridY in 0..<Self.gridHeight {
                    grid[gridX][gridY]?.index = -1
                }
            }
            
            for gridX in 0..<Self.gridWidth {
                for gridY in 0..<Self.gridHeight {
                    while true {
                        grid[gridX][gridY]?.index = Int.random(in: 0..<4)
                        if !isMatch(gridX: gridX, gridY: gridY) {
                            break
                        }
                    }
                }
            }
        }
        
        for gridX in 0..<Self.gridWidth {
            for gridY in 0..<Self.gridHeight {
                grid[gridX][gridY]?.spawn()
            }
        }
    }
    
    func update(deltaTime: CGFloat) {
        
        if landSoundTime > 0.0 {
            landSoundTime -= deltaTime
            if landSoundTime <= 0.0 {
                landSoundTime = 0.0
            }
        }
        
        if isMatching {
            matchTime -= deltaTime
            if matchTime <= 0.0 {
                matchTime = 0.0
                isMatching = false
                finishMatching()
            }
        }
        
        var didAnyTileLand = false
        var fallingCount = 0
        for gridX in 0..<Self.gridWidth {
            for gridY in 0..<Self.gridHeight {
                guard let tile = grid[gridX][gridY] else { continue }
                var fallingBefore = tile.isFalling
                tile.update(deltaTime: deltaTime)
                if tile.isFalling == false && fallingBefore == true {
                    didAnyTileLand = true
                }
                if tile.isFalling {
                    fallingCount += 1
                }
            }
        }
        
        if didAnyTileLand {
            if landSoundTime == 0.0 {
                game.soundNodeLanded.run(SKAction.play())
                landSoundTime = 0.125
            }
        }
        
        if isToppling && fallingCount == 0 {
            isToppling = false
            processAllMatches()
        }
        
    }
    
    func touchBegan(touch: UITouch, x: CGFloat, y: CGFloat) {
        
    }
    
    func touchMoved(touch: UITouch, x: CGFloat, y: CGFloat) {
        
    }
    
    func touchEnded(touch: UITouch, x: CGFloat, y: CGFloat) {
        
    }
    
    func moveTileToTop(gridX: Int, gridY: Int) {
        if let tile = getTile(gridX: gridX, gridY: gridY) {
            tile.spriteNode.removeFromParent()
            game.scene.addChild(tile.spriteNode)
        }
        for _gridX in 0..<Board.gridWidth {
            for _gridY in 0..<Board.gridHeight {
                if gridX == _gridX && gridY == _gridY {
                    grid[gridX][gridY]?.spriteNode?.zPosition = 1024.0
                } else {
                    grid[gridX][gridY]?.spriteNode?.zPosition = 0.0
                }
            }
        }
    }
    
    func getTile(gridX: Int, gridY: Int) -> Tile? {
        if gridX >= 0 && gridX < Board.gridWidth && gridY >= 0 && gridY < Board.gridHeight {
            return grid[gridX][gridY]
        }
        return nil
    }
    
    func isMatch(gridX: Int, gridY: Int) -> Bool {
        if isMatchH(gridX: gridX, gridY: gridY) { return true }
        if isMatchV(gridX: gridX, gridY: gridY) { return true }
        return false
    }
    
    func isMatchH(gridX: Int, gridY: Int) -> Bool {
        
        guard let index = grid[gridX][gridY]?.index else { return false }
        
        var matchCount = 1
        var seekH = gridX - 1
        while seekH >= 0 {
            guard let tile = grid[seekH][gridY] else { break }
            guard tile.index == index else { break }
            matchCount += 1
            seekH -= 1
        }
        seekH = gridX + 1
        while seekH < Self.gridWidth {
            guard let tile = grid[seekH][gridY] else { break }
            guard tile.index == index else { break }
            matchCount += 1
            seekH += 1
        }
        
        return matchCount >= 3
    }
    
    func isMatchV(gridX: Int, gridY: Int) -> Bool {
        guard let index = grid[gridX][gridY]?.index else { return false }
        var matchCount = 1
        var seekV = gridY - 1
        while seekV >= 0 {
            guard let tile = grid[gridX][seekV] else { break }
            guard tile.index == index else { break }
            matchCount += 1
            seekV -= 1
        }
        seekV = gridY + 1
        while seekV < Self.gridWidth {
            guard let tile = grid[gridX][seekV] else { break }
            guard tile.index == index else { break }
            matchCount += 1
            seekV += 1
        }
        return matchCount >= 3
    }
    
    func processAllMatches() {
        for gridX in 0..<Board.gridWidth {
            for gridY in 0..<Board.gridHeight {
                matched[gridX][gridY] = false
            }
        }
        
        for gridX in 0..<Board.gridWidth {
            for gridY in 0..<Board.gridHeight {
                if matched[gridX][gridY] { continue }
                if isMatchH(gridX: gridX, gridY: gridY) {
                    if let index = grid[gridX][gridY]?.index {
                        matched[gridX][gridY] = true
                        
                        var seekH = gridX - 1
                        while seekH >= 0 {
                            guard let tile = grid[seekH][gridY] else { break }
                            guard tile.index == index else { break }
                            matched[seekH][gridY] = true
                            seekH -= 1
                        }
                        seekH = gridX + 1
                        while seekH < Self.gridWidth {
                            guard let tile = grid[seekH][gridY] else { break }
                            guard tile.index == index else { break }
                            matched[seekH][gridY] = true
                            seekH += 1
                        }
                    }
                }
                
                if isMatchV(gridX: gridX, gridY: gridY) {
                    if let index = grid[gridX][gridY]?.index {
                        
                        matched[gridX][gridY] = true
                        
                        var seekV = gridY - 1
                        while seekV >= 0 {
                            guard let tile = grid[gridX][seekV] else { break }
                            guard tile.index == index else { break }
                            matched[gridX][seekV] = true
                            seekV -= 1
                        }
                        seekV = gridY + 1
                        while seekV < Self.gridWidth {
                            guard let tile = grid[gridX][seekV] else { break }
                            guard tile.index == index else { break }
                            matched[gridX][seekV] = true
                            seekV += 1
                        }
                    }
                }
            }
        }
        processAllMatchesWithMatchGridPopulated()
    }
    
    private func processAllMatchesWithMatchGridPopulated() {
        
        var didAnyMatchOccur = false
        for gridX in 0..<Board.gridWidth {
            for gridY in 0..<Board.gridHeight {
                if matched[gridX][gridY] {
                    if let tile = grid[gridX][gridY] {
                        didAnyMatchOccur = true
                        tile.isMatching = true
                        matchAnimation(gridX: gridX, gridY: gridY)
                    }
                }
            }
        }
        
        if didAnyMatchOccur {
            isMatching = true
            matchTime = 0.25
            game.soundNodePrematch.run(SKAction.play())
        }
        
    }
    
    private func finishMatching() {
        
        for node in matchAnimationNodes {
            node.removeFromParent()
        }
        matchAnimationNodes.removeAll()
        
        for gridX in 0..<Board.gridWidth {
            for gridY in 0..<Board.gridHeight {
                if matched[gridX][gridY] {
                    if let tile = grid[gridX][gridY] {
                        tile.spriteNode.removeFromParent()
                        grid[gridX][gridY] = nil
                        explosionAnimation(gridX: gridX, gridY: gridY)
                        game.score += 100
                    }
                }
            }
        }
        
        topple()
        game.soundNodeMatch.run(SKAction.play())
        
    }
    
    func topple() {
        
        for gridX in 0..<Board.gridWidth {
            var gridY = Board.gridHeight - 1
            var fallCount = 0
            while gridY >= 0 {
                
                if let tile = getTile(gridX: gridX, gridY: gridY) {
                    
                    grid[gridX][gridY] = nil
                    grid[gridX][gridY + fallCount] = tile
                    tile.gridY = gridY + fallCount
                    
                    let targetY = tileY(gridY: gridY + fallCount)
                    tile.fall(to: targetY)
                    
                } else {
                    isToppling = true
                    fallCount += 1
                }
                gridY -= 1
            }
            
            fillColumn(gridX: gridX, count: fallCount)
        }
    }
    
    private func fillColumn(gridX: Int, count: Int) {
        
        let x = tileX(gridX: gridX)
        var y = game.height + game.tileHeight / 2.0
        for i in 0..<count {
            
            let gridY = count - 1 - i
            let tile = Tile(board: self, index: Int.random(in: 0..<4), gridX: gridX, gridY: gridY)
            grid[gridX][gridY] = tile
            
            // Try to have this not match...
            for _ in 0..<10 {
                if isMatch(gridX: gridX, gridY: gridY) {
                    tile.index = Int.random(in: 0..<4)
                } else {
                    break
                }
            }
            
            tile.spawn()
            tile.spriteNode.position.x = x
            tile.spriteNode.position.y = y
            let targetY = tileY(gridY: gridY)
            tile.fall(to: targetY)
            y += game.tileHeight
        }
        
    }

    private func explosionAnimation(gridX: Int, gridY: Int) {
        
        let x = tileX(gridX: gridX)
        let y = tileY(gridY: gridY)
        
        let size = game.tileWidth * 2.5
        
        let node = SKSpriteNode()
        game.scene.addChild(node)
        node.size = CGSize(width: size, height: size)
        
        let animateAction = SKAction.animate(with: game.animationBurstTextures, timePerFrame: 0.033)
        let removeAction = SKAction.removeFromParent()
        node.run(SKAction.sequence([animateAction, removeAction]))
        node.position = CGPoint(x: x, y: y)
        node.blendMode = .add
        
    }
    
    private func matchAnimation(gridX: Int, gridY: Int) {
        let x = tileX(gridX: gridX)
        let y = tileY(gridY: gridY)
        
        let size = game.tileWidth * 1.5
        
        let nodeSquare = SKSpriteNode()
        game.scene.addChild(nodeSquare)
        nodeSquare.size = CGSize(width: size, height: size)
        
        let animateAction = SKAction.animate(with: game.animationHighlightSquareTextures, timePerFrame: 0.033)
        //let removeAction = SKAction.removeFromParent()
        
        nodeSquare.run(SKAction.repeatForever(animateAction))
        nodeSquare.position = CGPoint(x: x, y: y)
        nodeSquare.blendMode = .add
        nodeSquare.alpha = 0.5
        nodeSquare.zPosition = 2048.0
        
        matchAnimationNodes.append(nodeSquare)
        
        
        
        let nodeHighlight = SKSpriteNode()
        game.scene.addChild(nodeHighlight)
        nodeHighlight.size = CGSize(width: size, height: size)
        nodeHighlight.run(SKAction.repeatForever(animateAction))
        nodeHighlight.position = CGPoint(x: x, y: y)
        nodeHighlight.blendMode = .add
        nodeHighlight.alpha = 0.5
        nodeHighlight.zPosition = 2050.0
        
        
        matchAnimationNodes.append(nodeHighlight)
        
        
    }
    
}
