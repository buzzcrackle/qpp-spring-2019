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
    
    let defaults = UserDefaults.standard
    
    var currentPath = [Int()]
    var currentName = ""
    var pathNames = [String()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
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
    
    @IBAction func editButton(_ sender: Any) {
        if (currentName != "") {
            defaults.set(true, forKey: "isEditting")
            defaults.set(currentName, forKey: "currentName")
            performSegue(withIdentifier: "addModal", sender: self)
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        currentName = ""
        defaults.set(currentName, forKey: "currentName")
        performSegue(withIdentifier: "addModal", sender: self)
    }
    
    @IBAction func deliverButton(_ sender: Any) {
        pathNames = defaults.array(forKey: "paths") as! [String]
        print(pathNames)
        pickerView.reloadAllComponents()
        
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pathNames.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pathNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentName = pathNames[row]
        currentPath = defaults.array(forKey: pathNames[row]) as! [Int]
        defaults.set(currentName, forKey: "currentName")
        print(currentPath)
        mapVIew.drawPoints()
    }
}

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
