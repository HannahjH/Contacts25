//
//  ContactDetailViewController.swift
//  Contacts25
//
//  Created by Hannah Hoff on 4/12/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController {

    var contact: Contact? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func updateViews() {
        guard let contact = contact else { return }
        
        nameTextField.text = contact.name
        phoneTextField.text = contact.phoneNumber
        emailTextField.text = contact.email
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let nameTextField = nameTextField.text,
        let phoneNumberTextField = phoneTextField.text,
            let emailTextField = emailTextField.text else { return }
        
        if let contact = contact {
            ContactController.shared.updateContact(contact: contact, name: nameTextField, phoneNumber: phoneNumberTextField, email: emailTextField) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("Failed to update")
                }
            }
        } else {
                    ContactController.shared.createContact(name: nameTextField, phoneNumber: phoneNumberTextField, email: emailTextField, completion: { (_) in
                    })
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
