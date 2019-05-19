//
//  AddViewController.swift
//  qpp-ios
//
//  Created by Jesse Liang on 5/17/19.
//  Copyright © 2019 Jesse Liang. All rights reserved.
//

import UIKit
import Alamofire
import CoreGraphics

let DIRECTIONS = ["Up", "Down", "Left", "Right"]
let SERVER_URL = "http://35.231.1.207:3000"

class AddViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var pathView: PathView!
    
    let defaults = UserDefaults.standard
    
    var directionsList = [Int()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let currName = defaults.string(forKey: "currentName")
        if (currName != "") {
            directionsList = defaults.array(forKey: currName!) as! [Int]
        } else {
            directionsList.removeAll()
        }
        updateDirections()
    }
    
    func updateDirections() {
        var text = ""
        
        pathView.drawPoints(directions: directionsList)
        
        if (directionsList.count == 0) {
            label.text = text
            return
        }
        
        for i in 0..<directionsList.count {
            text += DIRECTIONS[directionsList[i]]
            if (i == directionsList.count - 1) {
                break
            }
            text += ", "
        }
        label.text = text
    }

    @IBAction func upButton(_ sender: Any) {
        if (directionsList.last == 1) {
            return
        }
        directionsList.append(0)
        updateDirections()
    }
    
    @IBAction func downButton(_ sender: Any) {
        if (directionsList.last == 0) {
            return
        }
        directionsList.append(1)
        updateDirections()
    }
    
    @IBAction func leftButton(_ sender: Any) {
        if (directionsList.last == 3) {
            return
        }
        directionsList.append(2)
        updateDirections()
    }
    
    @IBAction func rightButton(_ sender: Any) {
        if (directionsList.last == 2) {
            return
        }
        directionsList.append(3)
        updateDirections()
    }
    
    @IBAction func deleteButton(_ sender: Any) {
        if (directionsList.count != 0) {
            directionsList.removeLast()
        }
        updateDirections()
    }
    
    @IBAction func clearButton(_ sender: Any) {
        directionsList.removeAll()
        updateDirections()
    }
    
    @IBAction func doneButton(_ sender: Any) {
        if (defaults.bool(forKey: "isEditting")) {
            let name = defaults.string(forKey: "currentName")
            let headers: HTTPHeaders = [
                "Content-Type" : "application/json",
                "Accept": "application/json"
            ]
            let params: Parameters = [
                "name": name!,
                "path": self.directionsList
            ]
            Alamofire.request(SERVER_URL + "/add-path", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseString { response in
                
                let statusCode = response.response?.statusCode
                if statusCode != 200 {
                    self.errorLabel.text = "Network error, try again later"
                    self.errorLabel.textColor = UIColor.red
                } else {
                    self.defaults.set(self.directionsList, forKey: name!)
                    self.defaults.set(false, forKey: "isEditting")
                    self.directionsList.removeAll()
                    self.dismiss(animated: true, completion: nil)
                }
                
            }
        } else {
            getPathName(message: "Enter name for path")
        }
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getPathName(message: String) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "New Path", message: message, preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Room 1"
        })
        
        //3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (action) -> Void in
            let textField = alert?.textFields![0] as UITextField?
            if (textField?.text == "") {
                self.getPathName(message: "Name is required")
            } else if (self.defaults.array(forKey: textField!.text!) != nil) {
                self.getPathName(message: "Name is already taken")
            } else {
                let headers: HTTPHeaders = [
                    "Content-Type" : "application/json",
                    "Accept": "application/json"
                ]
                let params: Parameters = [
                    "name": textField!.text!,
                    "path": self.directionsList
                ]
                Alamofire.request(SERVER_URL + "/add-path", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseString { response in
                    
                    let statusCode = response.response?.statusCode
                    if statusCode != 200 {
                        self.errorLabel.text = "Network error, try again later"
                        self.errorLabel.textColor = UIColor.red
                    } else {
                        self.defaults.set(self.directionsList, forKey: textField!.text!)
                        var paths = self.defaults.array(forKey: "paths") as! [String]
                        paths.append(textField!.text!)
                        self.defaults.set(paths, forKey: "paths")
                        self.defaults.set(false, forKey: "isEditting")
                        self.directionsList.removeAll()
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
}

class PathView: UIView {
    
    var dirs: [Int] = []
    
    var path = UIBezierPath()
    var shapeLayer = CAShapeLayer()
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let halfWidth = width / 2
        
        var rect = CGRect(origin: CGPoint(x: halfWidth - 12.5, y: height - 25), size: CGSize(width: 25, height: 25))
        let homeRect = UIBezierPath(rect: rect)
        UIColor.black.setFill()
        homeRect.fill()
        
        var currPoint = CGPoint(x: halfWidth, y: height - 12.5)
        for dir in dirs {
            
            let currX = currPoint.x
            let currY = currPoint.y
            
            path.move(to: currPoint)
            
            switch dir {
            case 0:
                currPoint = CGPoint(x: currX, y: currY - 30)
            case 1:
                currPoint = CGPoint(x: currX, y: currY + 30)
            case 2:
                currPoint = CGPoint(x: currX - 30, y: currY)
            case 3:
                currPoint = CGPoint(x: currX + 30, y: currY)
            default:
                break;
            }
            
            path.addLine(to: currPoint)
            
            rect = CGRect(origin: CGPoint(x: currPoint.x - 5, y: currPoint.y - 5), size: CGSize(width: 10, height: 10))
            let nodeRect = UIBezierPath(rect: rect)
            UIColor.black.setFill()
            nodeRect.fill()
        }
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 2
        
        self.layer.addSublayer(shapeLayer)
    }
    
    public func drawPoints(directions: [Int]) {
        dirs = directions
        path.removeAllPoints()
        path = UIBezierPath()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
}
