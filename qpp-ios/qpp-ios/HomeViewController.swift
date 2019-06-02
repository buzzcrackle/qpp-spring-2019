//
//  HomeViewController.swift
//  qpp-ios
//
//  Created by Jesse Liang on 5/17/19.
//  Copyright © 2019 Jesse Liang. All rights reserved.
//

import UIKit
import Alamofire
import CoreGraphics

class HomeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var mapVIew: MapView!
    @IBOutlet weak var messageLabel: UILabel!
    
    let defaults = UserDefaults.standard
    var timer: Timer?
    
    var currentPath = [Int()]
    var currentName = ""
    var pathNames = [String()]
    
    // Runs code whenever this page is first loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        // CHecks for all paths that were already created
        Alamofire.request(SERVER_URL + "/get-all", method: .get).responseJSON { response in
            let statusCode = response.response?.statusCode
            if statusCode != 200 {
                self.messageLabel.text = "Network error try again later"
                self.messageLabel.textColor = UIColor.red
            } else {
                if let result = response.result.value as? [String: Any] {
                    let paths = result["paths"] as! [[String: Any]]
                    var array : [String] = []
                    for i in 0..<paths.count {
                        let path = paths[i]
                        let pathName = path["name"] as! String
                        let pathArray = path["path"] as! [Int]
                        array.append(pathName)
                        self.defaults.set(pathArray, forKey: pathName)
                    }
                    self.defaults.set(array, forKey: "paths")
                }
            }
        }
        
        defaults.set(false, forKey: "isEditting")
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if defaults.array(forKey: "paths") != nil {
            pathNames = defaults.array(forKey: "paths") as! [String]
        } else {
            pathNames.removeAll()
            defaults.set(pathNames, forKey: "paths")
        }
        
        currentPath.removeAll()
        
        if (pathNames.count != 0) {
            currentName = pathNames[pickerView.selectedRow(inComponent: 0)]
            currentPath = defaults.array(forKey: currentName) as! [Int]
            defaults.set(currentName, forKey: "currentName");
        }
    }
    
    // Updates view whenever the view appears again
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageLabel.text = ""
        if (defaults.array(forKey: "paths") == nil) {
            var array = [String()]
            array.removeAll()
            defaults.set(array, forKey: "paths")
        }
        
        pathNames = defaults.array(forKey: "paths") as! [String]
        if (pathNames.count != 0 ) {
            currentName = pathNames[pickerView.selectedRow(inComponent: 0)]
            defaults.set(currentName, forKey: "currentName");
        }
        pickerView.reloadAllComponents()
        mapVIew.drawPoints()
    }
    
    // Sends user to add path page but with the existing path
    @IBAction func editButton(_ sender: Any) {
    if (currentName != "") {
            defaults.set(true, forKey: "isEditting")
            defaults.set(currentName, forKey: "currentName")
            performSegue(withIdentifier: "addModal", sender: self)
        }
    }
    
    // Sends user to add path page
    @IBAction func addButton(_ sender: Any) {
        currentName = ""
        defaults.set(currentName, forKey: "currentName")
        performSegue(withIdentifier: "addModal", sender: self)
    }
    
    // Calls delivery
    @IBAction func deliverButton(_ sender: Any) {
        if (currentPath.count == 0) {
            messageLabel.text = "No path selected"
            messageLabel.textColor = UIColor.red
        } else {
            Alamofire.request(SERVER_URL + "/bot-free", method: .get).responseJSON { response in
                let statusCode = response.response?.statusCode
                if statusCode != 200 {
                    self.messageLabel.textColor = UIColor.red
                    self.messageLabel.text = "Network error try again later"
                } else {
                    if let result = response.result.value as? [String: Any] {
                        if (result["free"] as! Bool == false) {
                            self.messageLabel.textColor = UIColor.black
                            self.messageLabel.text = "Robot currently unavailable, try again later"
                        } else {
                            self.startDelivery()
                        }
                    }
                }
            }
        }
    }
    
    // Sends request to server to start deliver for bot
    func startDelivery() {
        messageLabel.text = ""
        let currPath = defaults.array(forKey: currentName) as! [Int]
        let headers: HTTPHeaders = [
            "Content-Type" : "application/json",
            "Accept": "application/json"
        ]
        let params: Parameters = [
            "name": currentName,
            "path": currPath
        ]
        Alamofire.request(SERVER_URL + "/bot-instructions", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseString { response in
            
            let statusCode = response.response?.statusCode
            if statusCode != 200 {
                self.messageLabel.textColor = UIColor.red
                self.messageLabel.text = "Network error, try again later"
            } else {
                self.messageLabel.textColor = UIColor.black
                self.messageLabel.text = "Success, robot in delivery"
                self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.checkStatus), userInfo: nil, repeats: true)
                
            }
            
        }
    }
    
    // Checks the server to see if there is an update on the delivery
    @objc func checkStatus() {
        Alamofire.request(SERVER_URL + "/bot-free", method: .get).responseJSON { response in
            let statusCode = response.response?.statusCode
            if statusCode != 200 {
                self.messageLabel.text = "Network error try again later"
                self.messageLabel.textColor = UIColor.red
            } else {
                if let result = response.result.value as? [String: Any] {
                    if (result["free"] as! Bool == true) {
                        self.timer?.invalidate()
                        self.messageLabel.textColor = UIColor.black
                        self.messageLabel.text = "Delivery made, robot available"
                    }
                }
            }
        }
    }
    
    // Used to create the number of rows for pickerview
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pathNames.count
    }
    
    // Used to determine the number of componenets in pickerview (I'm assuming like a date picker requires 3 components MMDDYY, but we need 1)
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Used to determine the strings in each row of the pickerview
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pathNames[row]
    }
    
    // Used to see which pickerview was selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentName = pathNames[row]
        currentPath = defaults.array(forKey: pathNames[row]) as! [Int]
        defaults.set(currentName, forKey: "currentName")
        mapVIew.drawPoints()
    }
}

