//
//  NotificationManager.swift
//  Midterm_Mapkit
//
//  Created by  on 9/29/19.
//  Copyright © 2019 Team Android. All rights reserved.
//  From Tutorial at: https://learnappmaking.com/local-notifications-scheduling-swift/

import UIKit
import UserNotifications


// this LocalNotificationManager class helps manage local notifications.

class NotificationManager: NSObject {

    // defining our own notification type instead of using iOS sdk UNUserNotificationCenter
    struct Notification {
        var id:String
        var title:String
        var datetime:DateComponents
    }
    
    // list of notifications
    var notifications = [Notification]()
    
    // check what notifications are currently scheduled
    func listScheduledNotifications()
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    private func requestAuthorization()
    {
        // get shared notification instance, prompt the user for the permisssion,
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            // check if user granted permission and there wasn't an error
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    
    func schedule()
    {
        // get shared notification instance notification settings
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            // switch off the authorization status given
            switch settings.authorizationStatus {
            case .notDetermined: // haven't ask for permission so request authorization
                self.requestAuthorization()
            case .authorized, .provisional: // we have permission so start scheduling notifications
                self.scheduleNotifications()
            default:
                break // Do nothing
            }
        }
    }
    
    // iterate over notifications in the notification array and schedule them for delivery
    private func scheduleNotifications()
    {
        for notification in notifications
        {
            // set up the notification from our structure to ios SDK
            let content = UNMutableNotificationContent()
            content.title = notification.title
            content.sound = .default()

            // use the current date/time to indicate WHEN the notification should be sent
            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
            
            // uncomment this for using a GPS region as the trigger for the notification!
            // let trigger = UNLocationNotificationTrigger(triggerWithRegion: region, repeats: false)

            // combine the content and the trigger for the notification, give it an id as well
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

            // send the request to the notification center -- check for errors
            UNUserNotificationCenter.current().add(request) { error in

                guard error == nil else { return }

                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
    
}
extension AppDelegate: UNUserNotificationCenterDelegate
{
    // function to handle incoming local notifications. This delegate is called when the app starts from a tapped notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){
        
        let id = response.notification.request.identifier
        print("Received notification with ID = \(id)")

        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        let id = notification.request.identifier
        print("Received notification with ID = \(id)")

        completionHandler([.sound, .alert])
    }
}
