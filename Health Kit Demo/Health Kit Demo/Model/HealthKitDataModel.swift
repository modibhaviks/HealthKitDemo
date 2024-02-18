//
//  HealthKitDataModel.swift
//  Health Kit Demo
//
//  Created by Bhavik on 18/02/24.
//

import Foundation

struct HealthKitDataModel: Codable {
    let heartRate: String
    let stepsCount: String
    let timeStamp: TimeInterval
}
