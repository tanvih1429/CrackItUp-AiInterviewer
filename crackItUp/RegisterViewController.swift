//
//  RegisterViewController.swift
//  crackItUp
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var UserNameTF: UITextField!
    @IBOutlet weak var EnterMailIDTextField: UITextField!
    @IBOutlet weak var EnterMobileNOTextField: UITextField!
    @IBOutlet weak var CreatePasswordTextField: UITextField!
    @IBOutlet weak var ConfirmPasswordTextField: UITextField!
    @IBOutlet weak var RegisterBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Assign delegates
        [UserNameTF, EnterMailIDTextField, EnterMobileNOTextField, CreatePasswordTextField, ConfirmPasswordTextField].forEach {
            $0?.delegate = self
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    // MARK: - Keyboard Handling
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyboardHeight / 2.5
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Registration
    @IBAction func registerButtonTapped(_ sender: Any) {
        guard let name  = UserNameTF.text, !name.isEmpty,
              let email = EnterMailIDTextField.text, isValidEmail(email),
              let phone = EnterMobileNOTextField.text, isValidMobile(phone),
              let password = CreatePasswordTextField.text, isValidPassword(password),
              let confirm  = ConfirmPasswordTextField.text, confirm == password else {
            showAlert("Please fill all fields correctly.")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    self.showAlert("This email is already registered.")
                case .invalidEmail:
                    self.showAlert("Invalid email address.")
                case .weakPassword:
                    self.showAlert("Password is too weak.")
                case .networkError:
                    self.showAlert("Network error. Please try again.")
                default:
                    self.showAlert("Registration failed: \(error.localizedDescription)")
                }
                return
            }
            
            guard let user = result?.user else {
                self.showAlert("Something went wrong. Please try again.")
                return
            }
            
            // Save profile in Firestore
            Firestore.firestore().collection("users").document(user.uid).setData([
                "name": name,
                "email": email,
                "phone": phone,
                "createdAt": FieldValue.serverTimestamp()
            ], merge: true)
            
            // Send verification email
            user.sendEmailVerification { verErr in
                if let verErr = verErr {
                    self.showAlert("Could not send verification email. Please try again.\n\(verErr.localizedDescription)")
                    return
                }
                
                // Immediately sign out
                do {
                    try Auth.auth().signOut()
                } catch {
                    print("Sign out error: \(error.localizedDescription)")
                }
                
                self.showAlert("We’ve sent a verification link to \(email). Please verify your email before logging in.") {
                    if let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") {
                        self.navigationController?.pushViewController(loginVC, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Validation Helpers
    func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
    
    func isValidMobile(_ phone: String) -> Bool {
        let regex = "^[0-9]{10}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: phone)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
}
