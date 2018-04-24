//
//  InviteTableViewCell.swift
//  PhotoStash
//
//  Created by Glizela Taino on 4/11/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class InviteTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var inviteText: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    var userName = String()
    var albumName = String()
    @IBOutlet weak var confirmationLabel: UILabel!
    @IBOutlet weak var undoButton: UIButton!
    var accepted:Bool?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //accept button
        acceptButton.backgroundColor = .black
        acceptButton.layer.cornerRadius = 3
        acceptButton.titleLabel?.textColor = .white
        acceptButton.titleLabel?.text = "Accept"
        
        //decline button
        declineButton.backgroundColor = .white
        declineButton.layer.borderColor = UIColor.darkGray.cgColor
        declineButton.layer.borderWidth = 1
        declineButton.layer.cornerRadius = 3
        declineButton.titleLabel?.textColor = UIColor.darkGray
        declineButton.titleLabel?.text = "Decline"
        
        //imageView
        userImageView.layer.cornerRadius = userImageView.frame.height/2
        userImageView.clipsToBounds = true
        
        //confirmation
        toggleConfirmationState(didConfirm: false)
        
        //navbar
        
        
    }
    
    func setUserImage(image: UIImage) {
        userImageView.image = image
    }
    
    func setUserName(userName: String){
        self.userName = userName
    }
    
    func setAlbumName(albumName: String) {
        self.albumName = albumName
    }
    
    func setInviteText(){
        
        let text1 = NSMutableAttributedString(string: " wants to share the ")
        let text2 = NSMutableAttributedString(string: " album with you")
        
        let attribute = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15)]
        let attrUserName = NSMutableAttributedString(string: userName, attributes: attribute)
        let attrAlbumName = NSMutableAttributedString(string: albumName, attributes: attribute)
        attrUserName.append(text1)
        attrUserName.append(attrAlbumName)
        attrUserName.append(text2)
        
        self.inviteText.attributedText = attrUserName
    }
    
    @IBAction func acceptedInvite(_ sender: Any) {
        accepted = true
        confirmationLabel.text = "Album invite has been added"
        toggleConfirmationState(didConfirm: true)
        //do something to pass the data
    }
    
    
    @IBAction func declinedInvite(_ sender: Any) {
        accepted = false
        confirmationLabel.text = "Album invite has been declined"
        toggleConfirmationState(didConfirm: true)
        //do something to pass the data
        //OR we could wait till they close
    }
    
    func toggleConfirmationState(didConfirm: Bool){
        acceptButton.isHidden = didConfirm
        declineButton.isHidden = didConfirm
        undoButton.isHidden = !didConfirm
        confirmationLabel.isHidden = !didConfirm
    }
    
    @IBAction func undoButtonPressed(_ sender: Any) {
        accepted = nil
        toggleConfirmationState(didConfirm: false)
        //undo their previous response
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
