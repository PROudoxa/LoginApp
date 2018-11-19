//
//  Extensions.swift
//  LoginScreenTestRB
//
//  Created by Alex Voronov on 15.11.18.
//  Copyright © 2018 Alex Voronov. All rights reserved.
//

import Foundation
import UIKit


extension UIImageView {
    func downloaded(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activityIndicator.startAnimating()
        if self.image == nil{
            self.addSubview(activityIndicator)
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            DispatchQueue.main.async() {
                activityIndicator.removeFromSuperview()
            }
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data,
                let image = UIImage(data: data)
                else { return }
            
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    
    func downloaded(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        
        downloaded(url: url, contentMode: mode)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupCornersFor(views: [UIView], radius: CGFloat) {
        for view in views {
            view.layer.cornerRadius = radius
        }
    }
}

extension UITextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            let text = self.placeholder ?? ""
            self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSForegroundColorAttributeName : newValue ?? UIColor.gray])
        }
    }
}

    // MARK: String

extension String {
    func removeAllWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}


//extension String {
//    var stringByRemovingWhitespaces: String {
//        let components = self.components(separatedBy: .whitespaces)
//        return components.joined(separator: "")
//    }
//}
