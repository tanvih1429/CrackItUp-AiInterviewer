import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates for return key
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Setup keyboard observers & tap gesture
        setupKeyboardObservers()
        setupTapGesture()
    }

    // MARK: - Email/Password Login
    @IBAction func loginWithEmailTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert("Please enter both email and password.")
            return
        }

        // Try to sign in directly instead of using fetchSignInMethods
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .userNotFound:
                    self.showAlert("No account found for this email.")
                case .wrongPassword:
                    self.showAlert("Incorrect password.")
                default:
                    self.showAlert("Error: \(error.localizedDescription)")
                }
                return
            }

            // Successfully signed in
            self.showAlert("Login successful!")
        }
    }

    // MARK: - Google Sign-In
    @IBAction func loginWithGoogleTapped(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("❌ Missing Google Client ID.")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        // FIX: No optional binding on `self`
        let presentingVC = self.presentedViewController ?? self

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let error = error {
                print("Google Sign-In failed: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                print("❌ Missing Google user info.")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("Firebase Google Sign-In failed: \(error.localizedDescription)")
                    return
                }
                self.showAlert("Google login successful!")
            }
        }
    }

    // MARK: - Alert Helper
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Info", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    
    
    @IBAction func Registration(_ sender: Any) {
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as!    RegisterViewController
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}


  

// MARK: - Keyboard Handling
extension LoginViewController {
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let bottomInset = keyboardFrame.height - view.safeAreaInsets.bottom
            if view.frame.origin.y == 0 { // prevent stacking offset
                view.frame.origin.y -= bottomInset / 2
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }

    func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate (Return Key Handling)
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder() // go to password
        } else {
            textField.resignFirstResponder() // dismiss keyboard
        }
        return true
    }
}
