//
//  WakyZzzTests.swift
//  WakyZzzTests
//
//  Created by Matthew Sousa on 4/26/21.
//  Copyright © 2021 Olga Volkova OC. All rights reserved.
//

import XCTest
@testable import WakyZzz

class WakyZzzTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}


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
            print("\nfirstDay > secondDay")
            print("\(formatter.string(from: firstDay)) > \(formatter.string(from:secondDay))\n")
            XCTAssertTrue(firstDay > secondDay)
        case false:
            print("\nfirstDay < secondDay")
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
        let _ = am.fetchAlarm(with: testID)
        XCTAssert(am.allAlarms.count != 0)
    }
    
    // Test Delete all alarms
    func testDeleteAll() {
        am.fetchAllAlarms()
        am.deleteAllAlarms()
        am.fetchAllAlarms()
        XCTAssert(am.allAlarms.count == 0)
    }
    
    // Test to delete Specific alarm
    func testDeleteSpecificAlarm() {
        am.fetchAllAlarms()
        am.deleteAlarm(uuid: testID)
        am.fetchAllAlarms()
        XCTAssert(am.allAlarms.count == 0)
    }
    
    // Test getting alarm Time
    func testAlarmTime() {
        let id = "Patriots-Pink-SeaHorse"
        var alarm: Alarm?

        print("\n")
        let fetchedAlarm = am.fetchAlarm(with: id)
        if fetchedAlarm != nil {
            alarm = fetchedAlarm
            print("Found Alarm: \(alarm?.uuid ?? "nil")")
        } else {
            alarm = am.createNewAlarm(uuid: id, time: Date())
            print("Created Alarm: \(alarm?.uuid ?? "nil")")
        }
        
        if let alarmTime = alarm?.alarmTime {
            print("date: \(alarmTime)")
        }
        
        print("\n")
        
         
        
        XCTAssert(alarm?.alarmTime != nil)
    }
    
}
