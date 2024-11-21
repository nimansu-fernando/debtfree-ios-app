//
//  EventKitManager.swift
//  DebtFree
//
//  Created by COBSCCOMPY4231P-006 on 2024-11-11.
//

import SwiftUI
import EventKit

class EventKitManager {
    static let shared = EventKitManager()
    private let eventStore = EKEventStore()
    
    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    }
    
    func saveToCalendar(
        title: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool,
        location: String,
        notes: String,
        urls: [String],
        reminder: String,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.location = location
        event.notes = notes
        
        // Add URLs to notes
        if !urls.isEmpty {
            let urlString = "\n\nURLs:\n" + urls.joined(separator: "\n")
            event.notes = (event.notes ?? "") + urlString
        }
        
        // Set calendar
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Add reminder alarm
        if let alarm = createAlarm(from: reminder) {
            event.addAlarm(alarm)
        }
        
        do {
            try eventStore.save(event, span: .thisEvent)
            completion(true, nil)
        } catch {
            completion(false, error)
        }
    }
    
    private func createAlarm(from reminder: String) -> EKAlarm? {
        let components = reminder.components(separatedBy: " ")
        guard components.count >= 2,
              let timeValue = Int(components[0]) else {
            return nil
        }
        
        var offset: TimeInterval = 0
        switch components[1] {
        case "min":
            offset = TimeInterval(-timeValue * 60)
        case "hour":
            offset = TimeInterval(-timeValue * 60 * 60)
        default:
            return nil
        }
        
        return EKAlarm(relativeOffset: offset)
    }
}
