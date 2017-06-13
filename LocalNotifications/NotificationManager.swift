//
//  NotificationManager.swift
//  LocalNotifications
//
//  Created by Kapil Rathore on 13/06/17.
//  Copyright © 2017 Kapil Rathore. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications


class NotificationManager: NSObject {
    
    //Shared instance
    static let shared:NotificationManager = {
        return NotificationManager()
    }()
    
    //Let's keep tracking the status of the authorization
    var isAuthorized = false
    
    //1- We need to authorize the app before we do anything. When you ask for authorization an alert will show to user to either approve or not
    
    //With this function we can ask for the authorization from anywhere in our app
    //But in our case we will be calling this method once our app get launched
    
    func requestAuthorization(){
        
        UNUserNotificationCenter.current().delegate = self
        let options:UNAuthorizationOptions = [.badge,.alert,.sound]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted:Bool, error:Error?) in
            
            if granted {
                print("Notification Authorized")
                self.isAuthorized = true
                
            } else {
                self.isAuthorized = false
                print("Notification Not Authorized")
            }
        }
        
        let takenAction = UNNotificationAction(identifier: "takenAction", title: "Medicine Taken", options: [.foreground])
        let snoozeAction = UNNotificationAction(identifier: "snoozeAction", title: "Snooz Reminder", options: [.destructive])
        let missAction = UNNotificationAction(identifier: "missAction", title: "Medicine Missed", options: [.destructive])
        
        let notificationCategory = UNNotificationCategory(identifier: "notificationCategory", actions: [takenAction, snoozeAction, missAction], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([notificationCategory])
        
        let generalCategory = UNNotificationCategory(identifier: "GENERAL",
                                                     actions: [],
                                                     intentIdentifiers: [],
                                                     options: .customDismissAction)
        
        // Register the category.
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([generalCategory])
    }
    
    //Now let's implement our schdule function
    
    func schdule(identifier: String, title: String, body: String, dateComponent: DateComponents, repeats:Bool) {
        //Since we only have one notification in our App that will be schduled so it's good if we cancel all first before we set new one
        //        cancelAllNotifcations()
        
        //1- Create Content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = ["testInfo":"hello"] // Here you can attache extra info with content
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: repeats)
        
        //3- Create the request so we can add it to the NotificationCenter
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        //4- Add the request
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            if error == nil {
                //Let's format our date so it matches our device time
                print(repeats, "Notification Schduled",trigger.nextTriggerDate()?.formattedDate ?? "Date nil")
            } else {
                print("Error schduling a notification",error?.localizedDescription ?? "")
            }
        }
    }
    
    //Now let's implement our get pending notifcation function
    func getAllPendingNotifications(completion:@escaping ([UNNotificationRequest]?)->Void){
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests:[UNNotificationRequest]) in
            print(requests.count)
            return completion(requests)
        }
    }
    
    //We need to cancel the notifcation also sometime
    func cancelAllNotifcations(){
        getAllPendingNotifications { (requests:[UNNotificationRequest]?) in
            if let requestsIds = requests{
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestsIds.map{$0.identifier})
            }
        }
    }
}

//Now let's impelement the delegate methods
extension NotificationManager:UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Local Notifcation Received while app is open",notification.request.content)
        
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Did tap on the notification",response.notification.request.content)
        
        if response.actionIdentifier == "takenAction" {
            DispatchQueue.main.async(execute: {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewView")
            })
        }
        
        if response.actionIdentifier == "snoozeAction" {
            // snooze the reminder notification after 2 mins or so.
            
            //            response.notification.request.trigger
        }
        
        if response.actionIdentifier == "missAction" {
            // mark the medication as missed.
        }
        
        // Also we should call the completionHandler as soon as we're done from this call
        completionHandler()
    }
}

extension Date{
    var formattedDate:String{
        
        let format = DateFormatter()
        format.timeZone = TimeZone.current
        format.timeStyle = .medium
        format.dateStyle = .medium
        
        return format.string(from: self)
    }
}
