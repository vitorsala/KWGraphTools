//
//  PriorityQueue.swift
//  KPathFinding
//
//  Created by Vitor Kawai Sala on 29/08/18.
//

import Foundation

struct PriorityQueueElement<T>: Comparable {
    let element: T
    let priority: Float
    
    static func < (lhs: PriorityQueueElement, rhs: PriorityQueueElement) -> Bool {
        return lhs.priority < rhs.priority
    }
    static func > (lhs: PriorityQueueElement, rhs: PriorityQueueElement) -> Bool {
        return lhs.priority > rhs.priority
    }
    static func == (lhs: PriorityQueueElement, rhs: PriorityQueueElement) -> Bool {
        return lhs.priority == rhs.priority
    }
}

// MARK :- Priority Queue
/// Priority queue to be used with Djikstra Algorithm
internal class PriorityQueue<T> {
    
    /// The array storing the Heap Tree
    private var tree: [PriorityQueueElement<T>] = []
    
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
        return tree.first?.element
    }
    
    /// Initialize an empty queue
    internal init(){}
    
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
    internal func enqueue(_ element: T, priority: Float){
        let elem = PriorityQueueElement(element: element, priority: priority)
        self.tree.append(elem)
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
        return ret.element
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
            } else {
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
        } else if right >= self.count {
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
