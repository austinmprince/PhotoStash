//
//  User.swift
//  PhotoStash
//
//  Created by Austin Prince on 4/15/18.
//  Copyright © 2018 photostash. All rights reserved.
//

import Foundation
import UIKit

class User {
    private var firstName:String?
    private var lastName:String?
    private var email:String?
    public var profPic:UIImage?
    private var uid:String?
    
    
    init(first: String, last: String, image: UIImage) {
        self.firstName = first
        self.lastName = last
        self.profPic = image
    }
    init() {
        self.firstName = "blank"
    }
    public func setUid(uidString: String) {
        self.uid = uidString
    }
    public func setEmail(emailString:String) {
        self.email = emailString
    }
    public func getFirstName() -> String {
        return self.firstName!
    }
    public func getLastName() -> String {
        return self.lastName!
    }
    public func getEmail() -> String {
        return self.email!
    }
    public func getUID() -> String {
        return self.uid!
    }
}
