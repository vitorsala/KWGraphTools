
//
//  TileName.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 02/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

protocol TileName {
    var name: String { get }
}

extension TileName where Self: RawRepresentable, Self.RawValue == String {
    var name: String { return self.rawValue }
}
