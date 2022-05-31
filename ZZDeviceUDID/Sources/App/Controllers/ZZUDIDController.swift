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
        
        let deviceName = plistDict["DEVICE_NAME"] as? String
        let udid = plistDict["UDID"] as? String
        let imei = plistDict["IMEI"] as? String
        let version = plistDict["VERSION"] as? String
        let product = plistDict["PRODUCT"] as? String
        let serial = plistDict["SERIAL"] as? String
        let macAddress = plistDict["MAC_ADDRESS_EN0"] as? String
        let target = "/udid?device_name=\(deviceName ?? "")&udid=\(udid ?? "")&imei=\(imei ?? "")&version=\(version ?? "")&product=\(product ?? "")&serial=\(serial ?? "")&mac_address=\(macAddress ?? "")"
        
        return req.redirect(to: target, type: .permanent)
    }
    
}

