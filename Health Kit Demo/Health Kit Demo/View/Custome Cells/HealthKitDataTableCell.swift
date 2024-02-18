//
//  HealthKitDataTableCell.swift
//  Health Kit Demo
//
//  Created by Bhavik-COGNIWIDE on 18/02/24.
//

import UIKit

class HealthKitDataTableCell: UITableViewCell {
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var heartRateLabel: UILabel!
    @IBOutlet weak var stepsCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupData(data: HealthKitDataModel) {
        
        let date = Date(timeIntervalSince1970: TimeInterval(data.timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.timeZone = .current
        let localDate = dateFormatter.string(from: date)
        
        dateTimeLabel.text = "\(localDate)"
        heartRateLabel.text = "\(data.heartRate)"
        stepsCountLabel.text = "\(data.stepsCount)"
    }
}
