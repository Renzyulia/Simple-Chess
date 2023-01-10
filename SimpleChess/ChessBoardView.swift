//
//  ChessBoardView.swift
//  SimpleChess
//
//  Created by d.kelt on 25.11.2022.
//

import UIKit

final class ChessBoardView: UIView {
    
    var tiles: [UIImageView] = []
    
    init() {
        super.init(frame: .zero)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func movePiece() {
        
    }
    
    func setPiece() {
        
    }
    
    func resetBoard() {
        placeBlackPieces()
        clearCenterTiles()
        placeWhitePieces()
    }
    
    private func placeBlackPieces() {
        tiles[0].image = UIImage(named: "Pieces/Black/Rook")!
        tiles[1].image = UIImage(named: "Pieces/Black/Knight")!
        tiles[2].image = UIImage(named: "Pieces/Black/Bishop")!
        tiles[3].image = UIImage(named: "Pieces/Black/Queen")!
        tiles[4].image = UIImage(named: "Pieces/Black/King")!
        tiles[5].image = UIImage(named: "Pieces/Black/Bishop")!
        tiles[6].image = UIImage(named: "Pieces/Black/Knight")!
        tiles[7].image = UIImage(named: "Pieces/Black/Rook")!
        tiles[8].image = UIImage(named: "Pieces/Black/Pawn")!
        tiles[9].image = UIImage(named: "Pieces/Black/Pawn")!
        tiles[10].image = UIImage(named: "Pieces/Black/Pawn")!
        tiles[11].image = UIImage(named: "Pieces/Black/Pawn")!
        tiles[12].image = UIImage(named: "Pieces/Black/Pawn")!
        tiles[13].image = UIImage(named: "Pieces/Black/Pawn")!
        tiles[14].image = UIImage(named: "Pieces/Black/Pawn")!
        tiles[15].image = UIImage(named: "Pieces/Black/Pawn")!
    }
    
    private func clearCenterTiles() {
        for tile in tiles[16...47] {
            tile.image = nil
        }
    }
    
    private func placeWhitePieces() {
        tiles[48].image = UIImage(named: "Pieces/White/Pawn")!
        tiles[49].image = UIImage(named: "Pieces/White/Pawn")!
        tiles[50].image = UIImage(named: "Pieces/White/Pawn")!
        tiles[51].image = UIImage(named: "Pieces/White/Pawn")!
        tiles[52].image = UIImage(named: "Pieces/White/Pawn")!
        tiles[53].image = UIImage(named: "Pieces/White/Pawn")!
        tiles[54].image = UIImage(named: "Pieces/White/Pawn")!
        tiles[55].image = UIImage(named: "Pieces/White/Pawn")!
        tiles[56].image = UIImage(named: "Pieces/White/Rook")!
        tiles[57].image = UIImage(named: "Pieces/White/Knight")!
        tiles[58].image = UIImage(named: "Pieces/White/Bishop")!
        tiles[59].image = UIImage(named: "Pieces/White/Queen")!
        tiles[60].image = UIImage(named: "Pieces/White/King")!
        tiles[61].image = UIImage(named: "Pieces/White/Bishop")!
        tiles[62].image = UIImage(named: "Pieces/White/Knight")!
        tiles[63].image = UIImage(named: "Pieces/White/Rook")!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tileSize = bounds.width / 8
        
        for (offset, subview) in tiles.enumerated() {
            let row = CGFloat(offset / 8)
            let column = CGFloat(offset % 8)
            
            subview.frame = CGRect(x: column * tileSize, y: row * tileSize, width: tileSize, height: tileSize)
        }
    }
    
    private func configureSubviews() {
        for i in 0...7 {
            for j in 0...7 {
                let tile = UIImageView()
                tile.autoresizingMask = []
                tile.contentMode = .scaleAspectFit
                tile.backgroundColor = ((i + j) % 2 == 0) ? .gray : .darkGray
                tiles.append(tile)
                addSubview(tile)
            }
        }
    }
}
