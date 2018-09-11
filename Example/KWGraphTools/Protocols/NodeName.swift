//
//  NodeName.swift
//  KPathFinding_Example
//
//  Created by Vitor Kawai Sala on 01/09/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

protocol NodeName {
    var name: String { get }
}

extension NodeName where Self: RawRepresentable, Self.RawValue == String {
    var name: String { return self.rawValue }
}
