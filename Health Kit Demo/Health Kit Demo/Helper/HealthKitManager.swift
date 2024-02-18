//
//  HealthKitManager.swift
//  Health Kit Demo
//
//  Created by Bhavik on 14/02/24.
//

import Foundation
import HealthKit


class HealthKitManager {
    private let healthStore: HKHealthStore
    
    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            fatalError("This app requires a device that supports HealthKit")
        }
        
        healthStore = HKHealthStore()
        requestHealthkitPermissions()
    }
    
    private func requestHealthkitPermissions() {
        
        let sampleTypesToRead = Set([
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .stepCount)!
        ])
        
        healthStore.requestAuthorization(toShare: nil, read: sampleTypesToRead) { (success, error) in
            print("Request Authorization: Success: ", success, " Error: ", error ?? "nil")
        }
    }
    
    // MARK: - Combine Method to read multiple data from Health Kit
    
    func readHealthKitData(completion: @escaping (String, String) -> ()) {
        let group = DispatchGroup()
        
        /// Read Heart Rate Data
        group.enter()
        
        let quantityType  = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        var heartRateAverage: Double = 0
        
        let sampleQuery = HKSampleQuery.init(sampleType: quantityType,
                                             predicate: getPastHoursPredicate(pastHour: -24),
                                             limit: HKObjectQueryNoLimit,
                                             sortDescriptors: [sortDescriptor],
                                             resultsHandler: { (query, results, error) in
            
            guard let samples = results as? [HKQuantitySample] else {
                print(error!)
                group.leave()
                return
            }
            let allHeartRate = samples.compactMap({$0.quantity.doubleValue(for: HKUnit(from: "count/min"))})
            heartRateAverage = allHeartRate.reduce(.zero, +) / Double(allHeartRate.count)
            
            for sample in samples {
                let mSample = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                print("Heart rate : \(mSample)")
            }
            
            print("Average Heart Rate: \(heartRateAverage)")
            group.leave()
            
        })
        self.healthStore.execute(sampleQuery)

        /// Read Steps count data
        group.enter()
        
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            group.leave()
            fatalError("Error: Unable to get the step count type.")
        }
        
        var totalStepCount:Double = 0
        let query = HKStatisticsQuery.init(
            quantityType: stepCountType,
            quantitySamplePredicate: getPastHoursPredicate(pastHour: -24),
            options: [HKStatisticsOptions.cumulativeSum, HKStatisticsOptions.separateBySource]
        ) { (query, results, error) in
            
            totalStepCount = results?.sumQuantity()!.doubleValue(for: HKUnit.count()) ?? 0
            print("Total step count in Last hour: \(totalStepCount)")
            group.leave()
        }
        healthStore.execute(query)
        
        group.notify(queue: .main) {
            let heartRateString = String(format:"%.2f", heartRateAverage)
            let totalStepCountString = String(format:"%.2f", totalStepCount)
            completion(heartRateString, totalStepCountString)
        }
    }
    
    // MARK: - Individual Methods to read data from Health Kit
    
    func readHeartRate() -> Double {
        let quantityType  = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        var heartRateAverage: Double = 0
        
        let sampleQuery = HKSampleQuery.init(sampleType: quantityType,
                                             predicate: getPastHoursPredicate(pastHour: -5),
                                             limit: HKObjectQueryNoLimit,
                                             sortDescriptors: [sortDescriptor],
                                             resultsHandler: { (query, results, error) in
            
            guard let samples = results as? [HKQuantitySample] else {
                print(error!)
                return
            }
            let allHeartRate = samples.compactMap({$0.quantity.doubleValue(for: HKUnit(from: "count/min"))})
            heartRateAverage = allHeartRate.reduce(.zero, +) / Double(allHeartRate.count)
            
            for sample in samples {
                let mSample = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
                print("Heart rate : \(mSample)")
            }
            
            print("Average Heart Rate: \(heartRateAverage)")
            
        })
        self.healthStore.execute(sampleQuery)
        return heartRateAverage
    }
    
    func readStepsCount() -> Double {
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("Error: Unable to get the step count type.")
        }
        
        var totalStepCount:Double = 0
        let query = HKStatisticsQuery.init(
            quantityType: stepCountType,
            quantitySamplePredicate: getPastHoursPredicate(pastHour: -5),
            options: [HKStatisticsOptions.cumulativeSum, HKStatisticsOptions.separateBySource]
        ) { (query, results, error) in
            
            totalStepCount = results?.sumQuantity()!.doubleValue(for: HKUnit.count()) ?? 0
            print("Total step count in Last hour: \(totalStepCount)")
        }
        healthStore.execute(query)
        return totalStepCount
    }
    
    private func getPastHoursPredicate(pastHour: Int) -> NSPredicate {
        let today = Date()
        let startDate = Calendar.current.date(byAdding: .hour, value: pastHour, to: today)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: today,options: [])
        return predicate
    }
}
