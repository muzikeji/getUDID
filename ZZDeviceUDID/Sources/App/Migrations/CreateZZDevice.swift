//
//  CreateXYDevice.swift
//  
//
//  Created by SandsLee on 2022/5/29.
//

import Fluent

struct CreateZZDevice: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ZZ_DEVICE_SCHEMA)
            .id()
            .field("name", .string)
            .field("model", .string, .required)
            .field("udid", .string, .required)
            .field("serial", .string, .required)
            .field("owner", .string)
            .field("created_at", .string)
            .field("updated_at", .string)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ZZ_DEVICE_SCHEMA).delete()
    }
}
