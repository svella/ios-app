//
//  LoginViewController.swift
//  Listen.Moe
//
//  Copyright © 2017 Disre. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var errorMsg: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBAction func loginBtn(_ sender: Any) {
        if username.text != "" && password.text != "" {
            login(username: username.text!, password: password.text!)
        } else {
            errorMsg.text = "You didn't enter emough stuff..."
            errorMsg.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.errorMsg.isHidden = true;
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.tintColor = UIColor(red: 234/255, green: 33/255, blue: 88/255, alpha: 1.0)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        username.delegate = self
        password.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func login(username:String, password:String){
        
        let parameters = ["username": username, "password": password]
        let jsonBody = try? JSONSerialization.data(withJSONObject: parameters)
        let headers = ["Content-Type": "application/json", "Accept": "application/vnd.listen.v4+json"]
        
        var request = URLRequest(url: URL(string: "https://listen.moe/api/login")!)
        
        request.httpMethod = "POST"
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
//        let postString = "username=\(username)&password=\(password)"
//        request.httpBody = postString.data(using: .utf8)
        request.httpBody = jsonBody
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print(error?.localizedDescription as Any)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
                
            }
            
//            let responseString = String(data: data, encoding: .utf8)
//            print("responseString = \(responseString)")
            
            let info = try? JSONDecoder().decode(Response.self, from: data)
            if info?.message == "Successfully logged in." {
                let userDefaults = UserDefaults.standard
                userDefaults.set(info?.token, forKey: "token")
                userDefaults.set(username, forKey: "username")
                DispatchQueue.main.async() { () -> Void in
                    self.errorMsg.isHidden = true;
                    self.goAwayLogin()
                }
            } else {
                DispatchQueue.main.async() { () -> Void in
                    self.errorMsg.text = "Oops something went wrong"
                    self.errorMsg.isHidden = false;
                }
            }
        }
        task.resume()
        
    }
    
    func goAwayLogin () {
        let _ = self.navigationController?.popViewController(animated: true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
