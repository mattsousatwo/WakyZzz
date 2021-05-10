//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import UserNotifications

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmCellDelegate, AlarmViewControllerDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let am = AlarmManager()
    let nm = NotificationManager()
    
//    var alarms = [OldAlarm]()
    var editingIndexPath: IndexPath?
    let notificationManager = NotificationManager()
    
    // Add new Alarm
    @IBAction func addButtonPress(_ sender: Any) {
        presentAlarmViewController(alarm: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()

        presentActionAlertController()

    }
    
    func config() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        populateAlarms()
        
        notificationManager.userNotificationCenter.delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
    
    func populateAlarms() {
        
//        var alarm: OldAlarm
//
//        // Weekdays 5am
//        alarm = OldAlarm()
//        alarm.time = 5 * 3600
//        for (day, _) in alarm.repeatDays {
//            if day != .saturday ||
//                day != .sunday {
//                alarm.repeatDays[day] = true
//            }
//        }
////        for i in 1 ... 5 {
////            alarm.repeatDays[i] = true
////        }
//        alarms.append(alarm)
//
//        // Weekend 9am
//        alarm = OldAlarm()
//        alarm.time = 9 * 3600
//        alarm.enabled = false
//        alarm.repeatDays[.sunday] = true
//        alarm.repeatDays[.friday] = true
//        alarms.append(alarm)
        
        
        am.fetchAllAlarms()
        
        sortAlarmsByTime()
    }
    
}

// UITableViewControllerDelegate - Sections, rows, edit actions
extension AlarmsViewController {
    
    // Number of sections in table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows in per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return am.allAlarms.count
    }

    // Cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
//        if let alarm = alarm(at: indexPath) {
        if let alarm = am.alarm(at: indexPath) {
            cell.populate(caption: alarm.caption,
                          subcaption: alarm.subcaption,
                          enabled: alarm.enabled)
        }
        
        return cell
    }
    
    // Swipe Buttons
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.deleteAlarm(at: indexPath)
        }
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexPath) in
            self.editAlarm(at: indexPath)
        }
        return [delete, edit]
    }
    
}

// TableView - Helper Methods - delete, edit, move,
extension AlarmsViewController {
    
    // Delete alarm at row
    func deleteAlarm(at indexPath: IndexPath) {
        tableView.beginUpdates()
        
//        am.allAlarms.remove(at: indexPath.row)
        let alarm = am.allAlarms[indexPath.row]
        alarm.enabled = false
        nm.disable(alarm: alarm)
        
        am.deleteAlarm(uuid: alarm.uuid!)
        
        
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    // Edit alarm at row - present editing view
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: am.alarm(at: indexPath))
    }
    
    // Add alarm at row
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
        am.allAlarms.insert(alarm, at: indexPath.row)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    // Move alarm to row
    func moveAlarm(from originalIndextPath: IndexPath, to targetIndexPath: IndexPath) {
        let alarm = am.allAlarms.remove(at: originalIndextPath.row)
        am.allAlarms.insert(alarm, at: targetIndexPath.row)
        tableView.reloadData()
    }
    
    // Present Alarm Detail View
    func presentAlarmViewController(alarm: Alarm?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let alarmViewController = popupViewController.viewControllers[0] as! AlarmViewController
        alarmViewController.alarm = alarm
        alarmViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
}

// AlarmViewControllerDelegate
extension AlarmsViewController {
    
    // Handle if alarm Detail was dismissed
    func alarmViewControllerDone(alarm newAlarm: Alarm) {
        if let editingIndexPath = editingIndexPath {
            tableView.reloadRows(at: [editingIndexPath], with: .automatic)
        }
        else {
            addAlarm(newAlarm, at: IndexPath(row: am.allAlarms.count, section: 0))
            sortAlarmsByTime()
        }
        editingIndexPath = nil
    }
    
    // Cancel was pressed in AlarmViewController
    func alarmViewControllerCancel() {
        editingIndexPath = nil
    }
    
    // Find Index for alarm based on Alarms.time
    func sortAlarmsByTime() {
        am.allAlarms.sort() { $0.time > $1.time }
        tableView.reloadData()
    }
    
}

// AlarmCellDelegate
extension AlarmsViewController {
    
    // Handle alarm switch toggling
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            if let alarm = am.alarm(at: indexPath) {
                alarm.enabled = enabled
                
                switch enabled {
                case true:
                    nm.schedualeNotifications(for: alarm)
                case false:
                    nm.disable(alarm: alarm)
                }
                
            }
        }
    }
}

// UNUserNotificationCenterDelegate
extension AlarmsViewController {
    
    // Handles Response to Notification In background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        notificationManager.handle(response: response, in: self)
        
        completionHandler()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }
    
}
