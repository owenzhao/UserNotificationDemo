//
//  NotificationViewController.swift
//  NotificationContent
//
//  Created by WANG WEI on 2016/08/05.
//  Copyright © 2016年 OneV's Den. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

struct NotificationPresentItem {
    let url: URL
    let title: String
    let text: String
}

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    var items: [NotificationPresentItem] = []
    
    fileprivate var index: Int = 0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        if let items = content.userInfo["items"] as? [[String: AnyObject]] {
            
            for i in 0..<items.count {
                let item = items[i]
                guard let title = item["title"] as? String, let text = item["text"] as? String else {
                    continue
                }
                
                if i > content.attachments.count - 1 {
                    continue
                }
                
                let url = content.attachments[i].url
                
                let presentItem = NotificationPresentItem(url: url, title: title, text: text)
                self.items.append(presentItem)
            }
        }
        
        updateUI(0)
    }
    
    fileprivate func updateUI(_ index: Int) {
        let item = items[index]
        if item.url.startAccessingSecurityScopedResource() {
            imageView.image = UIImage(contentsOfFile: item.url.path)
            item.url.stopAccessingSecurityScopedResource()
        }
        label.text = item.title
        textView.text = item.text
        
        self.index = index
    }

    func didReceive(_ response: UNNotificationResponse, completionHandler completion: (UNNotificationContentExtensionResponseOption) -> Void) {
        if response.actionIdentifier == "switch" {
            let nextIndex: Int
            if index == 0 {
                nextIndex = 1
            } else {
                nextIndex = 0
            }
            
            updateUI(nextIndex)
            completion(.doNotDismiss)
        } else if response.actionIdentifier == "open" {
            completion(.dismissAndForwardAction)
        } else if response.actionIdentifier == "dismiss" {
            completion(.dismiss)
        } else {
            completion(.dismissAndForwardAction)
        }
    }
}
