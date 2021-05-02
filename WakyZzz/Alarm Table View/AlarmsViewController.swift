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
    
    var alarms = [Alarm]()
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        
        presentActionAlertController()
        
    }
    
    func config() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        populateAlarms()
        
        notificationManager.userNotificationCenter.delegate = self
        
        notificationManager.requestNotificationAuthorization()
    }
    
    func populateAlarms() {
        
        var alarm: Alarm
        
        // Weekdays 5am
        alarm = Alarm()
        alarm.time = 5 * 3600
        for i in 1 ... 5 {
            alarm.repeatDays[i] = true
        }
        alarms.append(alarm)
        
        // Weekend 9am
        alarm = Alarm()
        alarm.time = 9 * 3600
        alarm.enabled = false
        alarm.repeatDays[0] = true
        alarm.repeatDays[6] = true
        alarms.append(alarm)
        sortAlarmsByTime()
    }
    
    // Number of sections in table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows in per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }

    // Cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath) as! AlarmTableViewCell
        cell.delegate = self
        if let alarm = alarm(at: indexPath) {
            cell.populate(caption: alarm.caption, subcaption: alarm.repeating, enabled: alarm.enabled)
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
    
    // Get alarm for row
    func alarm(at indexPath: IndexPath) -> Alarm? {
        return indexPath.row < alarms.count ? alarms[indexPath.row] : nil
    }
    
    // Delete alarm at row
    func deleteAlarm(at indexPath: IndexPath) {
        tableView.beginUpdates()
        
        alarms.remove(at: indexPath.row)
        let alarm = alarms[indexPath.row]
        alarm.enabled = false
        alarm.disableNotifications()
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    // Edit alarm at row - present editing view
    func editAlarm(at indexPath: IndexPath) {
        editingIndexPath = indexPath
        presentAlarmViewController(alarm: alarm(at: indexPath))
    }
    
    // Add alarm at row
    func addAlarm(_ alarm: Alarm, at indexPath: IndexPath) {
        tableView.beginUpdates()
        alarms.insert(alarm, at: indexPath.row)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    // Move alarm to row
    func moveAlarm(from originalIndextPath: IndexPath, to targetIndexPath: IndexPath) {
        let alarm = alarms.remove(at: originalIndextPath.row)
        alarms.insert(alarm, at: targetIndexPath.row)
        tableView.reloadData()
    }
    
    func alarmCell(_ cell: AlarmTableViewCell, enabledChanged enabled: Bool) {
        if let indexPath = tableView.indexPath(for: cell) {
            if let alarm = self.alarm(at: indexPath) {
                alarm.enabled = enabled
                
                switch enabled {
                case true:
                    alarm.setNotifications()
                case false:
                    alarm.disableNotifications()
                }
                
            }
        }
    }
    
    func presentAlarmViewController(alarm: Alarm?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let popupViewController = storyboard.instantiateViewController(withIdentifier: "DetailNavigationController") as! UINavigationController
        let alarmViewController = popupViewController.viewControllers[0] as! AlarmViewController
        alarmViewController.alarm = alarm
        alarmViewController.delegate = self
        present(popupViewController, animated: true, completion: nil)
    }
    
    func alarmViewControllerDone(alarm newAlarm: Alarm) {
        if let editingIndexPath = editingIndexPath {
            tableView.reloadRows(at: [editingIndexPath], with: .automatic)
        }
        else {
            addAlarm(newAlarm, at: IndexPath(row: alarms.count, section: 0))
            sortAlarmsByTime()
        }
        editingIndexPath = nil
    }
    
    // Find Index for alarm based on Alarms.time
    func sortAlarmsByTime() {
        alarms.sort() { $0.time > $1.time }
        tableView.reloadData()
    }
    
    func alarmViewControllerCancel() {  
        editingIndexPath = nil
    }
}

// UNUserNotificationCenterDelegate
extension AlarmsViewController {
    
    // Handles Response to Notification In background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        notificationManager.handle(response: response, alarms: alarms)
        
        completionHandler()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge, .sound])
    }
    
}
