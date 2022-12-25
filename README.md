# iOSUDIDBySafari
iOS设备通过Safari浏览器获取设备UDID（设备唯一标识符）

## 0 ｜ 科普

### UDID

UDID(Unique Device Identifier)，设备唯一标示符，是iOS设备的一个唯一识别码。每台iOS设备都有一个独一无二的编码，UDID其实也是在设备量产的时候，生成随机的UUID写入到iOS设备硬件或者某一块存储器中，所以变成了固定的完全不会改变的一个标识符，用来区别每一个唯一的iOS设备，包括iPhones, iPads 以及 iPod touches。

随着苹果对App内通过代码的方式获取UDID封杀的越来越严格，私有API已经获取不到UDID、SERIAL等信息，继而出现了使用钥匙串配合UUID等等方法变相实现。

### MDM

iOS系统支持企业级的MDM（Mobile Device Managment），也就是所谓的移动设备管理，目的就是让企业能够方便的管理iPhone、iPad等移动设备。具体做法是通过在系统中安装配置文件（Profiles）的方式实现各种功能，设备管理，设备安全，获取设备信息，设备配置，备份和恢复等几类功能，可以根据不同应用场景实现很多具体小功能。

### Over-the-Air Profile Delivery and Configuration

一个配置的Profile描述文件允许你基于iOS设备发布配置信息，如果你需要配置大量设备的邮件设置，网络设置，或者设备的证书，那么通过配置文件可以轻松完成。

iOS的Profile描述文件包含很多可以指定的设置，包括：

* Passcode Policies 密码策略
* Restrictions on device features (disabling the camera, for example) 设备特性限制（例如：禁用摄像头）
* Wi-Fi Settings WIFI设置
* VPN Settings VPN设置
* Email Server Settings 邮件服务器设置
* Exchange Settings Exchange设置
* LDAP directory service settings LDAP目录服务设置
* CalDAV calendar service settings CalDAV日历服务设置
* Web clips 桌面快捷方式
* Credentials and keys 凭证和密钥
* Advanced cellular network settings 高级蜂窝网络设置


## 1 ｜ 通过Safari浏览器获取iOS设备UDID

