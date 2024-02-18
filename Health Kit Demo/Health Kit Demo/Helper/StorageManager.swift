//
//  StorageManager.swift
//  Health Kit Demo
//
//  Created by Bhavik on 18/02/24.
//

import Foundation

class StorageManager {
    
    static func saveDataToUserDefaults(healtKitData: HealthKitDataModel) {
        var healthKitDataList: [HealthKitDataModel]  = getDataFromUserDefaults() ?? []
        healthKitDataList.append(healtKitData)
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(healthKitDataList), forKey:"HealthKitStorage")
    }
    
    static func getDataFromUserDefaults() -> [HealthKitDataModel]? {
        if let data = UserDefaults.standard.value(forKey:"HealthKitStorage") as? Data {
            guard let healthKitDataList = try? PropertyListDecoder().decode([HealthKitDataModel].self, from: data) else {
                return []
            }
            return healthKitDataList
        }
        return []
    }
}
