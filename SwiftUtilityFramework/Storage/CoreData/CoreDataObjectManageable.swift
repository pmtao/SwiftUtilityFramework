//
//  CoreDataObjectManageable.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-9-18.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import CoreData

/// 适用于 Core Data 中 NSManagedObject 对象的协议，简化获取请求等相关便利属性和方法。
public protocol CoreDataObjectManageable: class, NSFetchRequestResult {
    /// 实体名称
    static var entityName: String { get }
    /// 默认的排序方式
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
    /// 默认谓词
    static var defaultPredicate: NSPredicate { get }
}

extension CoreDataObjectManageable {
    /// 默认的排序方式（初始值：无排序）
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }
    /// 默认谓词（初始值：所有记录）
    public static var defaultPredicate: NSPredicate { return NSPredicate(value: true) }
    /// 默认获取请求(使用默认排序器、默认谓词)
    public static var defaultFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        request.predicate = defaultPredicate
        return request
    }
}

extension CoreDataObjectManageable where Self: NSManagedObject {
    public static var entity: NSEntityDescription { return entity()  }
    
    public static var entityName: String {
        return entity.name!
    }
    
    /// 获取托管对象记录数
    public static func count(in context: NSManagedObjectContext,
                             configure: (NSFetchRequest<Self>) -> () = { _ in })
        -> Int {
            let request = NSFetchRequest<Self>(entityName: entityName)
            configure(request)
            return try! context.count(for: request)
    }
}
