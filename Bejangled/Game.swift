//
//  Game.swift
//  Bejangled
//
//  Created by Tiger Nixon on 4/17/23.
//

import Foundation
import SpriteKit

class Game: NSObject {
    
    
    var scoreLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var boardX: CGFloat = 0.0
    var boardY: CGFloat = 0.0
    var boardWidth: CGFloat = 256.0
    var boardHeight: CGFloat = 256.0
    var tileWidth: CGFloat = 32.0
    var tileHeight: CGFloat = 32.0
    
    let soundNodeLanded = SKAudioNode(fileNamed: "tile_landed.caf")
    let soundNodeMatch = SKAudioNode(fileNamed: "match.caf")
    let soundNodePrematch = SKAudioNode(fileNamed: "prematch.caf")
    let soundNodeMatchFailed = SKAudioNode(fileNamed: "match_fail.caf")
    
    
    
    
    
    var selectedTile: Tile?
    var selectedTileTouch: UITouch?
    
    var isSwapping: Bool = false
    var isUserInitiatedSwap = false
    var swapTileAnimationPercent: CGFloat = 0.0
    var swapTile1: Tile?
    var swapTile2: Tile?
    
    var animationBurstTextures = [SKTexture]()
    var animationHighlightSquareTextures = [SKTexture]()
    var animationTileHighlightTextures = [SKTexture]()
    
    
    lazy var board: Board = {
        Board(game: self, scene: scene)
    }()
    
    let scene: GameScene
    init(scene: GameScene) {
        self.scene = scene
    }
    
    lazy var window: UIWindow = {
        guard let scene = UIApplication.shared.connectedScenes.first else {
            return UIWindow()
        }
        guard let windowScene = scene as? UIWindowScene else {
            return UIWindow()
        }
        guard let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }()
    
    lazy var sceneSizeFactor: CGFloat = {
        let factor: CGFloat
        if window.bounds.size.height > 1.0 {
            factor = height / window.bounds.size.height
        } else {
            factor = 1.0
        }
        return factor
    }()
    
    lazy var safeAreaTop: CGFloat = {
        window.safeAreaInsets.top * sceneSizeFactor
    }()
    
    lazy var safeAreaBottom: CGFloat = {
        window.safeAreaInsets.bottom * sceneSizeFactor
    }()
    
    lazy var safeAreaLeft: CGFloat = {
        window.safeAreaInsets.left * sceneSizeFactor
    }()
    
    lazy var safeAreaRight: CGFloat = {
        window.safeAreaInsets.right * sceneSizeFactor
    }()
    
    var tileTexture0: SKTexture!
    var tileTexture1: SKTexture!
    var tileTexture2: SKTexture!
    var tileTexture3: SKTexture!
    
