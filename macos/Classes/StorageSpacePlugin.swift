import Cocoa
import FlutterMacOS

public class StorageSpacePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "storage_space", binaryMessenger: registrar.messenger)
    let instance = StorageSpacePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getLocalStorageStatistic":
        do {
          let attributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
          let storageSpace: [String: Int] = [
            "free": Int(attributes[FileAttributeKey.systemFreeSize] as! Int64),
            "total": Int(attributes[FileAttributeKey.systemSize] as! Int64)
          ]
          result(storageSpace)
        } catch {
          print("Error calculating storage space: \(error.localizedDescription)")
          result(FlutterError(code: "STORAGE_SPACE_ERROR", message: "Failed to calculate storage space", details: error.localizedDescription))
        }
    case "getAppUsedSpace":
        do {
          let appSupportURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
          let appSpecificSupportURL = appSupportURL.appendingPathComponent(Bundle.main.bundleIdentifier!, isDirectory: true)
          let appDataSize = try directorySize(appSpecificSupportURL)

          let cacheURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
          let appSpecificCacheURL = cacheURL.appendingPathComponent(Bundle.main.bundleIdentifier!, isDirectory: true)
          let cacheSize = try directorySize(appSpecificCacheURL)

          let storageSpace: [String: Int] = [
            "appUsedSpace": try directorySize(Bundle.main.bundleURL),
            "userDataSpace": appDataSize,
            "cacheSpace": cacheSize,
          ]

          result(storageSpace)
        } catch {
          print("Error calculating storage space: \(error.localizedDescription)")
          result(FlutterError(code: "STORAGE_SPACE_ERROR", message: "Failed to calculate storage space", details: error.localizedDescription))
        }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func directorySize(_ url: URL) throws -> Int {
          let resourceKeys: [URLResourceKey] = [.fileSizeKey, .totalFileAllocatedSizeKey]
          let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: resourceKeys, options: [], errorHandler: nil)!
          var totalSize = 0
          for case let fileURL as URL in enumerator {
              let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
              totalSize += resourceValues.totalFileAllocatedSize ?? resourceValues.fileSize ?? 0
          }
          return totalSize
      }
}

