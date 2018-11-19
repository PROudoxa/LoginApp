//
//  LoginViewController.swift
//  LoginScreenTestRB
//
//  Created by Alex Voronov on 15.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import UIKit
import Foundation


class LoginViewController: UIViewController {
    
    // MARK: Vars
    var networkManager = NetworkManager()
    var user: User?
    let diallingCode = "+380"
    let loginExactLength: Int = 9
    let passwordMinLength: Int = 6
    
    // used for errer label. Mihgt be simplified in case hardcode from storyboard. (!)Might contain wrong values
    var labelInvalidCredentialsHeight: CGFloat = 36 // from storyboard (will be updated in viewDidLoad)
    var constraintLabelInvalidCredentialsTopMarginDefaultValue: CGFloat = 0
    var constraintFlexibleSpaceDefaultValue: CGFloat = 32 + 16 + 36 // from storyboard + labelTopMargin + labeHeight
    var constraintVisibleLabelInvalidCredentialsTopMargin: CGFloat = 10 // top margin for visible label
    
    
    // MARK: @IBOutlets
    @IBOutlet weak var viewLoginTF: UIView!
    @IBOutlet weak var textFieldDiallingСode: UITextField!
    @IBOutlet weak var textFieldLogin: UITextField!
    @IBOutlet weak var viewPasswordTF: UIView!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var constraintLabelInvalidCredentialsTopMargin: NSLayoutConstraint!
    @IBOutlet weak var labelInvalidCredentials: UILabel!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var labelForgotPassword: UILabel!
    @IBOutlet weak var constraintFlexibleSpace: NSLayoutConstraint!
    
    @IBOutlet weak var imageViewFacebook: UIImageView!
    @IBOutlet weak var imageViewTwitter: UIImageView!
    @IBOutlet weak var imageViewVKontakte: UIImageView!
    @IBOutlet weak var imageViewGoogle: UIImageView!
    
    @IBOutlet weak var labelSignUp: UILabel!
    
    
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupDefaultsForViews()
        self.hideKeyboardWhenTappedAround()
        self.takeСhargeAsDelegate()
        self.addSegueTaps()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.hideLabelInvalidCredentials()
        self.addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.removeObservers()
    }
    
    deinit {
        self.removeObservers()
    }
}

    // MARK: Private funcs

private extension LoginViewController {
    
    func setupDefaultsForViews() {
        self.textFieldDiallingСode.text = self.diallingCode
        self.textFieldLogin.text = ""
        self.textFieldPassword.text = ""
        self.viewLoginTF.backgroundColor = Colors.grayColor
        self.viewPasswordTF.backgroundColor = Colors.grayColor
        
        self.toggleButtonLogin(to: false)
        self.setupCornersFor(views: [self.viewLoginTF, self.viewPasswordTF, self.buttonLogin], radius: ViewBorders.cornerRadius)
        
        self.setupDefaultsForViewsRelatedToErrorLabel()
    }
    
    func setupDefaultsForViewsRelatedToErrorLabel() {
        // set default values for margins for visible/invisible label
        self.labelInvalidCredentialsHeight = self.labelInvalidCredentials.frame.height
        self.constraintLabelInvalidCredentialsTopMarginDefaultValue = 0
        self.constraintFlexibleSpaceDefaultValue = self.constraintFlexibleSpace.constant + self.constraintLabelInvalidCredentialsTopMarginDefaultValue + self.labelInvalidCredentialsHeight
        self.constraintVisibleLabelInvalidCredentialsTopMargin = self.constraintLabelInvalidCredentialsTopMargin.constant
    }
    
    func takeСhargeAsDelegate() {
        self.textFieldLogin.delegate = self
        self.textFieldPassword.delegate = self
    }
    
    func showLabelInvalidCredentials(errorMessage: String) {
        self.labelInvalidCredentials.text = errorMessage
        self.constraintLabelInvalidCredentialsTopMargin.constant = self.constraintVisibleLabelInvalidCredentialsTopMargin
        self.constraintFlexibleSpace.constant = self.constraintFlexibleSpaceDefaultValue - self.labelInvalidCredentialsHeight - constraintVisibleLabelInvalidCredentialsTopMargin
        self.view.layoutIfNeeded()
    }
    
    func hideLabelInvalidCredentials() {
        self.labelInvalidCredentials.text = ""
        self.constraintLabelInvalidCredentialsTopMargin.constant = 0
        self.constraintFlexibleSpace.constant = self.constraintFlexibleSpaceDefaultValue
        self.view.layoutIfNeeded()
    }
    
    // MARK: segue taps
    
