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
