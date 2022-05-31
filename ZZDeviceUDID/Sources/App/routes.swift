import Fluent
import Vapor

func routes(_ app: Application) throws {
    // 测试首页
    app.get { req -> String in
        return "Hello, Vapor!!!"
    }
    
    // UDID .mobileconfig 下载与展示
    app.get("udid") { req -> EventLoopFuture<View> in
        let device = try req.query.decode(ZZDeviceUDIDQuery.self)
        return req.view.render("index", device)
    }

    // 注册 Controllers
    try app.register(collection: TodoController())
    try app.register(collection: ZZDeviceController())
    try app.register(collection: ZZUDIDController())
}