苹果公司允许开发者通过iOS设备和Web服务器之间的某个操作（其实就是MDM的获取设备信息功能），来获得iOS设备的UDID、SERIAL等，具体可以参考：[木子科技｜一步快速获取 iOS 设备的 UDID](https://muvip.cn/udid) 。获取步骤简要概述：

1. 在你的Web服务器上创建一个.mobileconfig的XML格式的描述文件；
2. 用户在所有操作之前必须先通过某个点击操作完成.mobileconfig描述文件的下载和安装；
3. 服务器需要的数据，比如：UDID、SERIAL，需要在.mobileconfig描述文件中配置好，以及 **服务器接收数据的URL** 地址；
4. 当用户设备完成数据的收集后，返回提示给客户端用户；

![ota_developer_flow_chart-c](https://raw.githubusercontent.com/lishuzhi1121/oss/master/uPic/2022/05/31-152918-ota_developer_flow_chart.jpeg)

## 2 ｜ .mobileconfig 文件

本文主要讲如何获得UDID，其实还可以获取更多信息

> 经过测试，可以支持的有：
> 
> DEVICE_NAME：设备名称（可能获取不到了，测试时未获取到）
> 
> UDID：设备唯一标识符
> 
> IMEI：移动设备识别码（仅当有SIM卡时才有值）
> 
> ICCID：集成电路卡识别码即SIM卡卡号（可能获取不到了，测试时未获取到）
> 
> VERSION：版本号
> 
> PRODUCT：设备型号
> 
> SERIAL：设备序列号
> 
> MAC_ADDRESS_EN0：网卡物理地址（MAC地址，可能获取不到了，测试时未获取到）

以下是一个获得UDID示例.mobileconfig配置文件内容示例：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>PayloadContent</key>
        <dict>
            <key>URL</key>
            <string>http://10.0.25.180:4443/udid/receive</string> <!--接收数据的地址-->
            <key>DeviceAttributes</key>
            <array>
                <string>DEVICE_NAME</string>
                <string>UDID</string>
                <string>IMEI</string>
                <string>ICCID</string>
                <string>VERSION</string>
                <string>PRODUCT</string>
                <string>SERIAL</string>
                <string>MAC_ADDRESS_EN0</string>
            </array>
        </dict>
        <key>PayloadOrganization</key>
        <string>dev.xxxxxx.org</string>  <!--组织名称-->
        <key>PayloadDisplayName</key>
        <string>获取设备 UDID</string>  <!--安装配置文件时显示的标题-->
        <key>PayloadVersion</key>
        <integer>1</integer>
        <key>PayloadUUID</key>
        <string>3C4DC7D2-E475-3375-489C-0BB8D737A653</string>  <!--自己随机填写的唯一字符串-->
        <key>PayloadIdentifier</key>
        <string>com.xxxxxx.profile-service</string>  <!--类似Bundle ID-->
        <key>PayloadDescription</key>
        <string>本文件仅用来获取设备 ID</string>   <!--配置文件描述信息-->
        <key>PayloadType</key>
        <string>Profile Service</string>   <!--固定值,不要改-->
    </dict>
</plist>
```

使用以上示例需要自行修改的有：

* URL：修改为你自己的用于接收数据的url接口地址
* PayloadOrganization：修改为你自己定义的组织名称
* PayloadUUID：修改为自行生成的唯一字符串，建议使用UUID
* PayloadIdentifier：修改为你自己的唯一的字符串，建议使用Bundle ID

#### Tips

> **很多网上教程说这里接收数据的URL一定要用https的地址，否则会报错，但是经过实测发现其实http的就行，并不会报错。**

## 3 ｜ .moblieconfig 签名

经过上面创建好的.mobileconfig文件，如果用户直接下载到手机上，进行安装时则会有非常醒目的红色 **未签名** 提示，如下图：

![mobileconfig_unsign-c](https://raw.githubusercontent.com/lishuzhi1121/oss/master/uPic/2022/05/31-160649-mobileconfig_unsign.PNG)

给.mobileconfig文件签名有很多种方式，具体可以参考：[为iOS的mobileconfig文件进行签名](http://www.skyfox.org/ios-mobileconfig-sign.html)

下面介绍一个iOS开发者最简单的签名方式：

首先，打开终端并进入你创建的未签名的.mobileconfig文件目录里，执行以下命令，找出电脑中可以用于签名的证书：

```sh
security find-identity -p codesigning -v
```

执行结果如下图：

![security-find-identity-c](https://raw.githubusercontent.com/lishuzhi1121/oss/master/uPic/2022/05/31-161835-IpEt5J.png)

选择一个 **iPhone Distribution** 证书，例如上图中的最后一个，并复制其名称(就是"iPhone Distribution: XXXXXXX Inc."这一串)，然后执行以下命令进行签名：

```sh
security cms -S -N "你的证书名称" -i udidUnsigned.mobileconfig -o udidSigned.mobileconfig
```

> 这里假设你的未签名文件名为 udidUnsigned.mobileconfig，签名后的文件名为 udidSigned.mobileconfig

执行完成后即可得到签名的.mobileconfig文件。再提供给用户下载安装后即可看到心情愉悦的绿色 **已验证** 提示了。

![mobile_signed-c](https://raw.githubusercontent.com/lishuzhi1121/oss/master/uPic/2022/05/31-163314-mobile_signed.PNG)


## 4 ｜ 页面展示和接口服务

准备工作完成之后就需要提供一个网页，让用户在Safari里打开网页并下载.mobileconfig文件，这里就有很多技术选择了，PHP、Java、Python等等，作为一个iOS开发者，下面将使用Swift [Vapor框架](https://vapor.codes/) 搭建服务。

Vapor框架的 [安装](https://docs.vapor.codes/install/macos/) 和 [Hello，World！](https://docs.vapor.codes/getting-started/hello-world/) 大家就自行学习了，创建vapor项目时选择使用Fluent和Leaf，如下图：

![vapor-new-c](https://raw.githubusercontent.com/lishuzhi1121/oss/master/uPic/2022/05/31-165412-3wN34Z.png)

### 项目设置

Vapor项目创建完成后，需要进行几个设置：

* 修改工作目录为工程目录
  打开 **“Edit Scheme”** ，转到 **“Options”** 选项卡，将 **"Working Directory"** 勾选上 **“Use custom working directory:”** 并选择为工程目录
  
  ![vapor-working-directory-c](https://raw.githubusercontent.com/lishuzhi1121/oss/master/uPic/2022/05/31-171604-kAV55V.png)
  
* 打开文件访问中间件，并将.mobileconfig文件放到 **/Public** 目录里

  ![open-file-middleware-c](https://raw.githubusercontent.com/lishuzhi1121/oss/master/uPic/2022/05/31-171828-qcwq09.png)

  > 开启文件服务中间件之后，放到Public目录里的文件就可以被直接访问，这里主要用于.mobileconfig文件的下载服务。

* 设置服务启动的host和port
  
  ![vapor-host-port-c](https://raw.githubusercontent.com/lishuzhi1121/oss/master/uPic/2022/05/31-175908-KFEGVO.png)
  
  > hostname设置为"0.0.0.0"以便局域网内其他设备都能访问到服务。


### 下载展示页面

写一个用于让用户点击下载mobileconfig文件和展示接收到UDID等数据的页面，这个比较简单，直接写到Leaf文件里，详情请参考代码，index.leaf文件内容示例如下：

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">

  <title>GET UDID</title>
  <script src="https://upcdn.b0.upaiyun.com/libs/jquery/jquery-2.0.2.min.js">
      
  </script>
</head>

<body>
  <h1>点击下方获取UDID按钮以获取设备UDID</h1>
  
  <h3>DEVICE_NAME: #(device_name)</h3>
  <h3>UDID: #(udid)</h3>
  <h3>IMEI: #(imei)</h3>
  <h3>VERSION: #(version)</h3>
  <h3>SERIAL: #(serial)</h3>
  <h3>PRODUCT: #(product)</h3>
  <h3>MAC_ADDRESS_EN0: #(mac_address)</h3>
  
  <div class="title-box">
      <p><button class="btn-u btn-u-lg" style="border-radius: 4px;" onclick="getUDID();" id="getUDID">获取 UDID</button></p>
  </div>
</body>
<script type="text/javascript">
    $(document).ready(function() {
        #if(udid && serial):
            console.log("#(udid)")
            console.log("#(serial)")
        #else:
            console.log("No udid and serial was provided.")
        #endif
    });

    function getUDID() {
        window.location.href = "/mobileconfig/udidSigned.mobileconfig";
        setTimeout(function() {
            window.location.href = "http://10.0.25.180:4443/mobileprovision/embedded.mobileprovision";
        }, 2000);
    }
</script>
</html>
```

#### Tips

> 1. 上面的 getUDID 方法里，先去下载了我们准备好的.mobileconfig文件，然后2秒钟之后又下载了一个叫.mobileprovision的文件，没错！这个就是我们iOS开发平时用的描述文件，下载这个.mobileprovision文件的目的是为了让用户能够自动跳转到iOS系统的设置里去安装.mobileconfig配置文件。
> 2. mobileprovision文件可以从苹果开发者后台去下载，也可以从打包出来的ipa文件里获取（将ipa文件后缀改为zip，然后解压缩之后得到Payload文件夹，打开之后看到App名称，右键-显示包内容，即可看到embedded.mobileprovision文件了）。


### 数据接口

接口路由随意，我这里是/udid/receive，请求方式POST，接收到的数据可以理解成是一个xml文件格式，可能由于做了签名，所以存在一些乱码，但是主体xml数据结构是正常的。接收到的数据示例（已去除乱码部分）如下：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>IMEI</key>
	<string>35 873909 214899 9</string>
	<key>PRODUCT</key>
	<string>iPhone11,6</string>
	<key>SERIAL</key>
	<string>F2LXTKP4KPJ3</string>
	<key>UDID</key>
	<string>00008020-00112CE90101002E</string>
	<key>VERSION</key>
	<string>19E258</string>
</dict>
</plist>
```

数据接收服务接口代码如下：

```swift
//
//  XYUDIDController.swift
//  
//
//  Created by SandsLee on 2022/5/29.
//

import Fluent
import Vapor

struct XYUDIDController: RouteCollection {
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
        
        let deviceName = plistDict["DEVICE_NAME"] as? String
        let udid = plistDict["UDID"] as? String
        let imei = plistDict["IMEI"] as? String
        let version = plistDict["VERSION"] as? String
        let product = plistDict["PRODUCT"] as? String
        let serial = plistDict["SERIAL"] as? String
        let macAddress = plistDict["MAC_ADDRESS_EN0"] as? String
        let target = "/udid?device_name=\(deviceName ?? "")&udid=\(udid ?? "")&imei=\(imei ?? "")&version=\(version ?? "")&product=\(product ?? "")&serial=\(serial ?? "")&mac_address=\(macAddress ?? "")"
        // 注意，这里一定要响应一个301跳转，跳转的页面路由复用了上面下载的页面
        return req.redirect(to: target, type: .permanent)
    }
    
}
```

核心代码基本上就是这些，其他细节详见代码仓库。


## 5 ｜ 运行测试

将电脑上Vapor服务跑起来之后，手机访问页面并下载配置文件安装后看效果！

![udid_result-c](https://raw.githubusercontent.com/lishuzhi1121/oss/master/uPic/2022/05/31-180656-udid_result.PNG)

end