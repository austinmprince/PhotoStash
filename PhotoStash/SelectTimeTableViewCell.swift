//
//  SelectTimeTableViewCell.swift
//  PhotoStash
//
//  Created by Glizela Taino on 4/10/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit

class SelectTimeTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var associatedTimeLabel: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        //datepicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        timeTextField.tintColor = .clear
        timeTextField.inputView = datePicker
        timeTextField.delegate = self
    }

    func setAssociatedTimeLabel(associatedTimeText: String){
        associatedTimeLabel.text = associatedTimeText
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        setTimeTextField(timeText: textField.text!)
    }
    
    func setTimeTextField(timeText: String){
        timeTextField.text = timeText
    }
    
    func didSelect(){
        //timeTextField.textColor = UIColor(red: 2/255, green: 149/255, blue: 214/255, alpha: 1)
        timeTextField.becomeFirstResponder()
        
    }
    
    //datepicker
    @objc func dateChanged(_ datePicker: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyy    h:mm a"
        timeTextField.text = formatter.string(from: datePicker.date)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
