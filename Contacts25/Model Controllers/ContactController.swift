//
//  ContanctController.swift
//  Contacts25
//
//  Created by Hannah Hoff on 4/12/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    // Shared Instance
    static let shared = ContactController()
    private init(){}
    
    // Source of truth
    var contacts: [Contact] = []
    
    var contact: Contact?
    
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //Mark: - CRUD Functions
    func createContact(name: String, phoneNumber: String?, email: String?, completion: @escaping ((Contact?) -> Void)) {
        // Create a new contacts
        let contact = Contact(name: name, phoneNumber: phoneNumber, email: email)
        // Store it locally
        self.contacts.append(contact)
        // Create a CKRecord from the new post
        publicDB.save(CKRecord(contact: contact)) { (record, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(nil)
                return
            }
            // Unwrap record received
            guard let record = record else { return }
            // Create post from record
            let contact = Contact(ckRecord: record)
            // Store it locally
            guard let unwrappedContact = contact else { return }
            // Complete with contact
            completion(unwrappedContact)
        }
    }
    // Read
    func fetchContacts(completion: @escaping (Bool) -> Void) {
        // Make predicate for query
        let predicate = NSPredicate(value: true)
        // Make query for perform
        let query = CKQuery(recordType: Constants.recordTypeKey, predicate: predicate)
        // Make a fetch request
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            }
            // Unwrap records
            guard let records = records else { completion(false); return }
            // Fill our soucre of truth
            let contactsArray: [Contact] = records.compactMap{ Contact(ckRecord: $0) }
            self.contacts = contactsArray
            completion(true)
        }
    }
    
    func updateContact(contact: Contact, name: String, phoneNumber: String?, email: String?, completion: @escaping ((Bool) -> Void)) {
        contact.name = name
        contact.phoneNumber = phoneNumber
        contact.email = email
        
        publicDB.fetch(withRecordID: contact.recordID) { (record, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            }
            
            guard let record = record else { return }
            record[Constants.nameKey] = name
            record[Constants.phoneNumberKey] = phoneNumber
            record[Constants.emailKey] = email
            
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            modifyOperation.savePolicy = .changedKeys
            modifyOperation.queuePriority = .high
            modifyOperation.qualityOfService = .default
            modifyOperation.modifyRecordsCompletionBlock = {(records, recirdIDs, error) in
                completion(true)
            }
            self.publicDB.add(modifyOperation)
        }
    }
    
    func deleteContact(contact: Contact, completion: @escaping (Bool) -> ()) {
        guard let index = ContactController.shared.contacts.index(of: contact) else { return }
        ContactController.shared.contacts.remove(at: index)
        
        publicDB.delete(withRecordID: contact.recordID) { (_, error) in
            if let error = error {
                print("💩 There was an error in \(#function) ; \(error) ; \(error.localizedDescription) 💩")
                completion(false)
                return
            } else{
                completion(true)
            }
        }
    }
}
