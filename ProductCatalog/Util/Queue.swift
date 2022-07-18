//
//  Queue.swift
//  ProductCatalog
//
//  Created by Victor Zeng on 7/17/22.
//

import Foundation
public class LinkedList<T> {
    var data: T
    var next: LinkedList?
    public init(data: T){
        self.data = data
    }
}
public actor  DataQueue<T> {
    typealias LLNode = LinkedList<T>
    
    var first: LLNode?
    var last: LLNode?
    
    public var isEmpty: Bool { return first == nil }
    var doneReading: Bool = false
    
    func enqueue(key: T) {
        let nextItem = LLNode(data: key)
        
        if let lastNode = last {
            lastNode.next = nextItem
            last = nextItem
        } else {
            first = nextItem
            last = nextItem
        }
    }
    func dequeue() -> T? {
        guard let d = first else {return nil}
        first = d.next
        if first == nil {
            last = nil
        }
        return d.data
    }
    
    func notifyDoneReading() {
        self.doneReading = true
    }
    func isReadingDone() -> Bool {
        return self.doneReading
    }
}
