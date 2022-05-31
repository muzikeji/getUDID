//
//  XYDevice.swift
//  
//
//  Created by SandsLee on 2022/5/29.
//

import Fluent
import Vapor

// 更新参数
struct ZZDeviceUpdateInfo: Content {
    var udid: String
    var name: String?
    var owner: String?
}

// UDID query参数model
struct ZZDeviceUDIDQuery: Content {
    var device_name: String?
    var udid: String?
    var imei: String?
    var version: String?
    var product: String?
    var serial: String?
    var mac_address: String?
}

// 数据库表名定义
let ZZ_DEVICE_SCHEMA = "zz_devices"

final class ZZDevice: Model, Content {
    static let schema = ZZ_DEVICE_SCHEMA
    
    @ID(key: .id)
    var id: UUID?
    
    // 设备名称
    @Field(key: "name")
    var name: String?
    
    // 设备型号
    @Field(key: "model")
    var model: String
    
    // 设备UDID
    @Field(key: "udid")
    var udid: String
    
    // 设备SERIAL
    @Field(key: "serial")
    var serial: String
    
    // 设备使用人
    @Field(key: "owner")
    var owner: String?
    
    // When this Planet was created.
    @Timestamp(key: "created_at", on: .create, format: .iso8601)
    var createdAt: Date?
    
    // When this Planet was last updated.
    @Timestamp(key: "updated_at", on: .update, format: .iso8601)
    var updatedAt: Date?

    init() { }

    init(id: UUID? = nil, name: String?, model: String, udid: String, serial: String, owner: String? = nil) {
        self.id = id
        self.name = name
        self.model = model
        self.udid = udid
        self.serial = serial
        self.owner = owner
    }
}
