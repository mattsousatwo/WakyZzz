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
    let am = AlarmManager()
    let nm = NotificationManager()
    var alarm: Alarm?
    var clearAlarms: Bool = true
    
    var delegate: AlarmViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        config()
        print("AlarmViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if clearAlarms == true {
            clearCreatedAlarm()
        }
        
    }

    
    func config() {        
        if alarm == nil {
            navigationItem.title = AlarmViewTitle.newAlarm.rawValue
            alarm = am.createNewAlarm()
        }
        else {
            navigationItem.title = AlarmViewTitle.editAlarm.rawValue
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        setInitalTime()
        
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(appMovedToBackground),
                       name: UIApplication.willResignActiveNotification,
                       object: nil)
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
//                alarm?.setTime(date: defaultDate)
                am.setTime(alarm: alarm, time: defaultDate)
            }
            else {
                am.setTime(alarm: alarm)
            }
        }

        datePicker.date = (alarm?.alarmTime)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return Alarm.daysOfWeek.count
        return Day.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let path = Alarm.daysOfWeek[indexPath.row]
        let path = Day.allCases[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayOfWeekCell", for: indexPath)
//        cell.textLabel?.text = Alarm.daysOfWeek[indexPath.row].rawValue
        cell.textLabel?.text = path.rawValue
        cell.accessoryType = (alarm?.decodedRepeatingDays[path])! ? .checkmark : .none
        if (alarm?.decodedRepeatingDays[path])! {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Repeat on following weekdays"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let path = Alarm.daysOfWeek[indexPath.row]
        let path = Day.allCases[indexPath.row]
        alarm?.set(path, repeat: true)
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.decodedRepeatingDays[path])! ? .checkmark : .none
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let path = Alarm.daysOfWeek[indexPath.row]
        let path = Day.allCases[indexPath.row]
        alarm?.set(path, repeat: false)
        tableView.cellForRow(at: indexPath)?.accessoryType = (alarm?.decodedRepeatingDays[path])! ? .checkmark : .none
    }
    
    @IBAction func cancelButtonPress(_ sender: Any) {
        clearCreatedAlarm()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPress(_ sender: Any) {
        guard let alarm = alarm else { return }
        clearAlarms = false
        delegate?.alarmViewControllerDone(alarm: alarm)
        delegate?.sortAlarmsByTime()
        nm.disable(alarm: alarm)
        am.update(alarm: alarm, enabled: true)
        nm.schedualeNotifications(for: alarm)
        presentingViewController?.dismiss(animated: true, completion: {
            self.clearAlarms = true
        })
        
    }
    @IBAction func datePickerValueChanged(_ sender: Any) {
        am.setTime(alarm: alarm, time: datePicker.date)
        
    }
    
    /// When the app moves to background dismiss view and delete newly created alarm
    @objc func appMovedToBackground() {
        clearCreatedAlarm()
        self.dismiss(animated: true)
    }

    
    /// Will remove newly created alarm
    func clearCreatedAlarm() {
        guard let alarm = alarm else { return }
        guard let alarmID = alarm.uuid else { return }
        print(#function)
        am.deleteAlarm(uuid: alarmID)

    }
        
    
}