    func addSegueTaps() {
        let tapSignUp = UITapGestureRecognizer(target: self, action: #selector(self.goToSignUpVC(sender:)))
        self.labelSignUp.isUserInteractionEnabled = true
        self.labelSignUp.addGestureRecognizer(tapSignUp)
        
        let tapForgotPassword = UITapGestureRecognizer(target: self, action: #selector(self.goToForgotPasswordVC(sender:)))
        self.labelForgotPassword.isUserInteractionEnabled = true
        self.labelForgotPassword.addGestureRecognizer(tapForgotPassword)
    }
    
    @objc func goToSignUpVC(sender: UITapGestureRecognizer) {
        guard let signUpVC: SignUpViewController = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController else { print("sorry, i can't go to signUpVC..."); return }
        
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func goToForgotPasswordVC(sender: UITapGestureRecognizer) {
        guard let forgotPasswordVC: ForgotPasswordViewController = storyboard?.instantiateViewController(withIdentifier: StoryboardIds.ForgotPasswordViewController.rawValue) as? ForgotPasswordViewController else { print("sorry, i can't go to forgotPasswordVC..."); return }
        
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }
    
    // MARK: Check credentials before loggining in
    
    func credentialsAreAllowed(login: String, password: String) -> Bool {
        let isLoginAllowed = self.isLoginEvaluated(login, exactLength: self.loginExactLength)
        let isPasswordAllowed = self.isPasswordEvaluated(password, minimalLenght: self.passwordMinLength)
        
        return (isLoginAllowed && isPasswordAllowed)
    }
    
    func isLoginEvaluated(_ login : String, exactLength: Int) -> Bool {
        guard exactLength >= 1 else { return false }
        
        let numberOfDigits = exactLength
        var sequenceOfDigits = ""
        let oneDigit = ".*[0-9]"
        
        for _ in 1...numberOfDigits {
            sequenceOfDigits = sequenceOfDigits + oneDigit
        }
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=\(sequenceOfDigits)).{\(numberOfDigits)}$")
        
        return passwordTest.evaluate(with: login)
    }
    
    func isPasswordEvaluated(_ password : String, minimalLenght: Int) -> Bool {
        guard minimalLenght >= 0 else { return false }
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^.{\(minimalLenght),}$")
        return passwordTest.evaluate(with: password)
    }
    
    func toggleButtonLogin(to isActiveState: Bool) {
        let titleColor = isActiveState ? UIColor.white : Colors.grayColor
        self.buttonLogin.setTitleColor(titleColor, for: .normal)
        self.buttonLogin.backgroundColor = isActiveState ? Colors.lightBlueColor : Colors.darkGrayColor
        self.buttonLogin.layer.borderWidth = isActiveState ? 0 : ViewBorders.borderWidth
        self.buttonLogin.isEnabled = isActiveState
        self.buttonLogin.layer.borderColor = Colors.grayColor.cgColor
    }
}

    // MARK: @IBActions

extension LoginViewController {

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        let loginTail = self.textFieldLogin.text ?? ""
        let password = self.textFieldPassword.text ?? ""
        
        let credentialsAreAllowed = self.credentialsAreAllowed(login: loginTail, password: password)
        
        guard
            credentialsAreAllowed,
            let diallingCode = self.textFieldDiallingСode.text else { return }
        
        self.buttonLogin.isUserInteractionEnabled = false
        
        let login = diallingCode + loginTail
        
        self.spinner.startAnimating()
        self.networkManager.callToLogIn(login: login, password: password)
    }
}

    // MARK: KVO

extension LoginViewController {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(networkManager.userHasBeenGot) {
            
            if networkManager.userHasBeenGot {
                self.hideLabelInvalidCredentials()
                self.buttonLogin.isUserInteractionEnabled = true
                self.spinner.stopAnimating()
                
                self.user = self.networkManager.getUser()
                
                guard
                    let homeVC: HomeViewController = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController,
                    let loggedUser = self.user else { print("sorry, i can't go to HomeVC..."); return }
                
                homeVC.user = loggedUser
                
                DispatchQueue.main.async {
                    self.present(homeVC, animated: true, completion: nil)
                }
            }
            
        } else if keyPath == #keyPath(networkManager.errorMessage) {
            
            if let error = self.networkManager.errorMessage {
                // TODO: switch errors from networkManager enum
                self.buttonLogin.isUserInteractionEnabled = true
                self.spinner.stopAnimating()
                
                print(error)
                self.showLabelInvalidCredentials(errorMessage: error)
            }
        }
    }
    
    func addObservers() {
        addObserver(self, forKeyPath: #keyPath(networkManager.userHasBeenGot), options: [.old, .new], context: nil)
        addObserver(self, forKeyPath: #keyPath(networkManager.errorMessage), options: [.old, .new], context: nil)
    }
    
    func removeObservers() {
        removeObserver(self, forKeyPath: #keyPath(networkManager.userHasBeenGot))
        removeObserver(self, forKeyPath: #keyPath(networkManager.errorMessage))
    }
}

    // MARK: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        switch textField {
        case self.textFieldLogin:
            break
            /* in case num keyboard is changed to letters keyboard
            let passIsEmpty: Bool = (self.textFieldPassword.text?.removeAllWhitespaces() == "")
            
            if passIsEmpty {
                textField.returnKeyType = .continue
            } else {
                textField.returnKeyType = .go
            } */
            
        case self.textFieldPassword:
            textField.returnKeyType = .go
            
        default:
            print("\(self).switch: Hey, bro! I've got unknown text field...")
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let oldText = textField.text else { return true }
        
        let newText = (oldText as NSString).replacingCharacters(in: range, with: string)
        let newTextCleared = newText.removeAllWhitespaces()
        
        var credentialsAreAllowed = false
        
        switch textField {
        case self.textFieldLogin:
            credentialsAreAllowed = self.credentialsAreAllowed(login: newTextCleared, password: self.textFieldPassword.text ?? "")
            
        case self.textFieldPassword:
            credentialsAreAllowed = self.credentialsAreAllowed(login: self.textFieldLogin.text ?? "", password: newTextCleared)
            
        default:
            print("\(self).switch: Bro, i've got unknown text field...")
        }
        
        // Validation before goToLogin func
        self.toggleButtonLogin(to: credentialsAreAllowed)
        
        return true
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        //textField.text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
//        print(textFieldPassword.text ?? "def")
//        // called even in case cancel
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case self.textFieldLogin:
            break
            /* in case num keyboard is changed to letters keyboard
            let passIsEmpty: Bool = (self.textFieldPassword.text?.removeAllWhitespaces() == "")
            
            if passIsEmpty {
                self.textFieldPassword.becomeFirstResponder()
            } else {
                print("go to login")
            } */
            
        case self.textFieldPassword:
            self.loginButtonTapped(self.buttonLogin)
            
        default:
            print("\(self).switch: Hey, bro! I've got unknown text field...")
        }
        
        return true
    }
}
