//
//  Extension.swift
//  VideoRecordingDemo
//
//  Created by Khadija Daruwala on 10/08/20.
//  Copyright © 2020 Khadija Daruwala. All rights reserved.
//

import Foundation

extension Date {
    func dateComponentsSince(date: Date, components: Set<Calendar.Component>?) -> DateComponents {
        let components = components ?? Set<Calendar.Component>([.nanosecond, .second, .minute, .hour, .day, .month, .year])
        let differenceOfDate = Calendar.current.dateComponents(components, from: date, to: self)
        return differenceOfDate
    }

    func timeStringSince(date: Date, components: Set<Calendar.Component>? = nil) -> String {
        let differenceOfDate = self.dateComponentsSince(date: date, components: components)
        return differenceOfDate.dateComponentsToTimeString()
    }
}


extension DateComponents {
    func dateComponentsToTimeString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.minimumIntegerDigits = 2
        let minute = formatter.string(from: self.minute! as NSNumber)!
        let second = formatter.string(from: self.second! as NSNumber)!
        let str = "\(minute):\(second)"
        return str
    }

}
