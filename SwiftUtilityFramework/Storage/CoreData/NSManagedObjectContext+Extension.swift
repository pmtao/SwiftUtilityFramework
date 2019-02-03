//
//  NSManagedObjectContext+Extension.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-9-20.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    // MARK: --查询方法----------------
    
    /// 通用数据查询方法
    public func fetch<T>(request: NSFetchRequest<T>) -> [T] {
        var entity: [T] = []
        do {
            entity = try self.fetch(request)
        } catch let error as NSError {
            print("\(T.self) Fetching error: \(error), \(error.userInfo)")
        }
        return entity
    }
    
    // MARK: --变更方法----------------
    
    /// 在实体中插入一条新纪录
    public func insertObject<Model: NSManagedObject>()
        -> Model where Model: CoreDataObjectManageable
    {
        guard let obj = NSEntityDescription.insertNewObject(
            forEntityName: Model.entityName, into: self) as? Model
            else {
                fatalError("在 Core Data 中插入记录时，指定的模型类型错误。")
        }
        return obj
    }
    
    /// 将变更保存至存储中，如果失败则进行回滚。
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
    
    /// 在上下文所在的队列中执行变更操作，并将变更保存至存储中，在失败时进行回滚。
    public func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
    
    /// 在上下文所在的队列中执行变更操作，并将此操作放入指定的任务组中。
    public func perform(group: DispatchGroup, block: @escaping () -> ()) {
        group.enter()
        perform {
            block()
            group.leave()
        }
    }
    
    /// 统计当前上下文中包含的变更数量，含 3 类操作：新增、修改、删除
    fileprivate var changedObjectsCount: Int {
        return insertedObjects.count + updatedObjects.count + deletedObjects.count
    }
    
    /// 延迟保存变更，为提高性能减少保存次数，累积上下文更改到 100 个时再保存，不够时先放入任务组中，
    /// 等任务组中前一批执行完后再执行，保存失败时进行回滚。
    /// > **通常用于 CloudKit 操作结束后在本地存储中批量添加远程标识符，以表示与远程一致。**
    ///
    /// - Parameters:
    ///   - group: 用于累积任务的任务组
    ///   - completion: 保存结束后的操作，入参为保存是否成功，默认无操作。
    public func delayedSaveOrRollback(group: DispatchGroup,
                               completion: @escaping (Bool) -> () = { _ in })
    {
        let changeCountLimit = 100
        guard changeCountLimit >= changedObjectsCount else {
            return completion(saveOrRollback())
        }
        let queue = DispatchQueue.global(qos: .default)
        group.notify(queue: queue) {
            self.perform(group: group) {
                guard self.hasChanges else { return completion(true) }
                completion(self.saveOrRollback())
            }
        }
    }
    
    // MARK: --便利属性----------------
    
    /// /// 上下文所在的 NSPersistentStore
    private var store: NSPersistentStore {
        guard let psc = persistentStoreCoordinator else {
            fatalError("persistentStoreCoordinator missing.") }
        guard let store = psc.persistentStores.first else {
            fatalError("PersistentStoreCoordinator Has No Store.") }
        return store
    }
    
    /// 上下文所在的 NSPersistentStore 的元数据
    public var metaData: [String: AnyObject] {
        get {
            guard let psc = persistentStoreCoordinator else {
                fatalError("must have persistentStoreCoordinator") }
            return psc.metadata(for: store) as [String : AnyObject]
        }
        set {
            performChanges {
                guard let psc = self.persistentStoreCoordinator else {
                    fatalError("persistentStoreCoordinator missing") }
                psc.setMetadata(newValue, for: self.store)
            }
        }
    }
    
    /// 设置上下文所在的 NSPersistentStore 的元数据
    public func setMetaData(object: AnyObject?, forKey key: String) {
        var md = metaData
        md[key] = object
        metaData = md
    }
    
}

/// 对 NSManagedObject 类型的集合进行扩展，将一个上下文中的托管对象映射为另一个上下文中的对象（上下文所在的协调器相同）
extension Sequence where Iterator.Element: NSManagedObject {
    public func remap(to context: NSManagedObjectContext) -> [Iterator.Element] {
        return map { unmappedMO in
            guard unmappedMO.managedObjectContext !== context else { return unmappedMO }
            guard let object = context.object(with: unmappedMO.objectID) as? Iterator.Element else { fatalError("Invalid object type") }
            return object
        }
    }
}