// UIView for the map This part is really messy, but it basically creates a new "node" and connects it to the previous one as a line
class MapView: UIView {
    let defaults = UserDefaults.standard
    
    var path = UIBezierPath()
    var shapeLayer = CAShapeLayer()
    
    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let halfWidth = width / 2
        
        var rect = CGRect()
        
        let pathNames = defaults.array(forKey: "paths") as! [String]
        for pathName in pathNames {
            let dirs = defaults.array(forKey: pathName) as! [Int]
            
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
        }
        
        shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.lineWidth = 2
        
        self.layer.addSublayer(shapeLayer)
        
        let curPath = UIBezierPath()
        let curLayer = CAShapeLayer()
        
        let curName = defaults.string(forKey: "currentName")
        if (curName != nil) {
            let dirs = defaults.array(forKey: curName!) as! [Int]
            
            var currPoint = CGPoint(x: halfWidth, y: height - 12.5)
            for i in 0..<dirs.count {
                
                let currX = currPoint.x
                let currY = currPoint.y
                
                var endPoint = CGPoint()
                
                switch dirs[i] {
                case 0:
                    curPath.move(to: CGPoint(x: currX, y: currY - 5))
                    currPoint = CGPoint(x: currX, y: currY - 30)
                    endPoint = CGPoint(x: currX, y: currY - 25)
                case 1:
                    curPath.move(to: CGPoint(x: currX, y: currY + 5))
                    currPoint = CGPoint(x: currX, y: currY + 30)
                    endPoint = CGPoint(x: currX, y: currY + 25)
                case 2:
                    curPath.move(to: CGPoint(x: currX - 5, y: currY))
                    currPoint = CGPoint(x: currX - 30, y: currY)
                    endPoint = CGPoint(x: currX - 25, y: currY)
                case 3:
                    curPath.move(to: CGPoint(x: currX + 5, y: currY))
                    currPoint = CGPoint(x: currX + 30, y: currY)
                    endPoint = CGPoint(x: currX + 25, y: currY)
                default:
                    break;
                }
                
                curPath.addLine(to: endPoint)
                
                let rectLayer = CAShapeLayer()
                
                let rect2 = CGRect(origin: CGPoint(x: currPoint.x - 5, y: currPoint.y - 5), size: CGSize(width: 10, height: 10))
                let nodeRect = UIBezierPath(rect: rect2)
                
                rectLayer.path = nodeRect.cgPath
                rectLayer.strokeColor = UIColor.green.cgColor
                if (i == dirs.count - 1) {
                    rectLayer.strokeColor = UIColor.red.cgColor
                }
                
                self.layer.addSublayer(rectLayer)
            }
            
            curLayer.path = curPath.cgPath
            curLayer.strokeColor = UIColor.green.cgColor
            curLayer.lineWidth = 2

            self.layer.addSublayer(curLayer)
        }
        
        rect = CGRect(origin: CGPoint(x: halfWidth - 12.5, y: height - 25), size: CGSize(width: 25, height: 25))
        let homeRect = UIBezierPath(rect: rect)
        UIColor.black.setFill()
        homeRect.fill()
        
        let homeLayer = CAShapeLayer()
        homeLayer.path = homeRect.cgPath
        homeLayer.strokeColor = UIColor.black.cgColor
        
        self.layer.addSublayer(homeLayer)
    }
    
    public func drawPoints() {
        path.removeAllPoints()
        path = UIBezierPath()
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
}
