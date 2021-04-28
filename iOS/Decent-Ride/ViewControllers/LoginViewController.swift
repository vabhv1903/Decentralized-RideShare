//
//  ViewController.swift
//  Decent-Ride
//
//  Created by Tucker on 1/24/21.
//

import UIKit
import Web3swift


class LoginViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var walletPrivateKeyMnemonic: UITextField!
    @IBOutlet weak var walletNameTextField: UITextField!
    @IBOutlet weak var walletPasswordTextField: UITextField!
    @IBOutlet weak var useExistingAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var pickRoleSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var networkPicker: UISegmentedControl!
    
    // Create new account (true) or use existing account (false)
    private var createNewAccount:Bool = true
    
    // MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.layer.cornerRadius = 6.0
        
    }

    // MARK: pickRoleAction
    @IBAction func pickRoleAction(_ sender: Any) {
        let title = pickRoleSegmentedControl.titleForSegment(at: pickRoleSegmentedControl.selectedSegmentIndex)
        if title == "Passanger" {
            role = .passenger
        }else {
            role = .driver
        }
    }
    
    @IBAction func networkPicker(_ sender: Any) {
        let title = networkPicker.titleForSegment(at: networkPicker.selectedSegmentIndex)
        if title == "Rinkeby Testnet"{
            network = .rinkeby
            
        }else{
            network = .ganache
        }
        
    }
    
    
    
    // MARK: useExistingAccountAction
    // Allows user to login using a existing or create a new account
    @IBAction func useExistingAccountAction(_ sender: Any) {
        if createNewAccount {
            // Switch to create new account
            createNewAccount = false
            // Update views
            walletPrivateKeyMnemonic.isHidden = false
            useExistingAccountButton.setTitle("Create New Account", for: .normal)
            loginButton.setTitle("Login", for: .normal)
        }else{
            createNewAccount = true
            walletPrivateKeyMnemonic.isHidden = true
            useExistingAccountButton.setTitle("Use Existing Account", for: .normal)
            loginButton.setTitle("Create Account", for: .normal)
        }
    }
    
    // MARK: loginButtonAction
    @IBAction func loginButtonAction(_ sender: Any) {
        
        // Create new account
        if createNewAccount {
            wallet = createWallet(password: walletPasswordTextField.text!, walletName: walletNameTextField.text!)
        }
        // Use existing account
        else{
            // Check if text fields are empty
            //if walletPasswordTextField.text!.isEmpty || walletPrivateKeyMnemonic.text!.isEmpty {return}
                // 64 chars is a private key
                if walletPrivateKeyMnemonic.text!.count == 64 {
                    wallet = getWallet(password: walletPasswordTextField.text!, privateKey: walletPrivateKeyMnemonic.text!, walletName: walletNameTextField.text!)
                }
                // Must be a mnemonic
                else {
                    wallet = getWallet(password: walletPasswordTextField.text!, mnemonics: walletPrivateKeyMnemonic.text!, walletName: walletNameTextField.text!)
                }
        }
        // TODO handle error if wallet is nil
        if wallet == nil {return} // RideViewController will not work if no wallet
        password = walletPasswordTextField.text!
        // Segue to view controller
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "RideViewController") as! RideViewController
        self.navigationController!.pushViewController(VC1, animated: true)
    }
}


