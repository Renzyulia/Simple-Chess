//
//  ViewController.swift
//  SimpleChess
//
//  Created by d.kelt on 25.11.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let chessView = ChessBoardView()
        chessView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(chessView)
        
        NSLayoutConstraint.activate([
            chessView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -16),
            chessView.heightAnchor.constraint(equalTo: view.widthAnchor),
            chessView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            chessView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        chessView.resetBoard()
    }
}

class GameController: ChessBoardViewDelegate {
    var chessBoardView = ChessBoardView()
    var board = ChessBoard(storage: StorageForPieces())
    var numberOfTap = 0
    var selectedPiece: Piece? = nil
    
    init() {
        chessBoardView.delegate = self
    }
    
    func userDidTap(row: Int, column: Int) {
        switch numberOfTap {
        case 0:
            if let piece = board.storage.piece(at: .init(row: row, column: column)!) {
                selectedPiece = piece
                numberOfTap = 1
            }
        case 1:
            //сначала мы проверяем, что наша фигура, выбранная на первом тапе может ходить на выбранную вторым тапом клетку
            // если она может ходить, то мы проверяем не возникнет ли шаха королю этим ходом
            //если не возникает, то можно сходить
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
        if row < 8 {
            self.row = row
        } else {
            return nil
        }
        if column < 8 {
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
    func position(moveForwardUpTo: Int) -> RelativePosition
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
    
    func position(moveForwardUpTo: Int) -> RelativePosition {
        if piece.color == .white {
            return .init(row: -(moveForwardUpTo), column: 0)
        } else {
            return .init(row: moveForwardUpTo, column: 0)
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

class ChessBoard: Board {
    let storage: Storage
    var pieces: [Piece] {
        return storage.pieces
    }
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    func kingPosition(for color: Color) -> Coordinate {
        for piece in pieces {
            if piece.isKing && piece.color == color {
                return storage.coordinate(of: piece)!
            }
        }
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
            let coordinate = self.storage.coordinate(of: piece)
            let context = ContextForPiece(piece: piece, coordinate: coordinate!, board: self)
            if piece.color != color {
                for move in piece.possibleMoves(in: context) {
                    if move.row == kingPosition.row && move.column == kingPosition.column {
                        return true
                    }
                }
            }
        }
    }
    
    func board(afterMovingPieceFrom: Coordinate, to: Coordinate) -> Board {
        let movedPiece = storage.piece(at: afterMovingPieceFrom)
        let shadowStorage = storage.shadow(byMoving: movedPiece!, to: to)
        let board = ChessBoard(storage: shadowStorage)
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
    
    var boardElement = [
        BoardElement(piece: Rook(color: .white), coordinate: .init(row: 0, column: 0)!),
        BoardElement(piece: Knight(color: .white), coordinate: .init(row: 0, column: 1)!),
        BoardElement(piece: Bishop(color: .white), coordinate: .init(row: 0, column: 2)!),
        BoardElement(piece: Queen(color: .white), coordinate: .init(row: 0, column: 3)!),
        BoardElement(piece: King(color: .white), coordinate: .init(row: 0, column: 4)!),
        BoardElement(piece: Bishop(color: .white), coordinate: .init(row: 0, column: 5)!),
        BoardElement(piece: Knight(color: .white), coordinate: .init(row: 0, column: 6)!),
        BoardElement(piece: Rook(color: .white), coordinate: .init(row: 0, column: 7)!),
        BoardElement(piece: Pawn(color: .white), coordinate: .init(row: 1, column: 0)!),
        BoardElement(piece: Pawn(color: .white), coordinate: .init(row: 1, column: 1)!),
        BoardElement(piece: Pawn(color: .white), coordinate: .init(row: 1, column: 2)!),
        BoardElement(piece: Pawn(color: .white), coordinate: .init(row: 1, column: 3)!),
        BoardElement(piece: Pawn(color: .white), coordinate: .init(row: 1, column: 4)!),
        BoardElement(piece: Pawn(color: .white), coordinate: .init(row: 1, column: 5)!),
        BoardElement(piece: Pawn(color: .white), coordinate: .init(row: 1, column: 6)!),
        BoardElement(piece: Pawn(color: .white), coordinate: .init(row: 1, column: 7)!),
        BoardElement(piece: Rook(color: .black), coordinate: .init(row: 6, column: 0)!),
        BoardElement(piece: Knight(color: .black), coordinate: .init(row: 6, column: 1)!),
        BoardElement(piece: Bishop(color: .black), coordinate: .init(row: 6, column: 2)!),
        BoardElement(piece: Queen(color: .black), coordinate: .init(row: 6, column: 3)!),
        BoardElement(piece: King(color: .black), coordinate: .init(row: 6, column: 4)!),
        BoardElement(piece: Bishop(color: .black), coordinate: .init(row: 6, column: 5)!),
        BoardElement(piece: Knight(color: .black), coordinate: .init(row: 6, column: 6)!),
        BoardElement(piece: Rook(color: .black), coordinate: .init(row: 6, column: 7)!),
        BoardElement(piece: Pawn(color: .black), coordinate: .init(row: 7, column: 0)!),
        BoardElement(piece: Pawn(color: .black), coordinate: .init(row: 7, column: 1)!),
        BoardElement(piece: Pawn(color: .black), coordinate: .init(row: 7, column: 2)!),
        BoardElement(piece: Pawn(color: .black), coordinate: .init(row: 7, column: 3)!),
        BoardElement(piece: Pawn(color: .black), coordinate: .init(row: 7, column: 4)!),
        BoardElement(piece: Pawn(color: .black), coordinate: .init(row: 7, column: 5)!),
        BoardElement(piece: Pawn(color: .black), coordinate: .init(row: 7, column: 6)!),
        BoardElement(piece: Pawn(color: .black), coordinate: .init(row: 7, column: 7)!)
    ]
    
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
                index = 1
            }
        }
        return index
    }
    
    func shadow(byRemoving: Piece) -> Storage {
        let shadowStorage = ShadowStorageRemovingPiece(originalStorage: self, removedPiece: byRemoving)
        return shadowStorage
    }
    
    func shadow(byAdding: Piece, at: Coordinate) -> Storage {
        let shadowStorage = ShadowStorageAdditingPiece(originalStorage: self, addedPiece: byAdding, coordinate: at)
        return shadowStorage
    }
    
    func shadow(byMoving: Piece, to: Coordinate) -> Storage {
        let shadowStorage = ShadowStorageMovingPiece(originalStorage: self, movedPiece: byMoving, coordinate: to)
        return shadowStorage
    }
}

class ShadowStorageRemovingPiece: Storage {
    var pieces: [Piece] = []
    let originalStorage: Storage
    let removedPiece: Piece
    
    init (originalStorage: Storage, removedPiece: Piece) {
        self.originalStorage = originalStorage
        self.removedPiece = removedPiece
    }
    
    func piece(at: Coordinate) -> Piece? {
        return originalStorage.piece(at: at)
    }
    
    func coordinate(of: Piece) -> Coordinate? {
        if of === removedPiece {
            return nil
        } else {
            return originalStorage.coordinate(of: of)
        }
    }
    
    func shadow(byRemoving: Piece) -> Storage {
        let shadowStorage = ShadowStorageRemovingPiece(originalStorage: self, removedPiece: byRemoving)
        return shadowStorage
    }
    
    func shadow(byAdding: Piece, at: Coordinate) -> Storage {
        let shadowStorage = ShadowStorageAdditingPiece(originalStorage: self, addedPiece: byAdding, coordinate: at)
        return shadowStorage
    }
    
    func shadow(byMoving: Piece, to: Coordinate) -> Storage {
        let shadowStorage = ShadowStorageMovingPiece(originalStorage: self, movedPiece: byMoving, coordinate: to)
        return shadowStorage
    }
}

class ShadowStorageMovingPiece: Storage {
    var pieces: [Piece] = []
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
    
    func shadow(byRemoving: Piece) -> Storage {
        let shadowStorage = ShadowStorageRemovingPiece(originalStorage: self, removedPiece: byRemoving)
        return shadowStorage
    }
    
    func shadow(byAdding: Piece, at: Coordinate) -> Storage {
        let shadowStorage = ShadowStorageAdditingPiece(originalStorage: self, addedPiece: byAdding, coordinate: at)
        return shadowStorage
    }
    
    func shadow(byMoving: Piece, to: Coordinate) -> Storage {
        let shadowStorage = ShadowStorageMovingPiece(originalStorage: self, movedPiece: byMoving, coordinate: to)
        return shadowStorage
    }
}

class ShadowStorageAdditingPiece: Storage {
    var pieces: [Piece] = []
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
    
    func shadow(byRemoving: Piece) -> Storage {
        let shadowStorage = ShadowStorageRemovingPiece(originalStorage: self, removedPiece: byRemoving)
        return shadowStorage
    }
    
    func shadow(byAdding: Piece, at: Coordinate) -> Storage {
        let shadowStorage = ShadowStorageAdditingPiece(originalStorage: self, addedPiece: byAdding, coordinate: at)
        return shadowStorage
    }
    
    func shadow(byMoving: Piece, to: Coordinate) -> Storage {
        let shadowStorage = ShadowStorageMovingPiece(originalStorage: self, movedPiece: byMoving, coordinate: to)
        return shadowStorage
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
            var tile = context.tile(at: .init(row: row, column: column))
            if tile == Tile.invalid {
                break
            } else if tile == Tile.withEnemy {
                possibleMoves.append(.init(row: row, column: column))
                break
            } else {
                possibleMoves.append(.init(row: row, column: column))
            }
            row += rowOffset
            column += columnOffset
        }
        return possibleMoves
    }
    
    func didMove() {
        <#code#>
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
        
        let possibleMoves = possibleMovesDown + possibleMovesLeft + possibleMovesUp + possibleMovesRight + possibleMovesDiagonallyUpAndLeft + possibleMovesDiagonallyDownAndLeft + possibleMovesDiagonallyUpAndRight + possibleMovesDiagonallyDownAndLeft
        
        return possibleMoves
    }
    
    func move(rowOffset: Int, columnOffset: Int, context: GameContext) -> [RelativePosition] {
        var possibleMoves: [RelativePosition] = []
        var row = 0 + rowOffset
        var column = 0 + columnOffset
        
        while true {
            var tile = context.tile(at: .init(row: row, column: column))
            if tile == Tile.invalid {
                break
            } else if tile == Tile.withEnemy {
                possibleMoves.append(.init(row: row, column: column))
                break
            } else {
                possibleMoves.append(.init(row: row, column: column))
            }
            row += rowOffset
            column += columnOffset
        }
        return possibleMoves
    }
    
    func didMove() {
        <#code#>
    }
}

class Knight: Piece {
    var color: Color
    var isKing = false
    
    init(color: Color) {
        self.color = color
    }
    
    func possibleMoves(in context: GameContext) -> [RelativePosition] {
        let moveRightAndUp = move(to: .init(row: 1, column: 2), context: context)
        let moveRightAndDown = move(to: .init(row: -1, column: 2), context: context)
        let moveDownAndRight = move(to: .init(row: -2, column: 1), context: context)
        let moveDownAndLeft = move(to: .init(row: -2, column: -1), context: context)
        let moveLeftAndDown = move(to: .init(row: -1, column: -2), context: context)
        let moveLeftAndUp = move(to: .init(row: 1, column: -2), context: context)
        let moveUpAndLeft = move(to: .init(row: 2, column: -1), context: context)
        let moveUpAndRight = move(to: .init(row: 2, column: 1), context: context)
        
        let possibleMoves = [moveRightAndDown, moveRightAndUp, moveDownAndRight, moveDownAndLeft, moveLeftAndDown, moveLeftAndUp, moveRightAndDown, moveUpAndRight]
        
        return possibleMoves
    }
    
    func move(to: RelativePosition, context: GameContext) -> RelativePosition {
        var tile = context.tile(at: to)
        if tile == Tile.isEmpty || tile == Tile.withEnemy {
            return to
        }
    }
    
    func didMove() {
        <#code#>
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
            var tile = context.tile(at: .init(row: row, column: column))
            if tile == Tile.invalid {
                break
            } else if tile == Tile.withEnemy {
                possibleMoves.append(.init(row: row, column: column))
                break
            } else {
                possibleMoves.append(.init(row: row, column: column))
            }
            row += rowOffset
            column += columnOffset
        }
        return possibleMoves
    }
    
    func didMove() {
        <#code#>
    }
}

class King: Piece {
    var color: Color
    var isKing = true
    
