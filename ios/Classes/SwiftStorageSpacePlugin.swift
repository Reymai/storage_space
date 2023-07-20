import Flutter
import Foundation
import UIKit

public class SwiftStorageSpacePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "storage_space", binaryMessenger: registrar.messenger())
        let instance = SwiftStorageSpacePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // this method should return map with free and total space of the device
        if call.method == "getLocalStorageStatistic" {
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
        }

        // this method should return how much space is used by the appUsedSpace, userDataSpace and cacheSpace
        if call.method == "getAppUsedSpace" {
            do {
                let appExecutableURL = Bundle.main.executableURL!
                let appExecutableSize = try FileManager.default.attributesOfItem(atPath: appExecutableURL.path)[.size] as! Int
                let appBundleSize = try directorySize(Bundle.main.bundleURL)

                let appDataURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let appDataSize = try directorySize(appDataURL)

                let appDocumentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let appDocumentsSize = try directorySize(appDocumentsURL)

                let cacheURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let cacheSize = try directorySize(cacheURL)

                let libraryDirectoryUrl = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let libraryDirectorySize = try directorySize(libraryDirectoryUrl)

                let storageSpace: [String: Int] = [
                    "appUsedSpace": appBundleSize,
                    "userDataSpace": libraryDirectorySize,
                    "cacheSpace":  appDocumentsSize + cacheSize,
                ]

                print("appBundleSize: \(appBundleSize)")
                print("appDataSize: \(appDataSize)")
                print("cacheSize: \(cacheSize)")
                print("libraryDirectorySize: \(libraryDirectorySize)")

                result(storageSpace)
            } catch {
                print("Error calculating storage space: \(error.localizedDescription)")
                result(FlutterError(code: "STORAGE_SPACE_ERROR", message: "Failed to calculate storage space", details: error.localizedDescription))
            }
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
