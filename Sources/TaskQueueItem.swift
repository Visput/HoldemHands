//
//  TaskQueueItem.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 7/6/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import SwiftTask

struct TaskQueueItem<Progress, Value, Error> {
    
    let inTaskClosure: () -> Task<Progress, Value, Error>
    let outFulfillClosure: Task<Progress, Value, Error>.FulfillHandler
    let outRejectClosure: Task<Progress, Value, Error>.RejectHandler
}
