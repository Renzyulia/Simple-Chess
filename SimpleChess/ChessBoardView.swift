//
//  ChessBoardView.swift
//  SimpleChess
//
//  Created by d.kelt on 25.11.2022.
//

import UIKit

final class ChessBoardView: UIView {
    
    var tiles: [TileView] = []
    weak var delegate: ChessBoardViewDelegate?
    
    init() {
        super.init(frame: .zero)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removePiece(at: Coordinate) {
        let index = at.row * 8 + at.column
        tiles[index].image = nil
    }
    
    func movePiece(visualPiece: VisualPiece, to: Coordinate) {
        let index = to.row * 8 + to.column
        tiles[index].image = visualPiece.image
    
    }
    
    func setPiece(at coordinate: Coordinate, with image: UIImage) {
        let index = coordinate.row * 8 + coordinate.column
        tiles[index].image = image
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
                var tile: TileView
                
                if ((i + j) % 2 == 0) {
                    tile = TileView(color: .white)
                } else {
                    tile = TileView(color: .black)
                }
                tile.backgroundColor = tile.backColor
                tile.autoresizingMask = []
                tile.contentMode = .scaleAspectFit
                tile.isUserInteractionEnabled = true
                tiles.append(tile)
                addSubview(tile)
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                tile.addGestureRecognizer(tap)
            }
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        for index in 0..<tiles.count {
            if sender?.view == tiles[index] {
                let column = index % 8
                let row = (index - column) / 8
                delegate?.userDidTap(row: row, column: column)
            }
        }
    }
}

class TileView: UIImageView {
    var backColor: UIColor
    let backlightColor = UIColor(named: "Color")
    
    init(color: Color) {
        switch color {
        case .black: backColor = .darkGray
        case .white: backColor = .gray
        }
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeSelected(_ turnOn: Bool) {
        if turnOn {
            self.backgroundColor = backlightColor
        } else {
            self.backgroundColor = backColor
        }
    }
}

protocol ChessBoardViewDelegate: AnyObject {
    func userDidTap(row: Int, column: Int)
}


