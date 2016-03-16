//
//  SharingManager.swift
//  HoldemHands
//
//  Created by Uladzimir Papko on 3/4/16.
//  Copyright © 2016 Visput. All rights reserved.
//

import UIKit
import Foundation
import Social
import FBSDKShareKit

final class SharingManager: NSObject {
    
    enum ErrorCode: Int {
        case SharingAcountNotExist
        case SharingFailed
    }
    
    let errorDomain = "SharingManagerErrorDomain"
    
    var didCompleteShareAction: ((item: SharingItem) -> Void)?
    var didCancelShareAction: ((item: SharingItem) -> Void)?
    var didFailToShareAction: ((item: SharingItem, error: NSError) -> Void)?
    
    private var instagramDocumentController: UIDocumentInteractionController!
    private var facebookSharingItem: SharingItem!
    
    func shareWithInstagram(item: SharingItem, inView view: UIView) {
        Analytics.instagramSharingInitiated()
        
        let instagramUTI = "com.instagram.exclusivegram"
        let instagramCaptionKey = "InstagramCaption"
        let instagramImageFileName = "HoldemHands.igo"
        let instagramURL = NSURL(string: "instagram://app")!

        guard UIApplication.sharedApplication().canOpenURL(instagramURL) else {
            let error = NSError(domain: errorDomain,
                code: ErrorCode.SharingAcountNotExist.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "Unable to locate Instagram app."])
            didFailToShareAction?(item: item, error: error)
            Analytics.instagramSharingFailed(error)
            return
        }
        
        let imageData = UIImageJPEGRepresentation(item.image!, 1.0)
        let imagePath = instagramImageFileName.pathInDocumentsDirectory()
        NSFileManager.defaultManager().createFileAtPath(imagePath, contents: imageData, attributes: nil)
        let imageURL = NSURL(fileURLWithPath: imagePath)
        
        instagramDocumentController = UIDocumentInteractionController(URL: imageURL)
        instagramDocumentController.UTI = instagramUTI
        instagramDocumentController.annotation = [instagramCaptionKey: item.message!]
        instagramDocumentController.presentOpenInMenuFromRect(CGRect(x: 0.0, y: 0.0, width: 0.0, height: 0.0), inView: view, animated: true)

        didCompleteShareAction?(item: item)
        
        Analytics.instagramSharingCompleted()
    }

    func shareWithFacebook(item: SharingItem, inViewController viewController: UIViewController) {
        Analytics.facebookSharingInitiated()
        
        let sharingDialog = FBSDKShareDialog()
        guard sharingDialog.canShow() else {
            let error = NSError(domain: errorDomain,
                code: ErrorCode.SharingAcountNotExist.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "Unable to locate Facebook account."])
            didFailToShareAction?(item: item, error: error)
            Analytics.facebookSharingFailed(error)
            
            return
        }
        
        facebookSharingItem = item
        
        let content = FBSDKShareLinkContent()
        content.contentTitle = item.title
        content.contentDescription = item.message
        content.contentURL = item.linkURL
        content.imageURL = item.imageURL
        
        sharingDialog.shareContent = content
        sharingDialog.mode = .Native
        sharingDialog.fromViewController = viewController
        sharingDialog.delegate = self
        sharingDialog.show()
    }

    func shareWithTwitter(item: SharingItem, inViewController viewController: UIViewController) {
        Analytics.twitterSharingInitiated()
        
        guard SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) else {
            let error = NSError(domain: errorDomain,
                code: ErrorCode.SharingAcountNotExist.rawValue,
                userInfo: [NSLocalizedDescriptionKey: "Unable to locate Twitter account."])
            didFailToShareAction?(item: item, error: error)
            Analytics.twitterSharingFailed(error)
            
            return
        }
        
        let composer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        composer.setInitialText(item.message)
        composer.addURL(item.linkURL)
        composer.addImage(item.image)
        composer.completionHandler = { [unowned self] result in
            if result == .Done {
                self.didCompleteShareAction?(item: item)
                Analytics.twitterSharingCompleted()
            } else {
                self.didCancelShareAction?(item: item)
                Analytics.twitterSharingCanceled()
            }
            
            if viewController.presentedViewController != nil {
                viewController.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        viewController.presentViewController(composer, animated: true, completion: nil)
    }
}

extension SharingManager: FBSDKSharingDelegate {
    
    @objc func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        didCompleteShareAction?(item: facebookSharingItem)
        facebookSharingItem = nil
        Analytics.facebookSharingCompleted()
    }
    
    @objc func sharerDidCancel(sharer: FBSDKSharing!) {
        didCancelShareAction?(item: facebookSharingItem)
        facebookSharingItem = nil
        Analytics.facebookSharingCanceled()
    }
    
    @objc func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        var userInfo: [String: AnyObject] = [NSLocalizedDescriptionKey: "Failed to share with Facebook."]
        if error != nil {
            userInfo[NSUnderlyingErrorKey] = error
        }
        let sharingError = NSError(domain: errorDomain,
            code: ErrorCode.SharingFailed.rawValue,
            userInfo: userInfo)
        
        didFailToShareAction?(item: facebookSharingItem, error: sharingError)
        facebookSharingItem = nil
        Analytics.facebookSharingFailed(error)
    }
}
