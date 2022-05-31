//
//  XYDeviceController.swift
//  
//
//  Created by SandsLee on 2022/5/29.
//

import Fluent
import Vapor

struct ZZDeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let zzdevices = routes.grouped("zzdevices")
        zzdevices.get(use: index)
        zzdevices.post(use: create)
        zzdevices.group(":zzdeviceID") { device in
            device.delete(use: delete)
        }
        zzdevices.group("update") { device in
            device.post(use: update)
        }
    }

    func index(req: Request) async throws -> [ZZDevice] {
        try await ZZDevice.query(on: req.db).all()
    }

    func create(req: Request) async throws -> ZZDevice {
        let zzdevice = try req.content.decode(ZZDevice.self)
        try await zzdevice.save(on: req.db)
        return zzdevice
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let zzdevice = try await ZZDevice.find(req.parameters.get("zzdeviceID"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await zzdevice.delete(on: req.db)
        return .ok
    }
    
    // 根据 udid 更新
    func update(req: Request) async throws -> ZZDevice {
        let zzdeviceUpdateInfo = try req.content.decode(ZZDeviceUpdateInfo.self)
        guard let zzdevice = try await ZZDevice.query(on: req.db).filter(\.$udid == zzdeviceUpdateInfo.udid).first() else {
            throw Abort(.notFound)
        }
        if let name = zzdeviceUpdateInfo.name {
            zzdevice.name = name
        }
        if let owner = zzdeviceUpdateInfo.owner {
            zzdevice.owner = owner
        }
        
        try await zzdevice.update(on: req.db)
        return zzdevice
    }
    
}

