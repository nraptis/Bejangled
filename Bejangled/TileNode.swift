//
//  TileNode.swift
//  Bejangled
//
//  Created by Tiger Nixon on 4/17/23.
//

import Foundation
import SpriteKit

class TileNode: SKSpriteNode {
    
    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        print("ini")
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
