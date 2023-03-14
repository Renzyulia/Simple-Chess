//
//  ChessBoardView.swift
//  SimpleChess
//
//  Created by d.kelt on 25.11.2022.
//

import UIKit

final class ChessBoardView: UIView {
    
    private var tiles: [TileView] = []
    weak var delegate: ChessBoardViewDelegate?
    
    init() {
        super.init(frame: .zero)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removePiece(at coordinate: Coordinate) {
        let index = Index(from: coordinate)
        tiles[index.rawIndex].image = nil
    }
    
    func movePiece(visualPiece: VisualPiece, to coordinate: Coordinate) {
        let index = Index(from: coordinate)
        tiles[index.rawIndex].image = visualPiece.image
    }
    
    func setPiece(at coordinate: Coordinate, with image: UIImage) {
        let index = Index(from: coordinate)
        tiles[index.rawIndex].image = image
    }
    
    func glowChange(by coordinate: Coordinate, turnOn: Bool) {
        let index = Index(from: coordinate)
        tiles[index.rawIndex].makeSelected(turnOn)
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
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        for index in 0..<tiles.count {
            if sender?.view == tiles[index] {
                let index = Index(fromRaw: index)
                let coordinate = index?.coordinate
                delegate?.userDidTap(on: coordinate!)
                break
            }
        }
    }
    
   private final class TileView: UIImageView {
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
    
    private struct Index {
        let rawIndex: Int
        let coordinate: Coordinate
        
        init?(fromRaw: Int) {
            guard fromRaw <= 63 else { return nil }
            self.rawIndex = fromRaw
            
            let column = fromRaw % 8
            let row = (fromRaw - column) / 8
            coordinate = Coordinate(row: row, column: column)!
        }
        
        init(from coordinate: Coordinate) {
            self.coordinate = coordinate
            rawIndex = coordinate.row * 8 + coordinate.column
        }
    }
}

protocol ChessBoardViewDelegate: AnyObject {
    func userDidTap(on: Coordinate)
}


