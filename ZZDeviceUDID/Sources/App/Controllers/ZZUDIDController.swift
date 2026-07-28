//
//  XYUDIDController.swift
//  
//
//  Created by SandsLee on 2022/5/29.
//

import Fluent
import Vapor

struct ZZUDIDController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("udid") { udids in
            udids.post("receive", use: receive)
        }
    }
    
    // 接收到UDID回调
    func receive(req: Request) async throws -> Response {
        guard let fromRange = req.body.string?.range(of: "<?xml"),
              let endRange = req.body.string?.range(of: "</plist>"),
              let plistStr = req.body.string?[fromRange.lowerBound ..< endRange.upperBound],
              let plistData = plistStr.data(using: .utf8),
              let plistDict = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String : AnyObject] else {
            throw Abort(.badRequest)
        }
        
        print(plistDict)
        
//        let udidPath = req.application.directory.publicDirectory.appending("udid.xml")
//        if !FileManager.default.fileExists(atPath: udidPath) {
//            FileManager.default.createFile(atPath: udidPath, contents: nil, attributes: nil)
//        }
//        let filehandle = FileHandle(forWritingAtPath: udidPath)
//        do {
//            try filehandle?.seekToEnd()
//            filehandle?.write((req.body.string?.data(using: .utf8))!)
//        } catch {
//            print(error)
//        }
        
        let deviceName = plistDict["DEVICE_NAME"] as? String ?? ""
        let udid = plistDict["UDID"] as? String ?? ""
        let imei = plistDict["IMEI"] as? String ?? ""
        let version = plistDict["VERSION"] as? String ?? ""
        let product = plistDict["PRODUCT"] as? String ?? ""
        let serial = plistDict["SERIAL"] as? String ?? ""
        let macAddress = plistDict["MAC_ADDRESS_EN0"] as? String ?? ""
        
        if !udid.isEmpty {
            if let existing = try await ZZDevice.query(on: req.db).filter(\.$udid == udid).first() {
                existing.name = deviceName
                existing.model = product
                existing.serial = serial
                try await existing.update(on: req.db)
            } else {
                let device = ZZDevice(name: deviceName, model: product, udid: udid, serial: serial)
                try await device.save(on: req.db)
            }
        }
        
        let encode: (String) -> String = { $0.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? $0 }
        let target = "/udid?device_name=\(encode(deviceName))&udid=\(encode(udid))&imei=\(encode(imei))&version=\(encode(version))&product=\(encode(product))&serial=\(encode(serial))&mac_address=\(encode(macAddress))"
        
        return req.redirect(to: target, type: .normal)
    }
    
}

