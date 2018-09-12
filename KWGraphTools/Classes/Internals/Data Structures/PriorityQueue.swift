//
//  PriorityQueue.swift
//  KPathFinding
//
//  Created by Vitor Kawai Sala on 29/08/18.
//

import Foundation

// MARK :- Priority Queue
/// Priority queue to be used with Djikstra Algorithm
internal class PriorityQueue<T: Comparable> {
    
    /// The array storing the Heap Tree
    private var tree: [T] = []
    
    // MARK: Tree's status
    /// Return the number of elements in the tree
    var count: Int {
        return tree.count
    }
    
    /// Return if the tree is empty
    var isEmpty: Bool {
        return tree.isEmpty
    }
    
    /// Return the root element of the tree.
    internal var root: T? {
        return tree.first
    }
    
    /// Initialize an empty queue
    internal init(){}
    
    /// Inilialize an queue with an array of elements.
    ///
    /// the element's array must be the same size of priorities's array
    /// - Parameters:
    ///   - array: An array containing all elements to be included to the queue.
    ///   - priorities: An array containing all priorities associated with element's array
    /// - Throws: An *PriorityQueueError* if the element's array size does not match with the priorities array size
    internal init(withArray array: [T]) throws {
        for elem in array {
            self.enqueue(elem)
        }
    }
    
    #if DEBUG
    /// MARK: - Convenience functions
    /// Print current tree
    func printTree() {
        self.tree.forEach {
            print("\($0) ", separator: "", terminator: "")
        }
    }
    #endif
}

extension PriorityQueue {
    /// Enqueue an element
    ///
    /// - Parameters:
    ///   - element: element to be enqueued
    ///   - withPriority: the element priority in the queue
    internal func enqueue(_ element: T){
        self.tree.append(element)
        self.heapifyUp(fromIndex: self.count - 1)
    }
    
    /// dequeue an element
    ///
    /// - Returns: The first element in the queue
    internal func dequeue() -> T? {
        guard !self.isEmpty, let lastElem = self.tree.last else { return nil }
        let ret = tree[0]
        tree[0] = lastElem
        let _ = tree.popLast()
        if !self.isEmpty {
            heapifyDown(fromIndex: 0)
        }
        return ret
    }
}

// MARK: Internal Functions
// MARK: Construction & Maintenance
extension PriorityQueue {
    /// Normalize heap tree from bottom-up
    ///
    /// - Parameter startingIndex: index of the first element to be normalized.
    private func heapifyUp(fromIndex startingIndex: Int) {
        guard startingIndex > 0 else { return }
        
        var i = startingIndex
        var parent = self.parent(ofIndex: i)
        
        while(i > 0 && tree[i] < tree[parent]) {
            self.tree.swapAt(i, parent)
            i = parent
            parent = self.parent(ofIndex: i)
        }
    }
    
    /// Normalize heap tree from top-down
    ///
    /// - Parameter startingIndex: index of the first element to be normalized.
    private func heapifyDown(fromIndex startingIndex: Int) {
        var i = startingIndex
        
        while let sel = self.chooseBetweenChildrens(ofIndex: i) {
            if tree[sel] < tree[i] {
                self.tree.swapAt(sel, i)
                i = sel
            }
            else {
                return
            }
        }
    }
    
    /// Select child using the `comparator` passed through `init`
    ///
    /// - Parameter i: parent's index
    /// - Returns: selected child's index or nil if the parent have no child
    private func chooseBetweenChildrens(ofIndex i: Int) -> Int? {
        let left = self.leftChild(ofIndex: i)
        let right = left + 1
        
        if left >= self.count {
            return nil
        }
        else if right >= self.count {
            return left
        }
        return (tree[left] < tree[right] ? left : right)
    }
    
    /// Build heap
    private func buildHeap() {
        guard self.count >= 0 else { return }
        
        for i in stride(from: (self.count >> 1) - 1, to: -1, by: -1) {
            heapifyDown(fromIndex: i)
        }
    }
}

// MARK: Index access
extension PriorityQueue {
    private func parent(ofIndex i: Int) -> Int {
        return Int(i - 1) >> 1
    }
    
    private func leftChild(ofIndex i: Int) -> Int {
        return (i << 1) | 1
    }
    
    private func rightChild(ofIndex i: Int) -> Int {
        return self.leftChild(ofIndex: i) + 1
    }
}

enum PriorityQueueError: Error {
    case sizesDoesNotMatch(arraySize: Int, prioritySize: Int)
}
