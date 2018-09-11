//
//  PriorityQueue.swift
//  KPathFinding
//
//  Created by Vitor Kawai Sala on 29/08/18.
//

import Foundation

/// Struct representing an queue element. This struct is used to associate an element with its priority
private struct QueueElement<T> {
    var priority : Float
    var element : T
    
    init(element : T, priority : Float){
        self.priority = priority
        self.element = element
    }
}

extension QueueElement: Comparable {
    static func <(lhs: QueueElement, rhs: QueueElement) -> Bool {
        return lhs.priority < rhs.priority
    }
    
    static func >(lhs: QueueElement, rhs: QueueElement) -> Bool {
        return lhs.priority > rhs.priority
    }
    
    static func ==(lhs: QueueElement, rhs: QueueElement) -> Bool {
        return lhs.priority == rhs.priority
    }
}

// MARK :- Priority Queue
/// Priority queue to be used with Djikstra Algorithm
internal class PriorityQueue<T> {
    private let heap = HeapTree<QueueElement<T>>(type: HeapType.minHeap)
    
    internal var isEmpty: Bool {
        return self.heap.isEmpty
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
    internal init(withArray array: [T], andPriorityArray priorities: [Float]) throws {
        guard array.count == priorities.count else {
            throw PriorityQueueError.sizesDoesNotMatch(arraySize: array.count, prioritySize: priorities.count)
        }
        for i in 0..<array.count {
            self.enqueue(element: array[i], withPriority: priorities[i])
        }
    }
    
    #if DEBUG
    internal func print() {
        self.heap.printTree()
    }
    #endif
}

extension PriorityQueue {
    /// Enqueue an element
    ///
    /// - Parameters:
    ///   - element: element to be enqueued
    ///   - withPriority: the element priority in the queue
    internal func enqueue(element: T, withPriority: Float){
        heap.insert(element: QueueElement<T>(element: element, priority: withPriority))
    }
    
    /// dequeue an element
    ///
    /// - Returns: The first element in the queue
    internal func dequeue() -> T? {
        return heap.remove(elementAtIndex: 0)?.element
    }
    
    /// Get the first element without dequeueing.
    ///
    /// - Returns: The first element in the queue
    internal func peek() -> T? {
        return heap.root?.element
    }
}

enum PriorityQueueError: Error {
    case sizesDoesNotMatch(arraySize: Int, prioritySize: Int)
}
