import Flutter
import UIKit
import AWSS3
import AWSCore

public class SwiftFlutterAmazonS3Plugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_amazon_s3", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterAmazonS3Plugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method.elementsEqual("uploadImageToAmazon")){
            let arguments = call.arguments as? NSDictionary
            let imagePath = arguments!["filePath"] as? String
            
            var imageAmazonUrl = ""
            let S3BucketName = "find-images"
            let fileUrl = NSURL(fileURLWithPath: imagePath!)
            
            let uploadRequest = AWSS3TransferManagerUploadRequest()
            uploadRequest?.bucket = S3BucketName
            uploadRequest?.key = nameGenerator()
            uploadRequest?.contentType = "image/jpeg"
            uploadRequest?.body = fileUrl as URL
            uploadRequest?.acl = .publicReadWrite
            
            let credentialsProvider = AWSCognitoCredentialsProvider(
                regionType: AWSRegionType.USEast1,
                identityPoolId: "us-east-1:ffa41a0d-f4fb-425a-b23b-31c14476f95f")
            let configuration = AWSServiceConfiguration(
                region: AWSRegionType.USEast1,
                credentialsProvider: credentialsProvider)
            AWSServiceManager.default().defaultServiceConfiguration = configuration
            
            AWSS3TransferManager.default().upload(uploadRequest!).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    print("❌ Upload failed (\(error))")
                }
                if task.result != nil {
                    imageAmazonUrl = "https://s3.amazonaws.com/\(S3BucketName)/\(uploadRequest!.key!)"
                    print("✅ Upload successed (\(imageAmazonUrl))")
                } else {
                    print("❌ Unexpected empty result.")
                }
                result(imageAmazonUrl)
                return nil
            }
        }
    }
    
    public func nameGenerator() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "ddMMyyyy"
        let result = formatter.string(from: date)
        return "IMG" + result + String(Int64(date.timeIntervalSince1970 * 1000)) + "jpeg"
    }
}
