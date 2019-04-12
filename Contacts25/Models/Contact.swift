//
//  Contact.swift
//  Contacts25
//
//  Created by Hannah Hoff on 4/12/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation
import CloudKit


//DO I NEED A USER REFERENCE?
class Contact {
    var name: String
    var phoneNumber: String?
    var email: String?
    
    let recordID: CKRecord.ID
    
    init(name: String, phoneNumber: String?, email: String?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.email = email
        self.recordID = recordID
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let name = ckRecord[Constants.nameKey] as? String,
            let phoneNumber = ckRecord[Constants.phoneNumberKey] as? String,
            let email = ckRecord[Constants.emailKey] as? String else { return nil }
        
        self.init(name: name, phoneNumber: phoneNumber, email: email, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(contact: Contact){
        self.init(recordType: Constants.recordTypeKey, recordID: contact.recordID)
        self.setValue(contact.name, forKey: Constants.nameKey)
        self.setValue(contact.phoneNumber, forKey: Constants.phoneNumberKey)
        self.setValue(contact.email, forKey: Constants.emailKey)
    }
}

extension Contact: Equatable {
    static func ==(lhs: Contact, rhs: Contact) -> Bool {
        return lhs.name == rhs.name && lhs.email == rhs.email && lhs.phoneNumber == rhs.phoneNumber
    }
}

struct Constants {
    static let recordTypeKey = "contact"
    static let nameKey = "name"
    static let phoneNumberKey = "phoneNumber"

    static let emailKey = "email"
}
