//
//  KWInternalExtensions.swift
//  KWGraphTools
//
//  Created by Vitor Kawai Sala on 27/09/18.
//

import GameplayKit

extension vector_int2 {
    internal init(point: CGPoint) {
        self.init(x: Int32(point.x), y: Int32(point.y))
    }
}

extension CGPoint {
    internal init(vector: vector_int2) {
        self.init(x: Int(vector.x), y: Int(vector.y))
    }
}
