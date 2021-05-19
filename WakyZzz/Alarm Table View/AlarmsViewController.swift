//
//  AlarmsViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import UIKit
import UserNotifications
import Contacts

class AlarmsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AlarmCellDelegate, AlarmViewControllerDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let am = AlarmManager()
    let nm = NotificationManager()
    let ac = ActionControl()
    var editingIndexPath: IndexPath?
    
    
    
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

//        let contactControl = ContactControl()
//
//        contactControl.requestAccess(in: self) { (numbersArray) in
////            if let first = numbersArray.first {
////                self.randomNumber = first
////            }
//        }

        ac.configure(self)
        
        
        populateAlarms()
        
        nm.userNotificationCenter.delegate = self
        nm.clearBadgeNumbers()
        
    }
    
    func populateAlarms() {

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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.deleteAlarm(at: indexPath)
            completion(true)
        }
        let edit = UIContextualAction(style: .normal, title: "Edit") { (action, view, completion) in
            self.editAlarm(at: indexPath)
            completion(true)
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [delete, edit])
        
        swipeActions.performsFirstActionWithFullSwipe = true
        
        return swipeActions
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
        
        
        nm.handle(response: response, in: self)
        
        completionHandler()
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        nm.handleForeground(notification: notification, in: self)
        
        completionHandler([.alert, .badge, .sound])
    }
    
}
