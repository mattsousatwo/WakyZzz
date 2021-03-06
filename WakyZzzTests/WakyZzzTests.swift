//
//  WakyZzzTests.swift
//  WakyZzzTests
//
//  Created by Matthew Sousa on 4/26/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import XCTest
@testable import WakyZzz

class LocalNotificationTests: XCTestCase {
    
    let alarm = OldAlarm()
    let formatter = DateFormatter()
    let calendar = NSCalendar.current

    
    
    func testGettingAllDates() {
        
        var allDates: [Date] = []
        let today = Date()
        let currentYear = calendar.component(.year, from: today)
        
        guard var nextDate = calendar.nextDate(after: today, matching: .init(weekday: 1), matchingPolicy: .nextTime) else { return }
        let nextDateYear = calendar.component(.year, from: nextDate)
        
        
        repeat {
            let nextDateMatchingSpcecifications = nextDate
            allDates.append(nextDateMatchingSpcecifications)
            if let newDate = calendar.nextDate(after: nextDateMatchingSpcecifications, matching: .init(weekday: 1), matchingPolicy: .nextTime) {
                nextDate = newDate
            }
        } while nextDateYear == currentYear

        print("\n\n - testGettingAllDates()" )
        
        for date in allDates {
            print("\n ~ \(formatter.string(from: date))\n")
        }
        print(" \n - \n\n")
//        print("testGettingAllDates() - \n currentDate: \(formatter.string(from: Date())),\n currentDate: \(formatter.string(from: nextMonday!))")
        
        
    }
    
    
    func testAddingWeeksTodate() {
        formatter.dateStyle = .medium
        var allDates: [Date] = []
        var monWeekday = DateComponents()
        monWeekday.weekOfYear = 1
        
        
        
        // Compare dates years
        func yearsMatch(_ one: Date, _ two: Date) -> Bool {
            let yearOne = calendar.component(.year, from: one)
            let yearTwo = calendar.component(.year, from: two)
            switch yearOne == yearTwo {
            case true:
                return true
            case false:
                return false
            }
        }
        
        // return nextDate with component
        func nextDate(from date: Date, component: DateComponents) -> Date? {
            return calendar.date(byAdding: component, to: date)
            
        }
        
        
        let today = Date()
        
        var newDate = Date()
        
        while yearsMatch(today, newDate) {
            let lastDate = newDate
            allDates.append(lastDate)
            newDate = nextDate(from: newDate, component: monWeekday)!
            
        }
        
        print("\n\n - testAddingWeeksToDate()" )
        
        for date in allDates {
            print("\n ~ \(formatter.string(from: date))\n")
        }
        print(" \n - \n\n")
        
    }
    
    func testIfDateIsInPast() {
        var dayOne = DateComponents()
        dayOne.month = 1
        dayOne.day = 1
        dayOne.year = 1
        
        var dayTwo = DateComponents()
        dayTwo.month = 1
        dayTwo.day = 1
        dayTwo.year = 2
        
        let firstDay = calendar.date(from: dayOne)!
        let secondDay = calendar.date(from: dayTwo)!
        
        formatter.dateStyle = .medium
        
        switch firstDay > secondDay {
        case true:
            print("\(formatter.string(from: firstDay)) > \(formatter.string(from:secondDay))\n")
            XCTAssertTrue(firstDay > secondDay)
        case false:
            print("\(formatter.string(from: firstDay)) < \(formatter.string(from:secondDay))\n")
            XCTAssertTrue(firstDay < secondDay)
        }
        
        
        XCTAssertTrue(firstDay < secondDay)
    }
    
}

class AlarmManagerTests: XCTestCase {
    
    let am = AlarmManager()
    let testID = "123-TEST-ALARM-456"
    
    // Create new alarm test
    func testAlarmCreation() {
        let _ = am.createNewAlarm(uuid: testID)
        XCTAssert(am.allAlarms.count != 0 )
    }
    
    // Fetch all alarms test
    func testFetchAllAlarms() {
        am.fetchAllAlarms()
        XCTAssert(am.allAlarms.count != 0)
    }
    
    // Fetch Specific Alarm test
    func testFetchSpecificAlarm() {
        let alarm = am.fetchAlarm(with: testID)
        XCTAssert(alarm != nil, "Alarm == nil")
    }
    
    // Test Delete all alarms
    func testDeleteAll() {
        am.fetchAllAlarms()
        am.deleteAllAlarms()
        am.fetchAllAlarms()
        XCTAssert(am.allAlarms.count == 0, "Alams count: \(am.allAlarms.count)")
    }
    
    // Test to delete Specific alarm
    func testDeleteSpecificAlarm() {
        am.fetchAllAlarms()
        am.deleteAlarm(uuid: testID)
        am.fetchAllAlarms()
        
        let alarmExists = am.allAlarms.contains(where: { $0.uuid == testID })
        
        XCTAssert(alarmExists == false)
    }
    
