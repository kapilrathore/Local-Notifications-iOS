//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Kapil Rathore on 13/06/17.
//  Copyright © 2017 Kapil Rathore. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.datePicker.minimumDate = Date()
        self.datePicker.date = Date().addingTimeInterval(60)
    }

    @IBAction func scheduleNotification(_ sender: Any) {
        
        let duration = 10
        
        var components = Calendar.current.dateComponents([.minute, .hour, .day], from: datePicker.date)
        var newComponent = DateComponents()
        newComponent.day = components.day
        newComponent.hour = components.hour
        newComponent.minute = components.minute
        newComponent.second = 0
        
        for day in 0...duration {
            
            NotificationManager.shared.schdule(identifier: "Day \(day+1)", title: "Notification", body: "Day \(day+1) completed. \(duration-day-1) to go.", dateComponent: newComponent, repeats: false)
            
            let dateToIncrease = Calendar.current.date(from: newComponent)
            if dateToIncrease != nil {
                let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: dateToIncrease!)
                newComponent.day = Calendar.current.component(.day, from: nextDate!)
            }
        }
    }
}

