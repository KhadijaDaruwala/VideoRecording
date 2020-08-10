//
//  RecordView.swift
//  VideoRecordingDemo
//
//  Created by Khadija Daruwala on 10/08/20.
//  Copyright © 2020 Khadija Daruwala. All rights reserved.
//

import Foundation
import UIKit

class RecordView: UIView{

    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    @IBOutlet weak var labelTimer: UILabel!

    static func loadNib() -> RecordView {
        return UINib(nibName: "RecordView",
                     bundle: nil).instantiate(withOwner: nil,
                                              options: nil).first as! RecordView
    }

    func setRecordingView(isRecording: Bool){
        let image = isRecording ? UIImage(named: "ic_stop") : UIImage(named: "ic_start")
        buttonStart.setImage(image, for: .normal)
        labelTimer.isHidden = !isRecording
    }
}
