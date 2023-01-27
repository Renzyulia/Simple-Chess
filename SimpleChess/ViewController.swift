//
//  ViewController.swift
//  SimpleChess
//
//  Created by d.kelt on 25.11.2022.
//

import UIKit

class ViewController: UIViewController {
    
    var gameController: GameController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameController = GameController()
        let chessView = gameController!.chessBoardView
        chessView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(chessView)
        
        NSLayoutConstraint.activate([
            chessView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16),
            chessView.heightAnchor.constraint(equalTo: view.widthAnchor),
            chessView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chessView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

class GameController: ChessBoardViewDelegate {
    var chessBoardView = ChessBoardView()
    var board = ChessBoardMutable()
    var numberOfTap = 0
    var selectedPiece: Piece? = nil
    var positionOfSelectedPiece: Coordinate? = nil
    var possibleMoves = [Coordinate]()
    
    init() {
        chessBoardView.delegate = self
        
        create(piece: Rook(color: .white), at: .init(row: 0, column: 0)!, with: .init(rookWithColor: .white))
        create(piece: Knight(color: .white), at: .init(row: 0, column: 1)!, with: .init(knightWithColor: .white))
        create(piece: Bishop(color: .white), at: .init(row: 0, column: 2)!, with: .init(bishopWithColor: .white))
        create(piece: Queen(color: .white), at: .init(row: 0, column: 3)!, with: .init(queenWithColor: .white))
        create(piece: King(color: .white), at: .init(row: 0, column: 4)!, with: .init(kingWithColor: .white))
        create(piece: Bishop(color: .white), at: .init(row: 0, column: 5)!, with: .init(bishopWithColor: .white))
        create(piece: Knight(color: .white), at: .init(row: 0, column: 6)!, with: .init(knightWithColor: .white))
        create(piece: Rook(color: .white), at: .init(row: 0, column: 7)!, with: .init(rookWithColor: .white))
        create(piece: Pawn(color: .white), at: .init(row: 1, column: 0)!, with: .init(pawnWithColor: .white))
        create(piece: Pawn(color: .white), at: .init(row: 1, column: 1)!, with: .init(pawnWithColor: .white))
        create(piece: Pawn(color: .white), at: .init(row: 1, column: 2)!, with: .init(pawnWithColor: .white))
        create(piece: Pawn(color: .white), at: .init(row: 1, column: 3)!, with: .init(pawnWithColor: .white))
        create(piece: Pawn(color: .white), at: .init(row: 1, column: 4)!, with: .init(pawnWithColor: .white))
        create(piece: Pawn(color: .white), at: .init(row: 1, column: 5)!, with: .init(pawnWithColor: .white))
        create(piece: Pawn(color: .white), at: .init(row: 1, column: 6)!, with: .init(pawnWithColor: .white))
        create(piece: Pawn(color: .white), at: .init(row: 1, column: 7)!, with: .init(pawnWithColor: .white))
        create(piece: Pawn(color: .black), at: .init(row: 6, column: 0)!, with: .init(pawnWithColor: .black))
        create(piece: Pawn(color: .black), at: .init(row: 6, column: 1)!, with: .init(pawnWithColor: .black))
        create(piece: Pawn(color: .black), at: .init(row: 6, column: 2)!, with: .init(pawnWithColor: .black))
        create(piece: Pawn(color: .black), at: .init(row: 6, column: 3)!, with: .init(pawnWithColor: .black))
        create(piece: Pawn(color: .black), at: .init(row: 6, column: 4)!, with: .init(pawnWithColor: .black))
        create(piece: Pawn(color: .black), at: .init(row: 6, column: 5)!, with: .init(pawnWithColor: .black))
        create(piece: Pawn(color: .black), at: .init(row: 6, column: 6)!, with: .init(pawnWithColor: .black))
        create(piece: Pawn(color: .black), at: .init(row: 6, column: 7)!, with: .init(pawnWithColor: .black))
        create(piece: Rook(color: .black), at: .init(row: 7, column: 0)!, with: .init(rookWithColor: .black))
        create(piece: Knight(color: .black), at: .init(row: 7, column: 1)!, with: .init(knightWithColor: .black))
        create(piece: Bishop(color: .black), at: .init(row: 7, column: 2)!, with: .init(bishopWithColor: .black))
        create(piece: Queen(color: .black), at: .init(row: 7, column: 3)!, with: .init(queenWithColor: .black))
        create(piece: King(color: .black), at: .init(row: 7, column: 4)!, with: .init(kingWithColor: .black))
        create(piece: Bishop(color: .black), at: .init(row: 7, column: 5)!, with: .init(bishopWithColor: .black))
        create(piece: Knight(color: .black), at: .init(row: 7, column: 6)!, with: .init(knightWithColor: .black))
        create(piece: Rook(color: .black), at: .init(row: 7, column: 7)!, with: .init(rookWithColor: .black))
    }
    
    func create(piece: Piece, at: Coordinate, with: VisualPiece) {
        board.storage.add(piece, at: at)
        board.visualPieces.append(Pair(piece: piece, visualPiece: with))
        chessBoardView.setPiece(at: at, with: with.image)
    }
    
    func userDidTap(row: Int, column: Int) {
        switch numberOfTap {
        case 0:
            if let piece = board.storage.piece(at: .init(row: row, column: column)!) {
                selectedPiece = piece
                positionOfSelectedPiece = Coordinate(row: row, column: column)
                numberOfTap = 1
                
                let context = ContextForPiece(piece: selectedPiece!, coordinate: .init(row: row, column: column)!, board: board)
                for move in piece.possibleMoves(in: context) {
                    let moveCoordinate = Coordinate(row: row + move.row, column: column + move.column)
                    let shadowBoard = board.board(afterMovingPieceFrom: .init(row: row, column: column)!, to: moveCoordinate!)
                    if shadowBoard.hasCheck(for: piece.color) == false {
                        possibleMoves.append(moveCoordinate!)
                    }
                }
                
                for move in possibleMoves {
                    let index = move.row * 8 + move.column
                    chessBoardView.tiles[index].makeSelected(true)
                }
            }
        case 1:
            for move in possibleMoves {
                let index = move.row * 8 + move.column
                chessBoardView.tiles[index].makeSelected(false)
            }
            
            for move in possibleMoves {
                if move.row == row && move.column == column {  // здесь мы проверяем, что в нашем массиве, который мы сделали на первом тапе (исключили шаги, которые ведут к шаху), есть клетка, на которую мы нажали
                    let tile = board.tile(at: move, for: selectedPiece!.color) // если есть, то мы выявляем какой у нее тип
                    
                    var visualPiece: VisualPiece! = nil // здесь мы сразу находим нашу картинку для выбранной фигуры
                    for pair in board.visualPieces {
                        if pair.piece === selectedPiece! {
                            visualPiece = pair.visualPiece
                        }
                    }
                    
                    if tile == Tile.withEnemy { // если клетка занята врагом, то
                        chessBoardView.removePiece(at: move) // мы удаляем на доске эту вражескую фигуру
                        chessBoardView.removePiece(at: positionOfSelectedPiece!) //удаляем нашу фигуру с прошлого места
                        chessBoardView.movePiece(visualPiece: visualPiece, to: move) //вставляем ее на новое место
                        
                        let enemyPiece = board.storage.piece(at: .init(row: row, column: column)!)
                        board.storage.remove(enemyPiece!) // удаляем фигуру из board
                        board.storage.move(selectedPiece!, to: .init(row: row, column: column)!) // передвигаем фигуру внутри board
                        selectedPiece?.didMove()
                    } else if tile == Tile.isEmpty { 
                        chessBoardView.removePiece(at: positionOfSelectedPiece!)
                        chessBoardView.movePiece(visualPiece: visualPiece, to: move)
                        board.storage.move(selectedPiece!, to: .init(row: row, column: column)!)
                        selectedPiece?.didMove()
                    }
                }
            }
            numberOfTap = 0
            possibleMoves.removeAll() //очищаем наш массив возможных ходов
            selectedPiece = nil //обнуляем выбранную фигуру
            positionOfSelectedPiece = nil //обнуляем координату выбранной фигуры
        default: break
        }
    }
}

enum Color {
    case white
    case black
}

struct Coordinate {
    var row: Int
    var column: Int
    
    init?(row: Int, column: Int) {
        if row < 8 && row >= 0 {
            self.row = row
        } else {
            return nil
        }
        if column < 8 && column >= 0 {
            self.column = column
        } else {
            return nil
        }
    }
}

struct BoardElement {
    let piece: Piece
    var coordinate: Coordinate
}

struct RelativePosition {
    var row: Int
    var column: Int
}

protocol GameContext {
    func tile(at: RelativePosition) -> Tile
    func board(afterMovingTo: RelativePosition) -> GameContext
    func position(moveForwardUpTo: Int, moveHorizontalTo: Int) -> RelativePosition
}

class ContextForPiece: GameContext {
    let piece: Piece
    let coordinate: Coordinate
    let board: Board
    
    init(piece: Piece, coordinate: Coordinate, board: Board) {
        self.piece = piece
        self.coordinate = coordinate
        self.board = board
    }
    
    func tile(at: RelativePosition) -> Tile {
        if let absoluteCoordinate: Coordinate = .init(row: coordinate.row + at.row, column: coordinate.column + at.column) {
            return board.tile(at: absoluteCoordinate, for: piece.color)
        } else {
            return Tile(isValid: false, isEmpty: false, isTakenByEnemy: false)
        }
    }
    
    func board(afterMovingTo: RelativePosition) -> GameContext {
        let absoluteCoordinate: Coordinate = .init(row: coordinate.row + afterMovingTo.row, column: coordinate.column + afterMovingTo.column)!
        let shadowBoard = board.board(afterMovingPieceFrom: coordinate, to: absoluteCoordinate)
        return ContextForPiece(piece: piece, coordinate: absoluteCoordinate, board: shadowBoard)
    }
    
    func position(moveForwardUpTo: Int, moveHorizontalTo: Int) -> RelativePosition {
        if piece.color == .white {
            return .init(row: moveForwardUpTo, column: moveHorizontalTo)
        } else {
            return .init(row: -(moveForwardUpTo), column: moveHorizontalTo)
        }
    }
}

protocol Piece: AnyObject {
    var color: Color { get }
    var isKing: Bool { get }

    func possibleMoves(in: GameContext) -> [RelativePosition]
    func didMove()
}

struct Tile: Equatable {
    var isValid: Bool
    var isEmpty: Bool
    var isTakenByEnemy: Bool
    
    static var invalid: Tile {
        return Tile(isValid: false, isEmpty: false, isTakenByEnemy: false)
    }
        
    static var isEmpty: Tile {
        return Tile(isValid: true, isEmpty: true, isTakenByEnemy: false)
    }
        
    static var withEnemy: Tile {
        return Tile(isValid: true, isEmpty: false, isTakenByEnemy: true)
    }
}

protocol Board: AnyObject {
    var pieces: [Piece] { get }
    
    func kingPosition(for: Color) -> Coordinate
    func tile(at: Coordinate, for: Color) -> Tile
    func hasCheck(for: Color) -> Bool
    func board(afterMovingPieceFrom: Coordinate, to: Coordinate) -> Board
}

struct VisualPiece {
    let image: UIImage

    init(kingWithColor: Color) {
        switch kingWithColor {
        case .white: image = UIImage(named: "Pieces/White/King")!
        case .black: image = UIImage(named: "Pieces/Black/King")!
        }
    }
    
    init(queenWithColor: Color) {
        switch queenWithColor {
        case .white: image = UIImage(named: "Pieces/White/Queen")!
        case .black: image = UIImage(named: "Pieces/Black/Queen")!
        }
    }
    
    init(rookWithColor: Color) {
        switch rookWithColor {
        case .white: image = UIImage(named: "Pieces/White/Rook")!
        case .black: image = UIImage(named: "Pieces/Black/Rook")!
        }
    }
    
    init(knightWithColor: Color) {
        switch knightWithColor {
        case .white: image = UIImage(named: "Pieces/White/Knight")!
        case .black: image = UIImage(named: "Pieces/Black/Knight")!
        }
    }
    
    init(bishopWithColor: Color) {
        switch bishopWithColor {
        case .white: image = UIImage(named: "Pieces/White/Bishop")!
        case .black: image = UIImage(named: "Pieces/Black/Bishop")!
        }
    }
    
    init(pawnWithColor: Color) {
        switch pawnWithColor {
        case .white: image = UIImage(named: "Pieces/White/Pawn")!
        case .black: image = UIImage(named: "Pieces/Black/Pawn")!
        }
    }
}

struct Pair {
  var piece: Piece
  var visualPiece: VisualPiece
}

class ChessBoardMutable: Board {
    var storage: MutableStorage
    var pieces: [Piece] {
        return storage.pieces
    }
    var visualPieces: [Pair] = []
    
    init() {
        storage = StorageForPieces()
    }
    
    func kingPosition(for color: Color) -> Coordinate {
        var coordinate: Coordinate? = nil
        for piece in pieces {
            if piece.isKing && piece.color == color {
                coordinate = storage.coordinate(of: piece)!
            }
        }
        return coordinate!
    }
    
    func tile(at: Coordinate, for color: Color) -> Tile {
        var isEmpty = false
        var isTakenByEnemy = false
        
        let piece: Piece? = storage.piece(at: at)
        if piece == nil {
            isEmpty = true
        } else if piece?.color != color {
            isTakenByEnemy = true
        }
        return Tile(isValid: true, isEmpty: isEmpty, isTakenByEnemy: isTakenByEnemy)
    }
    
    func hasCheck(for color: Color) -> Bool {
        let kingPosition = kingPosition(for: color)
        
        for piece in pieces {
            if piece.color != color {
                let coordinate = self.storage.coordinate(of: piece)
                let context = ContextForPiece(piece: piece, coordinate: coordinate!, board: self)
                for move in piece.possibleMoves(in: context) {
                    if move.row == kingPosition.row && move.column == kingPosition.column {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func board(afterMovingPieceFrom: Coordinate, to: Coordinate) -> Board {
        let movedPiece = storage.piece(at: afterMovingPieceFrom)
        let shadowStorage = storage.shadow(byMoving: movedPiece!, to: to)
        let board = ChessBoardReadOnly(storage: shadowStorage)
        return board
    }
}

class ChessBoardReadOnly: Board {
    let storage: Storage
    var pieces: [Piece] {
        return storage.pieces
    }
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    func kingPosition(for color: Color) -> Coordinate {
        var coordinate: Coordinate? = nil
        for piece in pieces {
            if piece.isKing && piece.color == color {
                coordinate = storage.coordinate(of: piece)!
            }
        }
        return coordinate!
    }
    
    func tile(at: Coordinate, for color: Color) -> Tile {
        var isEmpty = false
        var isTakenByEnemy = false
        
        let piece: Piece? = storage.piece(at: at)
        if piece == nil {
            isEmpty = true
        } else if piece?.color != color {
            isTakenByEnemy = true
        }
        return Tile(isValid: true, isEmpty: isEmpty, isTakenByEnemy: isTakenByEnemy)
    }
    
    func hasCheck(for color: Color) -> Bool {
        let kingPosition = kingPosition(for: color) //черный
        
        for piece in pieces {
            if piece.color != color {
                let coordinate = self.storage.coordinate(of: piece)
                let context = ContextForPiece(piece: piece, coordinate: coordinate!, board: self)
                for move in piece.possibleMoves(in: context) {
                    if move.row == kingPosition.row && move.column == kingPosition.column {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func board(afterMovingPieceFrom: Coordinate, to: Coordinate) -> Board {
        let movedPiece = storage.piece(at: afterMovingPieceFrom)
        let shadowStorage = storage.shadow(byMoving: movedPiece!, to: to)
        let board = ChessBoardReadOnly(storage: shadowStorage)
        return board
    }
}

protocol Storage: AnyObject {
    var pieces: [Piece] { get }
    
    func piece(at: Coordinate) -> Piece?
    func coordinate(of: Piece) -> Coordinate?
    
    func shadow(byRemoving: Piece) -> Storage
    func shadow(byAdding: Piece, at: Coordinate) -> Storage
    func shadow(byMoving: Piece, to: Coordinate) -> Storage
}

extension Storage {
    func shadow(byRemoving: Piece) -> Storage {
        let shadowStorage = ShadowStorageRemovingPiece(originalStorage: self, removedPiece: byRemoving)
        return shadowStorage
    }
    
    func shadow(byAdding: Piece, at: Coordinate) -> Storage {
        let shadowStorage = ShadowStorageAdditingPiece(originalStorage: self, addedPiece: byAdding, coordinate: at)
        return shadowStorage
    }
    
    func shadow(byMoving: Piece, to: Coordinate) -> Storage {
        let enemyPieces: Piece? = piece(at: to)
        if enemyPieces != nil {
            let shadowStorage = ShadowStorageRemovingPiece(originalStorage: self, removedPiece: enemyPieces!)
            return shadowStorage.shadow(byMoving: byMoving, to: to)
        } else {
            let shadowStorage = ShadowStorageMovingPiece(originalStorage: self, movedPiece: byMoving, coordinate: to)
            return shadowStorage
        }
    }
}

protocol MutableStorage: Storage {
    func remove(_: Piece)
    func add(_: Piece, at: Coordinate)
    func move(_: Piece, to: Coordinate)
}

class StorageForPieces: Storage, MutableStorage {
    var pieces: [Piece] {
        var pieces = [Piece]()
        for element in boardElement {
            pieces.append(element.piece)
        }
        return pieces
    }
    
    var boardElement: [BoardElement] = []
    
    func piece(at: Coordinate) -> Piece? {
        var piece: Piece? = nil
        for element in boardElement {
            if element.coordinate.row == at.row && element.coordinate.column == at.column {
                piece = element.piece
            }
        }
        return piece
    }
    
    func coordinate(of: Piece) -> Coordinate? {
        var coordinate: Coordinate? = nil
        for element in boardElement {
            if element.piece === of {
                coordinate = element.coordinate
            }
        }
        return coordinate
    }
    
    func remove(_ piece: Piece) {
        let index = searchIndex(in: boardElement, piece: piece)
        boardElement.remove(at: index)
    }
    
    func add(_ piece: Piece, at: Coordinate) {
        boardElement.append(BoardElement(piece: piece, coordinate: at))
    }
    
    func move(_ piece: Piece, to: Coordinate) {
        let index = searchIndex(in: boardElement, piece: piece)
        boardElement[index].coordinate.row = to.row
        boardElement[index].coordinate.column = to.column
    }
    
    func searchIndex(in array: [BoardElement], piece: Piece) -> Int {
        var index = 0
        for i in 0..<array.count {
            if array[i].piece === piece {
                index = i
            }
        }
        return index
    }
}

class ShadowStorageRemovingPiece: Storage {
    var pieces: [Piece] {
        var pieces = originalStorage.pieces
        for index in 0..<pieces.count {
            if pieces[index] === removedPiece {
                pieces.remove(at: index)
                break
            }
        }
        return pieces
    }
    let originalStorage: Storage
    let removedPiece: Piece
    
    init (originalStorage: Storage, removedPiece: Piece) {
        self.originalStorage = originalStorage
        self.removedPiece = removedPiece
    }
    
    func piece(at: Coordinate) -> Piece? {
        let piece = originalStorage.piece(at: at)
        if piece === removedPiece {
            return nil
        } else {
            return piece
        }
    }
    
    func coordinate(of: Piece) -> Coordinate? {
        if of === removedPiece {
            return nil
        } else {
            return originalStorage.coordinate(of: of)
        }
    }
}

class ShadowStorageMovingPiece: Storage {
    var pieces: [Piece] {
        return originalStorage.pieces
    }
    var originalStorage: Storage
    var movedPiece: Piece
    var coordinate: Coordinate
    
    init (originalStorage: Storage, movedPiece: Piece, coordinate: Coordinate) {
        self.originalStorage = originalStorage
        self.movedPiece = movedPiece
        self.coordinate = coordinate
    }
    
    func piece(at: Coordinate) -> Piece? {
        let piece = originalStorage.piece(at: at)
        if piece === movedPiece {
            return nil
        } else if at.row == coordinate.row && at.column == coordinate.column {
            return movedPiece
        } else {
            return piece
        }
    }
    
    func coordinate(of: Piece) -> Coordinate? {
        if of === movedPiece {
            return coordinate
        } else {
            return originalStorage.coordinate(of: of)
        }
    }
}

class ShadowStorageAdditingPiece: Storage {
    var pieces: [Piece] {
        var pieces = originalStorage.pieces
        pieces.append(addedPiece)
        return pieces
    }
    var originalStorage: Storage
    var addedPiece: Piece
    var coordinate: Coordinate
    
    init (originalStorage: Storage, addedPiece: Piece, coordinate: Coordinate) {
        self.originalStorage = originalStorage
        self.addedPiece = addedPiece
        self.coordinate = coordinate
    }
    
    func piece(at: Coordinate) -> Piece? {
        let piece = originalStorage.piece(at: at)
        if at.row == coordinate.row && at.column == coordinate.column {
            return addedPiece
        } else {
            return piece
        }
    }
    
    func coordinate(of: Piece) -> Coordinate? {
        if of === addedPiece {
            return coordinate
        } else {
            return originalStorage.coordinate(of: of)
        }
    }
}

class Rook: Piece {
    var color: Color
    var isKing = false
    
    init(color: Color) {
        self.color = color
    }
    
    func possibleMoves(in context: GameContext) -> [RelativePosition] {
        let possibleMovesDown = move(rowOffset: -1, columnOffset: 0, context: context)
        let possibleMovesLeft = move(rowOffset: 0, columnOffset: -1, context: context)
        let possibleMovesUp = move(rowOffset: 1, columnOffset: 0, context: context)
        let possibleMovesRight = move(rowOffset: 0, columnOffset: 1, context: context)
        let possibleMoves = possibleMovesDown + possibleMovesLeft + possibleMovesRight + possibleMovesUp
        
        return possibleMoves
    }
    
    func move(rowOffset: Int, columnOffset: Int, context: GameContext) -> [RelativePosition] {
        var possibleMoves: [RelativePosition] = []
        var row = 0 + rowOffset
        var column = 0 + columnOffset
        
        while true {
            let tile = context.tile(at: .init(row: row, column: column))
            if tile == Tile.invalid {
                break
            } else if tile != Tile.isEmpty {
                if tile == Tile.withEnemy {
                    possibleMoves.append(.init(row: row, column: column))
                    break
                } else {
                    break
                }
            } else {
                possibleMoves.append(.init(row: row, column: column))
            }
            row += rowOffset
            column += columnOffset
        }
        return possibleMoves
    }
    
    func didMove() {
    }
}

class Queen: Piece {
    var color: Color
    var isKing = false
    
    init(color: Color) {
        self.color = color
    }
    
    func possibleMoves(in context: GameContext) -> [RelativePosition] {
        let possibleMovesDown = move(rowOffset: -1, columnOffset: 0, context: context)
        let possibleMovesLeft = move(rowOffset: 0, columnOffset: -1, context: context)
        let possibleMovesUp = move(rowOffset: 1, columnOffset: 0, context: context)
        let possibleMovesRight = move(rowOffset: 0, columnOffset: 1, context: context)
        let possibleMovesDiagonallyUpAndLeft = move(rowOffset: 1, columnOffset: -1, context: context)
        let possibleMovesDiagonallyDownAndLeft = move(rowOffset: -1, columnOffset: -1, context: context)
        let possibleMovesDiagonallyUpAndRight = move(rowOffset: 1, columnOffset: 1, context: context)
        let possibleMovesDiagonallyDownAndRight = move(rowOffset: -1, columnOffset: 1, context: context)
        
        let possibleMoves = possibleMovesDown + possibleMovesLeft + possibleMovesUp + possibleMovesRight + possibleMovesDiagonallyUpAndLeft + possibleMovesDiagonallyDownAndLeft + possibleMovesDiagonallyUpAndRight + possibleMovesDiagonallyDownAndRight
        
        return possibleMoves
    }
    
    func move(rowOffset: Int, columnOffset: Int, context: GameContext) -> [RelativePosition] {
        var possibleMoves: [RelativePosition] = []
        var row = 0 + rowOffset
        var column = 0 + columnOffset
        
        while true {
            let tile = context.tile(at: .init(row: row, column: column))
            if tile == Tile.invalid {
                break
            } else if tile != Tile.isEmpty {
                if tile == Tile.withEnemy {
                    possibleMoves.append(.init(row: row, column: column))
                    break
                } else {
                    break
                }
            } else {
                possibleMoves.append(.init(row: row, column: column))
            }
            row += rowOffset
            column += columnOffset
        }
        return possibleMoves
    }
    
    func didMove() {
    }
}

class Knight: Piece {
    var color: Color
    var isKing = false
    
    init(color: Color) {
        self.color = color
    }
    
    func possibleMoves(in context: GameContext) -> [RelativePosition] {
        let relativePositions = [RelativePosition(row: 1, column: 2), // moveRightAndUp
                                 RelativePosition(row: -1, column: 2), //moveRightAndDown
                                 RelativePosition(row: -2, column: 1), //moveDownAndRight
                                 RelativePosition(row: -2, column: -1), //moveDownAndLeft
                                 RelativePosition(row: -1, column: -2), //moveLeftAndDown
                                 RelativePosition(row: 1, column: -2), //moveLeftAndUp
                                 RelativePosition(row: 2, column: -1), //moveUpAndLeft
                                 RelativePosition(row: 2, column: 1)] //moveUpAndRight
        
        var possibleMoves = [RelativePosition]()
        
        for coordinate in relativePositions {
            if move(to: coordinate, context: context) {
                possibleMoves.append(coordinate)
            }
        }
        
        return possibleMoves
    }
    
    func move(to: RelativePosition, context: GameContext) -> Bool {
        let tile = context.tile(at: to)
        if tile == Tile.isEmpty || tile == Tile.withEnemy {
            return true
        } else {
            return false
        }
    }
    
    func didMove() {
    }
}

class Bishop: Piece {
    var color: Color
    var isKing = false
    
    init(color: Color) {
        self.color = color
    }
    
    func possibleMoves(in context: GameContext) -> [RelativePosition] {
        let possibleMovesDiagonallyUpAndLeft = move(rowOffset: 1, columnOffset: -1, context: context)
        let possibleMovesDiagonallyDownAndLeft = move(rowOffset: -1, columnOffset: -1, context: context)
        let possibleMovesDiagonallyUpAndRight = move(rowOffset: 1, columnOffset: 1, context: context)
        let possibleMovesDiagonallyDownAndRight = move(rowOffset: -1, columnOffset: 1, context: context)
        
        let possibleMoves = possibleMovesDiagonallyDownAndLeft + possibleMovesDiagonallyUpAndRight + possibleMovesDiagonallyUpAndLeft + possibleMovesDiagonallyDownAndRight
        
        return possibleMoves
    }
    
    func move(rowOffset: Int, columnOffset: Int, context: GameContext) -> [RelativePosition] {
        var possibleMoves: [RelativePosition] = []
        var row = 0 + rowOffset
        var column = 0 + columnOffset
        
        while true {
            let tile = context.tile(at: .init(row: row, column: column))
            if tile == Tile.invalid {
                break
            } else if tile != Tile.isEmpty {
                if tile == Tile.withEnemy {
                    possibleMoves.append(.init(row: row, column: column))
                    break
                } else {
                    break
                }
            } else {
                possibleMoves.append(.init(row: row, column: column))
            }
            row += rowOffset
            column += columnOffset
        }
        return possibleMoves
    }
    
    func didMove() {
    }
}

class King: Piece {
    var color: Color
    var isKing = true
    
    init(color: Color) {
        self.color = color
    }
    
    func possibleMoves(in context: GameContext) -> [RelativePosition] {
        var possibleMoves = [RelativePosition]()
        
        let relativePositions = [RelativePosition(row: 1, column: 0), //moveUp
                                 RelativePosition(row: 1, column: 1), //moveDiagonallyUpAndRight
                                 RelativePosition(row: 0, column: 1), //moveRight
                                 RelativePosition(row: -1, column: 1), //moveDiagonallyDownAndRight
                                 RelativePosition(row: -1, column: 0), //moveDown
                                 RelativePosition(row: -1, column: -1), //moveDiagonallyDownAndLeft
                                 RelativePosition(row: 0, column: -1), //moveLeft
                                 RelativePosition(row: 1, column: -1)] //moveDiagonallyUpAndLeft
        
        for coordinate in relativePositions {
            if move(to: coordinate, context: context) {
                possibleMoves.append(coordinate)
            }
        }
        
        return possibleMoves
    }
    
    func move(to: RelativePosition, context: GameContext) -> Bool {
        let tile = context.tile(at: to)
        if tile == Tile.isEmpty || tile == Tile.withEnemy {
            return true
        } else {
            return false
        }
    }
    
    func didMove() {
    }
}

class Pawn: Piece {
    var color: Color
    var isKing = false
    var firstMove = true
    
    init(color: Color) {
        self.color = color
    }
    
    func possibleMoves(in context: GameContext) -> [RelativePosition] {
        var possibleMoves = [RelativePosition]()
        
        switch firstMove {
        case true:
            let twoTilesUp = context.tile(at: context.position(moveForwardUpTo: 2, moveHorizontalTo: 0))
            let oneTileUp = context.tile(at: context.position(moveForwardUpTo: 1, moveHorizontalTo: 0))
            if twoTilesUp == Tile.isEmpty && oneTileUp == Tile.isEmpty {
                possibleMoves.append(context.position(moveForwardUpTo: 2, moveHorizontalTo: 0))
            }
            if oneTileUp == Tile.isEmpty {
                possibleMoves.append(context.position(moveForwardUpTo: 1, moveHorizontalTo: 0))
            }
            let tileDiagonallyRight = context.tile(at: context.position(moveForwardUpTo: 1, moveHorizontalTo: 1))
            if tileDiagonallyRight == Tile.withEnemy {
                possibleMoves.append(context.position(moveForwardUpTo: 1, moveHorizontalTo: 1))
            }
            let tileDiagonallyLeft = context.tile(at: context.position(moveForwardUpTo: 1, moveHorizontalTo: -1))
            if tileDiagonallyLeft == Tile.withEnemy {
                possibleMoves.append(context.position(moveForwardUpTo: 1, moveHorizontalTo: -1))
            }
            
        case false:
            let oneTileUp = context.tile(at: context.position(moveForwardUpTo: 1, moveHorizontalTo: 0))
            if oneTileUp == Tile.isEmpty {
                possibleMoves.append(context.position(moveForwardUpTo: 1, moveHorizontalTo: 0))
            }
            let tileDiagonallyRight = context.tile(at: context.position(moveForwardUpTo: 1, moveHorizontalTo: 1))
            if tileDiagonallyRight == Tile.withEnemy {
                possibleMoves.append(context.position(moveForwardUpTo: 1, moveHorizontalTo: 1))
            }
            let tileDiagonallyLeft = context.tile(at: context.position(moveForwardUpTo: 1, moveHorizontalTo: -1))
            if tileDiagonallyLeft == Tile.withEnemy {
                possibleMoves.append(context.position(moveForwardUpTo: 1, moveHorizontalTo: -1))
            }
        }
        return possibleMoves
    }
    
    func didMove() {
        firstMove = false
    }
}
