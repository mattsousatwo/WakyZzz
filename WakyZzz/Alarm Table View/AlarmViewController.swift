//
//  AlarmViewController.swift
//  WakyZzz
//
//  Created by Olga Volkova on 2018-05-30.
//  Copyright © 2018 Olga Volkova OC. All rights reserved.
//

import Foundation
import UIKit

protocol AlarmViewControllerDelegate {
    func alarmViewControllerDone(alarm: Alarm)
    func alarmViewControllerCancel()
    func sortAlarmsByTime()
}

enum AlarmViewTitle: String {
    case newAlarm = "New Alarm"
    case editAlarm = "Edit Alarm"
}

class AlarmViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    var alarm: Alarm?
    
    var delegate: AlarmViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()
        print("AlarmViewController")
    }
    
    func config() {        
        if alarm == nil {
            navigationItem.title = AlarmViewTitle.newAlarm.rawValue
            alarm = Alarm()
        }
        else {
            navigationItem.title = AlarmViewTitle.editAlarm.rawValue
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        setInitalTime()
    }
    
    // Set date picker time
    func setInitalTime() {
        if navigationItem.title == AlarmViewTitle.newAlarm.rawValue {
            let today = Date()
            let calendar = NSCalendar.current
            let day = calendar.component(.day, from: today)
            let month = calendar.component(.month, from: today)
            let year = calendar.component(.year, from: today)
            
            var dateComponents = DateComponents()
            dateComponents.timeZone = TimeZone(abbreviation: "EST")
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = day
            dateComponents.hour = 8
            dateComponents.minute = 0
            
            if let defaultDate = calendar.date(from: dateComponents) {
                alarm?.setTime(date: defaultDate)
            }
            else {
                alarm?.setTime(date: Date())
            }
        }

        datePicker.date = (alarm?.alarmDate)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Alarm.daysOfWeek.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayOfWeekCell", for: indexPath)
        cell.textLabel?.text = Alarm.daysOfWeek[indexPath.row]
        cell.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
        if (alarm?.repeatDays[indexPath.row])! {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Repeat on following weekdays"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = true
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        alarm?.repeatDays[indexPath.row] = false
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.repeatDays[indexPath.row])! ? .checkmark : .none
    }
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        delegate?.alarmViewControllerDone(alarm: alarm!)
        delegate?.sortAlarmsByTime()
        alarm?.disableNotifications()
        alarm?.enabled = true 
        alarm?.setNotifications()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func datePickerValueChanged(_ sender: Any) {
        alarm?.setTime(date: datePicker.date)
    }
    
}
