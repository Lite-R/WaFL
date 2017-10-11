//
//  ViewController.swift
//  Kanna_Attempt_1
//
//  Created by Sahitya Mohan Lal on 04/08/2017.
//  Copyright © 2017 Sahitya Mohan Lal. All rights reserved.
//

import UIKit
import Foundation
import Kanna

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var dishesTable: UITableView!
    @IBOutlet weak var cafeTitle: UILabel!
    @IBOutlet weak var pickerCafe: UIPickerView!
    @IBOutlet weak var closedLabel: UILabel!
    
    var dishes = [String]()
    var prices = [String]()
    var cafetarias = [String]()
    var listOfURLS = [String]()
    var selectedURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closedLabel.isHidden = true // Hide Closed Message
        // Do any additional setup after loading the view, typically from a nib.
        populateUIPicker()
        self.dishesTable.backgroundColor = UIColor.black
        self.pickerCafe.dataSource = self;
        self.pickerCafe.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //---UIPickerView Work Begins Here ---
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return cafetarias.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //self.textBox.text = self.list[row]
        selectedURL = listOfURLS[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label: UILabel
        if let view = view as? UILabel { label = view }
        else { label = UILabel() }
        
        label.text = cafetarias[row]
        label.textAlignment = .center
        label.font = UIFont(name: "Steiner", size: 13)
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }
    
    fileprivate func populateUIPicker() {
        guard let mainURL = URL(string: "http://speiseplan.studierendenwerk-hamburg.de/") else {
            return
        }
        
        do {
            let myCafe = try String(contentsOf: mainURL, encoding: String.Encoding.utf8)
            if let mainDOC = HTML(html: myCafe, encoding: .utf8) {
                print(mainDOC.title ?? "TitleNotfound")
                for cafe in mainDOC.xpath("//div[@id='subnavigation']/ul/li") {
                    let trimmedString = cafe.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
                    if !cafetarias.contains(trimmedString){
                        cafetarias.append(trimmedString)
                    }
                }
                for cafeURL in mainDOC.xpath("//div[@id='subnavigation']//a/@href") {
                    var cafeNumber = ""
                    let trimmedString = cafeURL.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
                    cafeNumber = String(trimmedString.characters.suffix(3))
                    let urlAddress = String(format: "http://speiseplan.studierendenwerk-hamburg.de/de/%@/2017/0/", cafeNumber)
                    if !listOfURLS.contains(urlAddress){
                        listOfURLS.append(urlAddress)
                    }
                }
            }
            
        }   catch let error as NSError {
            print("Error: Unable to Open Main HTML. \(error)")
        }
    }
    
    
    //---Table Work Begins Here ---
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dishes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DishesTableViewCell
        cell.dishesLabel.text = dishes[indexPath.row]
        cell.pricesLabel.text = prices[indexPath.row]
        return cell
    }
    
    
    //---Button Work Starts Here ---
    
    @IBAction func buttonPress(_ sender: UIButton) {
        print("We touched this button")
        networkConnect()
    }
    

    fileprivate func networkConnect() {
        //guard let url = URL(string: "http://speiseplan.studierendenwerk-hamburg.de/de/531/2017/0/") else {
        guard let url = URL(string: selectedURL) else {

            return
        }
        
        print("Stayin Alive...")
        
        dishes.removeAll() //Remove older data (if any) before re-populating
        prices.removeAll() //Remove older data (if any) before re-populating
        
        do {
            let myHTMLString = try String(contentsOf: url, encoding: String.Encoding.utf8)
            if let doc = HTML(html: myHTMLString, encoding: .utf8) {
                print(doc.title ?? "TitleNotfound")
                
                for title in doc.xpath("//div[@id='cafeteria']/h1") {
                    cafeTitle.text = title.text
                }
                
                for product in doc.xpath("//td[@class='dish-description']/text()[1]") {
                    let trimmedString = product.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
                    let trimParabolas = trimmedString.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
                    dishes.append(trimParabolas)
               }
                
                for price in doc.xpath("//td[@class='price'][1]") {
                    let price1 = price.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) ?? ""
                    prices.append(price1)
                }
            }
        }   catch let error as NSError {
            print("Error: Unable to Open Cafe HTML. \(error)")
        }
        if (dishes.isEmpty) {
            //---Mensa Is Closed Probably ---
            dishesTable.isHidden = true // Hide Table
            closedLabel.text = "Sorry, this Mensa appears to be currently closed!!" //@TO-DO: Fix URL number from listOfURLS match and open cafe URL -> Add the error on the contents xpath to this label
            closedLabel.isHidden = false //Un-hide Closed Message.
            }
        else {
            closedLabel.isHidden = true
            dishesTable.isHidden = false
            dishesTable.reloadData()
        }
    }
}
