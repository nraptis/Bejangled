//
//  GameView.swift
//  Bejangled
//
//  Created by Tiger Nixon on 4/17/23.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    var body: some View {
        GeometryReader { geometry in
            content(size: geometry.size)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func content(size: CGSize) -> some View {
        let size = CGSize(width: size.width * scale,
                          height: size.height * scale)
        return SpriteView(scene: GameScene(size: size))
    }
    
    var scale: CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return 1.0
        } else {
            return 2.0
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
