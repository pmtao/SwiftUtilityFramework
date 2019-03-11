//
//  CoreDataContainer.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-9-18.
//  Copyright © 2019年 SinkingSoul. All rights reserved.
//

import CoreData

/// Core Data 全局容器
private func defaultCoreDataContainer(_ name: CoreDataEnvironment.Name) -> NSPersistentContainer {
    return NSPersistentContainer(name: name.rawValue)
}

/// 加载 Core Data 存储
public func createContainer(_ name: CoreDataEnvironment.Name,
                            completion: @escaping (NSPersistentContainer) -> Void) {
    let container = defaultCoreDataContainer(name)
    container.loadPersistentStores { _, error in
        if error == nil {
            DispatchQueue.main.async {
                completion(container)
            }
        } else {
            fatalError("加载 NSPersistentStore 失败: \(error!)")
        }
    }
}