    init(color: Color) {
        self.color = color
    }
    
    func possibleMoves(in context: GameContext) -> [RelativePosition] {
        let moveUp = move(to: .init(row: 1, column: 0), context: context)
        let moveDiagonallyUpAndRight = move(to: .init(row: 1, column: 1), context: context)
        let moveRight = move(to: .init(row: 0, column: 1), context: context)
        let moveDiagonallyDownAndRight = move(to: .init(row: -1, column: 1), context: context)
        let moveDown = move(to: .init(row: -1, column: 0), context: context)
        let moveDiagonallyDownAndLeft = move(to: .init(row: -1, column: -1), context: context)
        let moveLeft = move(to: .init(row: 0, column: -1), context: context)
        let moveDiagonallyUpAndLeft = move(to: .init(row: 1, column: -1), context: context)
        
        let possibleMoves = [moveUp, moveDiagonallyUpAndRight, moveRight, moveDiagonallyDownAndRight, moveDown, moveDiagonallyDownAndLeft, moveLeft, moveDiagonallyUpAndLeft]
    }
    
    func move(to: RelativePosition, context: GameContext) -> RelativePosition {
        var tile = context.tile(at: to)
        if tile == Tile.isEmpty || tile == Tile.withEnemy {
            return to
        }
    }
    
