//
//  HomeViewController.swift
//  LoginScreenTestRB
//
//  Created by Alex Voronov on 16.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import UIKit
import CoreData
import M13Checkbox


class HomeViewController: UIViewController {
    
    var user: User?
    
    
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelFirstName: UILabel!
    @IBOutlet weak var labelLastName: UILabel!
    @IBOutlet weak var checkBox: M13Checkbox!
    
    
    // MARK: VIew lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureViews()
        self.updateUserDataViews()
        self.setCheckbox(checkBox: self.checkBox)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: @IBActions
    
    @IBAction func buttonLogOutTapped(_ sender: UIButton) {
        
        // delegate clean TF
        let message = "Are you sure you want to log out?"
        let alertController = UIAlertController(title: "Log out", message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Log out", style: .destructive) { (_) in
            self.doLogout()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancel)
        alertController.addAction(ok)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

private extension HomeViewController {
    
    func configureViews() {
        self.setupCornersFor(views: [self.imageViewAvatar], radius: self.imageViewAvatar.frame.height / 2)
        self.imageViewAvatar.layer.borderWidth = 2
        self.imageViewAvatar.layer.borderColor = UIColor.gray.cgColor
    }
    
    func updateUserDataViews() {
        var firstNameTail: String?
        var lastNameTail: String?
        var avatarLink: String?
        
        if self.user == nil {
            // came from launching app (homeVC as rootVC)
            // check Core Data model
            let userTupple = self.getUserDataFromCoreData()
            firstNameTail = userTupple.firstName
            lastNameTail = userTupple.lastName
            avatarLink = userTupple.avatarLink
            
        } else {
            // came from login screen
            firstNameTail = self.user?.firstName
            lastNameTail = self.user?.lastName
            avatarLink = self.user?.avatar
        }
        
        let firstNameFullText = "First name: " + (firstNameTail ?? "")
        let lastNameFullText = "Last name: " + (lastNameTail ?? "")
        
        let rangeFN = (firstNameFullText as NSString).range(of: firstNameTail ?? "")
        let attributedStringFN = NSMutableAttributedString(string: firstNameFullText)
        attributedStringFN.addAttribute(NSForegroundColorAttributeName, value: Colors.lightBlueColor, range: rangeFN)
        
        let rangeLN = (firstNameFullText as NSString).range(of: lastNameTail ?? "")
        let attributedStringLN = NSMutableAttributedString(string: lastNameFullText)
        attributedStringLN.addAttribute(NSForegroundColorAttributeName, value: Colors.lightBlueColor, range: rangeLN)
        
        self.labelFirstName.attributedText = attributedStringFN
        self.labelLastName.attributedText = attributedStringLN
        
        self.updateProfileImage(avatarLink: avatarLink)
    }
    
    func updateProfileImage(avatarLink: String?) {
        if let avatarLink = avatarLink, avatarLink != "" {
            DispatchQueue.global(qos: .background).async {
                self.imageViewAvatar.downloaded(link: avatarLink)
                self.imageViewAvatar.contentMode = .scaleAspectFill
            }
        }
    }
    
    func getUserDataFromCoreData() -> (firstName: String?, lastName: String?, avatarLink: String?) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return (nil, nil, nil) }
        
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let userRequest: NSFetchRequest<UserCoreDataModel> = UserCoreDataModel.fetchRequest()
        var userCoreData = [UserCoreDataModel]()
        
        do {
            try userCoreData = context.fetch(userRequest)
            
            guard userCoreData.count >= 0 else { print("list from coreData is empty"); return (nil, nil, nil) }
            
            let firstName = userCoreData.last?.firstName ?? ""
            let lastName = userCoreData.last?.lastName ?? ""
            let avatarLink = userCoreData.last?.avatarLink ?? ""
            
            return (firstName, lastName, avatarLink)
            
        } catch {
            print("Could not load data")
        }
        
        return (nil, nil, nil)
    }
    
    func doLogout() {
        UserDefaults.standard.setValue("", forKey: "Access-Token")
        
        guard
            let loginVC: LoginViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIds.LoginViewController.rawValue) as? LoginViewController else { print("sorry, i can't go to LoginVC..."); return }
        
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func setCheckbox(checkBox: M13Checkbox) {
        checkBox.boxType = .circle
        checkBox.checkState = .unchecked
        checkBox.stateChangeAnimation = .fade(.fill)
        checkBox.animationDuration = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // response imitation: error
            self.checkBox.toggleCheckState()
        }
    }
}