    // Test getting alarm Time
    func testAlarmTime() {
        let id = "Patriots-Pink-SeaHorse"
        var alarm: Alarm?

        
        let fetchedAlarm = am.fetchAlarm(with: id)
        if fetchedAlarm != nil {
            alarm = fetchedAlarm
        } else {
            alarm = am.createNewAlarm(uuid: id, time: Date())
        }
        
        XCTAssert(alarm?.alarmTime != nil)
    }
    
    func testDateFormatting() {
        var components = DateComponents()
        components.year = 1
        components.month = 1
        components.day = 1
        components.hour = 5
        components.minute = 20
        
        let dateFromComponents = am.calendar.date(from: components)!
        let formatted = am.format(date: dateFromComponents)
        let recreated = am.format(string: formatted)
        
        
        XCTAssert(recreated == dateFromComponents)
    }
    
}


class ActionContactTests: XCTestCase {
    
    let manager = ActionContactManager()
    let testID = "ACTION_CONTACT_TEST"
    var deletionID: String {
        return (ACMKey.prefix.rawValue + testID)
    }
    
    func testCreation() {
        
        manager.createNewActionContact(contactInfo: "myEmailAddress@mail.com", uuid: testID, type: .email, status: .inactive)
        manager.fetchAllActionContacts()
        
        XCTAssertTrue(manager.savedActionContacts.count != 0 )
    }
    
    func testDeletion() {
        manager.fetchAllActionContacts()
        manager.deleteActionContact(uuid: deletionID)
        manager.savedActionContacts.removeAll(where: { $0.uuid == deletionID })
        manager.fetchAllActionContacts()
        
        let contactInSavedActionContacts = manager.savedActionContacts.first(where: { $0.uuid == deletionID })
        XCTAssertTrue(contactInSavedActionContacts == nil, "Failed because savedActionContacts containts contact with uuid: \(deletionID)" )
    }
    
    
    func testDeleteAll() {
        manager.fetchAllActionContacts()
        manager.deleteAllActionContacts()
        manager.savedActionContacts.removeAll()
        
        manager.fetchAllActionContacts()
        XCTAssertTrue(manager.savedActionContacts.count == 0, "Failed because savedActionContacts.count = \(manager.savedActionContacts.count)" )
    }
    
    func testConvertPhoneNumber() {
        let originalPhoneNumber = "(617)-832-9213"
        
        let control = 6178329213
        
        guard let phoneNumber = originalPhoneNumber.convertToPhoneNumber() else { return }
            
        XCTAssertTrue(phoneNumber == control)
    }
    
    
    func testGettingActiveActionContactsWithStatus() {
        var otherActions = 0
        for action in manager.activeActions {
            if action.status != ActionStatus.active.rawValue {
                otherActions += 1
            }
        }
        XCTAssertTrue(otherActions == 0)
    }
    
    
    func testGettingIncompleteActionContactsWithStatus() {
        var otherActions = 0
        for action in manager.incompleteActions {
            if action.status == ActionStatus.complete.rawValue {
                otherActions += 1
            }
        }
        XCTAssertTrue(otherActions == 0)
    }
    
    func testGettingCompleteActionContactsWithStatus() {
        var otherActions = 0
        for action in manager.activeActions {
            if action.status != ActionStatus.complete.rawValue {
                otherActions += 1
            }
        }
        XCTAssertTrue(otherActions == 0)
        print(" \n After Assertion ----- \n ")
    }
    
}


class CoreDataCoderTests: XCTestCase {
    
    let cdCoder = CoredataCoder()

    var controlDate: Date {
        let calendar = Calendar.current
        var components = DateComponents()
        
        components.year = 2021
        components.month = 5
        components.day = 25
        components.hour = 3
        components.minute = 12
        components.second = 0
        return calendar.date(from: components)!
    }
   
    
    func testEncodeAndDecodeDays() {
        
        let days: [Day : Bool] = [.monday : true,
                                  .tuesday : false,
                                  .wednesday : true,
                                  .thursday : false,
                                  .friday : false,
                                  .saturday : true,
                                  .sunday : true ]
        
        let daysAsString = cdCoder.encode(days: days)
        
        let decodedDays = cdCoder.decode(days: daysAsString!)!
        
        XCTAssert(decodedDays == days)
    }
    
    
    func testFormattingDate() {
        
        let formattedDateString = cdCoder.format(date: controlDate)
        
        let control = "3:12 AM"
        
        XCTAssert(formattedDateString == control)
    }
    
    
}



class ActiveContactTests: XCTestCase {
    
    let acm = ActiveContactManager()
    let testID = "ACTIVECONTACT-TESTID"

    
    func testFetchActionContact() {
        acm.createNewActiveContact(contactInfo: "Contact Info",
                                   parentUUID: "Parent ID",
                                   uuid: testID)
        
        let contact = acm.fetchActiveContact()
        XCTAssert(contact?.uuid == testID)
    }
    
    
    func testDeleteActiveContact() {
        acm.clearActiveContact()
        let contact = acm.fetchActiveContact()
        
        XCTAssert(contact == nil)
        
    }
    
    
}