    func didMove() {
        <#code#>
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
            let twoTilesUp = context.tile(at: .init(row: 2, column: 0))
            if twoTilesUp == Tile.isEmpty {
                possibleMoves.append(.init(row: 2, column: 0))
            }
            let oneTileUp = context.tile(at: .init(row: 1, column: 0))
            if oneTileUp == Tile.isEmpty {
                possibleMoves.append(.init(row: 1, column: 0))
            }
            let tileDiagonallyRight = context.tile(at: .init(row: 1, column: -1))
            if tileDiagonallyRight == Tile.withEnemy {
                possibleMoves.append(.init(row: 1, column: -1))
            }
            let tileDiagonallyLeft = context.tile(at: .init(row: 1, column: 1))
            if tileDiagonallyLeft == Tile.withEnemy {
                possibleMoves.append(.init(row: 1, column: 1))
            }
        case false:
            let oneTileUp = context.tile(at: .init(row: 1, column: 0))
            if oneTileUp == Tile.isEmpty {
                possibleMoves.append(.init(row: 1, column: 0))
            }
            let tileDiagonallyRight = context.tile(at: .init(row: 1, column: -1))
            if tileDiagonallyRight == Tile.withEnemy {
                possibleMoves.append(.init(row: 1, column: -1))
            }
            let tileDiagonallyLeft = context.tile(at: .init(row: 1, column: 1))
            if tileDiagonallyLeft == Tile.withEnemy {
                possibleMoves.append(.init(row: 1, column: 1))
            }
        }
        return possibleMoves
    }
    
    func didMove() {
        firstMove = false
    }
}
