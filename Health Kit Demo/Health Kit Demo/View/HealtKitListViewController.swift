//
//  ViewController.swift
//  Health Kit Demo
//
//  Created by Bhavik on 18/02/24.
//

import UIKit

class HealtKitListViewController: UIViewController {
    
    // MARK: - IBoutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    var hkManager: HealthKitManager!
    var healthKitDataList: [HealthKitDataModel]?
    var currentHealthKitData: HealthKitDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupHealthKit()
        reloadData()
        retrieveDataFromHealthKit()
    }

    // MARK: - Private Methods
    private func setupTableView() {
        tableView.dataSource = self
        
        let nib = UINib(nibName: "HealthKitDataTableCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HealthKitDataTableCell")
    }
    
    private func setupHealthKit() {
        hkManager = HealthKitManager.init()
    }
    
    /// Fetch Latest Data from Health Kit
    private func retrieveDataFromHealthKit() {
        hkManager.readHealthKitData { [weak self] heartRate, steps in
            let timeStamp = Date().timeIntervalSince1970
            self?.currentHealthKitData = HealthKitDataModel(heartRate: heartRate, stepsCount: steps, timeStamp: timeStamp)
        }
    }
    
    /// Get Health Kit data from Storage and Reload Table View
    private func reloadData() {
        if let data = StorageManager.getDataFromUserDefaults(), !data.isEmpty {
            healthKitDataList = data
            tableView.reloadData()
        }
    }
    
    // MARK: - IBAction Methods
    @IBAction func retrieveDataFromHealthKitButtonTapped(_ sender: Any) {
        retrieveDataFromHealthKit()
    }
    
    @IBAction func getDataButtonTapped(_ sender: Any) {
        reloadData()
    }
    
    @IBAction func saveDataButtonTapped(_ sender: Any) {
        if let data = currentHealthKitData {
            StorageManager.saveDataToUserDefaults(healtKitData: data)
        }
    }
}

// MARK: - Table View Data Source
extension HealtKitListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return healthKitDataList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "HealthKitDataTableCell"
        let cell: HealthKitDataTableCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HealthKitDataTableCell
        
        if let data = healthKitDataList?[indexPath.row] {
            cell.setupData(data: data)
        } else {
            return UITableViewCell()
        }
        
        return cell
    }
}
