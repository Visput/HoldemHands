//
//  TaskQueue.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 7/1/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import SwiftTask

final class TaskQueue<Progress, Value, Error> {
    
    private var tasks: [() -> Task<Progress, Value, Error>] = []
    private let defaultValue: Value
    
    init(defaultValue: Value) {
        self.defaultValue = defaultValue
    }
    
    func addTask(task: () -> Task<Progress, Value, Error>) {
        let isQueueEmpty = tasks.isEmpty
        tasks.append(task)
        
        if isQueueEmpty {
            executePendingTasks()
        }
    }
}

extension TaskQueue {
    
    private func executePendingTasks() -> Task<Progress, Value, Error> {
        guard !tasks.isEmpty else {
            return Task<Progress, Value, Error>(initClosure: { _, fulfill, _, _ in
                fulfill(self.defaultValue)
            })
        }

        let task = tasks.first!
        return task().then({ _, _ in
            return Task<Progress, Value, Error>(initClosure: { _, fulfill, _, _ in
                let _ = self.tasks.removeFirst()
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
