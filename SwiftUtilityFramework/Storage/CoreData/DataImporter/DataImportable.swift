//
//  DataImportable.swift
//  SwiftUtilityFramework
//
//  Created by 阿涛 on 18-9-18.
//  Copyright © 2018年 SinkingSoul. All rights reserved.
//

import CoreData

public protocol ManagedObjectImportable {
    associatedtype JsonModel: Codable
    associatedtype JsonModelItem: Codable
    associatedtype Object: NSManagedObject

    static func prepareItemsToImport(_ model: JsonModel) -> [JsonModelItem]
    static func insert(_ item: JsonModelItem, into context: NSManagedObjectContext) -> Object?
}

public enum JsonParseError: Error {
    case invalidJsonFormat
    case emptyFile
    case cannotFindJsonFile
}

public enum ManagedObjectContextError: Error {
    case saveError
}

extension ManagedObjectImportable {
    static func importJson(from jsonPath: String) -> Result<JsonModel> {
        do {
            if let jsonData = NSData(contentsOfFile: jsonPath) as Data? {
                let model = try JSONDecoder().decode(JsonModel.self, from: jsonData)
                return Result.success(model)
            } else {
                return Result.error(JsonParseError.emptyFile)
            }
        } catch {
            return Result.error(JsonParseError.invalidJsonFormat)
        }
    }
    
    static func batchInsert(_ model: JsonModel, into context: NSManagedObjectContext) -> [Object] {
        var objects = [Object]()
        let itemsToImport = prepareItemsToImport(model)
        for item in itemsToImport {
            if let object = insert(item, into: context) {
                objects.append(object)
            }
        }
        return objects
    }
    
    static public func importJson(named jsonFileName: String,
                                  into context: NSManagedObjectContext) throws
    {
        guard let jsonPath = Bundle.main.path(forResource: jsonFileName, ofType: "json") else {
            throw JsonParseError.cannotFindJsonFile
        }
        let modelImportResult = importJson(from: jsonPath)
        switch modelImportResult {
        case .success(let model):
            _ = batchInsert(model, into: context)
            let saveResult = context.saveOrRollback()
            if !saveResult {
                throw ManagedObjectContextError.saveError
            }
        case .error(let error):
            throw error
        }
    }
}
