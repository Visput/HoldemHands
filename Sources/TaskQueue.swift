//
//  TaskQueue.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 7/1/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import SwiftTask

final class TaskQueue<Progress, Value, Error> {
    
    private var items = [TaskQueueItem<Progress, Value, Error>]()
    private let defaultValue: Value
    
    init(defaultValue: Value) {
        self.defaultValue = defaultValue
    }
    
    func addTask(task: () -> Task<Progress, Value, Error>) -> Task<Progress, Value, Error> {
        let isQueueEmpty = items.isEmpty
        
        var item: TaskQueueItem<Progress, Value, Error>! = nil
        let outTask = Task<Progress, Value, Error>(promiseInitClosure: { fulfill, reject in
            item = TaskQueueItem(inTaskClosure: task, outFulfillClosure: fulfill, outRejectClosure: reject)
        })
        
        items.append(item)
        
        if isQueueEmpty {
            executePendingTasks()
        }
        
        return outTask
    }
}

extension TaskQueue {
    
    private func executePendingTasks() -> Task<Progress, Value, Error> {
        guard !items.isEmpty else {
            return Task<Progress, Value, Error>(initClosure: { _, fulfill, _, _ in
                fulfill(self.defaultValue)
            })
        }

        let item = items.first!
        return item.inTaskClosure().then({ value, errorInfo in
            return Task<Progress, Value, Error>(initClosure: { _, fulfill, _, _ in
                if let value = value {
                    item.outFulfillClosure(value)
                } else {
                    item.outRejectClosure(errorInfo!.error!)
                }
                
                let _ = self.items.removeFirst()
                fulfill(self.defaultValue)
            })
        }).then({ _, _ in
            return self.executePendingTasks()
        })
    }
}

typealias SimpleTaskQueue = TaskQueue<Float, Void, Void>

extension TaskQueue {
    
    static func simpleQueue() -> SimpleTaskQueue {
        return SimpleTaskQueue(defaultValue: Void())
    }
}