    func load() {
        
        for i in 0...26 {
            let numberString: String
            if i < 10 {
                numberString = "0\(i)"
            } else {
                numberString = "\(i)"
            }
            let fileName = "burst_\(numberString)"
            
            if let image = UIImage(named: fileName) {
                let texture = SKTexture(image: image)
                animationBurstTextures.append(texture)
            }
        }
        
        for i in 0...11 {
            let numberString: String
            if i < 10 {
                numberString = "0\(i)"
            } else {
                numberString = "\(i)"
            }
            let fileName = "effect_hilight_square_\(numberString)"
            
            if let image = UIImage(named: fileName) {
                let texture = SKTexture(image: image)
                animationHighlightSquareTextures.append(texture)
            }
        }
        
        for i in 0...24 {
            let numberString: String
            if i < 10 {
                numberString = "0\(i)"
            } else {
                numberString = "\(i)"
            }
            let fileName = "effect_tile_highlight_\(numberString)"
            
            if let image = UIImage(named: fileName) {
                let texture = SKTexture(image: image)
                animationTileHighlightTextures.append(texture)
            }
        }
        
        if let tileImage = UIImage(named: "game_tile_0") {
            tileTexture0 = SKTexture(image: tileImage)
        }
        if let tileImage = UIImage(named: "game_tile_1") {
            tileTexture1 = SKTexture(image: tileImage)
        }
        if let tileImage = UIImage(named: "game_tile_2") {
            tileTexture2 = SKTexture(image: tileImage)
        }
        if let tileImage = UIImage(named: "game_tile_3") {
            tileTexture3 = SKTexture(image: tileImage)
        }
        
        soundNodeLanded.autoplayLooped = false
        scene.addChild(soundNodeLanded)
        
        soundNodeMatch.autoplayLooped = false
        scene.addChild(soundNodeMatch)
        
        soundNodeMatchFailed.autoplayLooped = false
        scene.addChild(soundNodeMatchFailed)
        
        soundNodePrematch.autoplayLooped = false
        scene.addChild(soundNodePrematch)
        
        
        
        computeGrid()
        board.load()
        
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: safeAreaLeft + tileWidth * 0.25,
                                      y: scene.size.height - safeAreaTop - tileHeight * 0.25)
        scoreLabel.fontName = "Chalkduster"
        scoreLabel.fontSize = 50.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scene.addChild(scoreLabel)
        
        
    }
    
    var width: CGFloat { scene.size.width }
    var height: CGFloat { scene.size.height }
    
    func computeGrid() {
        let safeAreaH = Int(safeAreaLeft + safeAreaRight + 0.5)
        let paddingH = Int(Board.paddingLeft + Board.paddingRight + 0.5)
        let availableScreenWidth = Int(width + 0.5) - safeAreaH - paddingH
        let baseWidth = Int(Tile.width) * Board.gridWidth
        let widthRatio: CGFloat = CGFloat(availableScreenWidth) / CGFloat(baseWidth)
        
        let tileWidthI = Int(Tile.width * widthRatio + 0.5)
        tileWidth = CGFloat(tileWidthI)
        tileHeight = CGFloat(tileWidthI)
        
        let boardWidthI = Int(tileWidth * CGFloat(Board.gridWidth) + 0.5)
        boardWidth = CGFloat(boardWidthI)
        boardHeight = CGFloat(boardWidthI)
        
        let boardXI = Int(width * 0.5 - boardWidth * 0.5 + 0.5)
        boardX = CGFloat(boardXI)
        
        let boardYI = Int(height * 0.5 + boardHeight * 0.5 + 0.5)
        boardY = CGFloat(boardYI)
    }

    func update(deltaTime: CGFloat) {
        
        if isSwapping {
            
            guard let swapTile1 = swapTile1 else {
                soundNodeMatchFailed.run(SKAction.play())
                cancelSwap()
                return
            }
            guard let swapTile2 = swapTile2 else {
                soundNodeMatchFailed.run(SKAction.play())
                cancelSwap()
                return
            }
            
            let tile1X = board.tileX(gridX: swapTile1.gridX)
            let tile1Y = board.tileY(gridY: swapTile1.gridY)
            
            let tile2X = board.tileX(gridX: swapTile2.gridX)
            let tile2Y = board.tileY(gridY: swapTile2.gridY)
        
            swapTileAnimationPercent += deltaTime * 1.5
            if swapTileAnimationPercent >= 1 {
                
                swap(&swapTile1.gridX, &swapTile2.gridX)
                swap(&swapTile1.gridY, &swapTile2.gridY)
                
                swapTile1.spriteNode.position.x = tile2X
                swapTile1.spriteNode.position.y = tile2Y
                
                swapTile2.spriteNode.position.x = tile1X
                swapTile2.spriteNode.position.y = tile1Y
                
                board.grid[swapTile1.gridX][swapTile1.gridY] = swapTile1
                board.grid[swapTile2.gridX][swapTile2.gridY] = swapTile2
                
                if isUserInitiatedSwap {
                    if board.isMatch(gridX: swapTile1.gridX,
                                     gridY: swapTile1.gridY) ||
                        board.isMatch(gridX: swapTile2.gridX,
                                      gridY: swapTile2.gridY) {
                        isSwapping = false
                        self.swapTile1 = nil
                        self.swapTile2 = nil
                        
                        board.processAllMatches()
                        
                    } else {
                        soundNodeMatchFailed.run(SKAction.play())
                        isUserInitiatedSwap = false
                        board.moveTileToTop(gridX: swapTile2.gridX, gridY: swapTile2.gridY)
                        swapTiles(tileA: swapTile1, tileB: swapTile2)
                    }
                } else {
                    isSwapping = false
                    self.swapTile1 = nil
                    self.swapTile2 = nil
                }
                
            } else {
                
                let x1 = tile1X + (tile2X - tile1X) * (swapTileAnimationPercent)
                let y1 = tile1Y + (tile2Y - tile1Y) * (swapTileAnimationPercent)
                let x2 = tile2X + (tile1X - tile2X) * (swapTileAnimationPercent)
                let y2 = tile2Y + (tile1Y - tile2Y) * (swapTileAnimationPercent)
                
                swapTile1.spriteNode.position.x = x1
                swapTile1.spriteNode.position.y = y1
                swapTile2.spriteNode.position.x = x2
                swapTile2.spriteNode.position.y = y2
            }
        }
        
        board.update(deltaTime: deltaTime)
    }
    
    private func canSelectTile() -> Bool {
        
        if selectedTile != nil { return false }
        if isSwapping { return false }
        if board.isToppling { return false }
        if board.isMatching { return false }
        
        return true
    }
    
    func touchBegan(touch: UITouch, x: CGFloat, y: CGFloat) {
        guard let gridX = board.getGridX(mouseX: x) else { return }
        guard let gridY = board.getGridY(mouseY: y) else { return }
        guard canSelectTile() else { return }
        guard let tile = board.getTile(gridX: gridX, gridY: gridY) else { return }
        
        selectedTile = tile
        selectedTileTouch = touch
        
        board.moveTileToTop(gridX: gridX, gridY: gridY)
    }
    
    func touchMoved(touch: UITouch, x: CGFloat, y: CGFloat) {
        guard let selectedTile = selectedTile else { return }
        guard touch == selectedTileTouch else { return }
        guard let gridX = board.getGridX(mouseX: x) else { return }
        guard let gridY = board.getGridY(mouseY: y) else { return }
        
        if gridX == (selectedTile.gridX - 1) && gridY == selectedTile.gridY {
            if let tile = board.getTile(gridX: gridX, gridY: gridY) {
                isUserInitiatedSwap = true
                swapTiles(tileA: selectedTile, tileB: tile)
                self.selectedTile = nil
                self.selectedTileTouch = nil
            }
        }
        if gridX == (selectedTile.gridX + 1) && gridY == selectedTile.gridY {
            if let tile = board.getTile(gridX: gridX, gridY: gridY) {
                isUserInitiatedSwap = true
                swapTiles(tileA: selectedTile, tileB: tile)
                self.selectedTile = nil
                self.selectedTileTouch = nil
            }
        }
        if gridX == selectedTile.gridX && gridY == (selectedTile.gridY + 1) {
            if let tile = board.getTile(gridX: gridX, gridY: gridY) {
                isUserInitiatedSwap = true
                swapTiles(tileA: selectedTile, tileB: tile)
                self.selectedTile = nil
                self.selectedTileTouch = nil
            }
        }
        if gridX == selectedTile.gridX && gridY == (selectedTile.gridY - 1) {
            if let tile = board.getTile(gridX: gridX, gridY: gridY) {
                isUserInitiatedSwap = true
                swapTiles(tileA: selectedTile, tileB: tile)
                self.selectedTile = nil
                self.selectedTileTouch = nil
            }
        }
    }
    
    func touchEnded(touch: UITouch, x: CGFloat, y: CGFloat) {
        self.selectedTile = nil
        self.selectedTileTouch = nil
    }
    
    func cancelSwap() {
        if let swapTile1 = swapTile1 {
            let x = board.tileX(gridX: swapTile1.gridX)
            let y = board.tileY(gridY: swapTile1.gridY)
            swapTile1.spriteNode.position = CGPoint(x: x, y: y)
            self.swapTile1 = nil
        }
        if let swapTile2 = swapTile2 {
            let x = board.tileX(gridX: swapTile2.gridX)
            let y = board.tileY(gridY: swapTile2.gridY)
            swapTile2.spriteNode.position = CGPoint(x: x, y: y)
            self.swapTile2 = nil
        }
        isSwapping = false
        swapTileAnimationPercent = 0.0
    }
    
    func swapTiles(tileA: Tile, tileB: Tile) {
        isSwapping = true
        swapTileAnimationPercent = 0.0
        swapTile1 = tileA
        swapTile2 = tileB
    }
    
}
