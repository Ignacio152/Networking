//
//  TableViewController.swift
//  Networking
//
//  Created by Ignas Pileckas on 11/12/2018.
//  Copyright © 2018 Ignas Pileckas. All rights reserved.
//

import UIKit
import PlainPing

class TableViewController: UITableViewController{
    
    var pings = [String]()
    var pinged = [String]()
    
    let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        populateArray()
    }
    
    func populateArray(){
        var numOfAddresses = 0
        
        while numOfAddresses<255{
            pings.append("192.168.1.\(numOfAddresses+1)")
            numOfAddresses+=1
        }
    }
    
    //MARK:- Ping Function
    func pingNext(){
        
        guard pings.count > 0 else {
            return
        }
        let ping = pings.removeFirst()
        
        PlainPing.ping(ping, withTimeout: 3.0, completionBlock: { (timeElapsed:Double?, error:Error?) in
            if let latency = timeElapsed{
                print("\(ping) latency (ms): \(latency)")
                self.pinged.append("\(ping) - Reachable")
                self.tableView.reloadData()
            }
        })
        pingNext()
    }
    
    func runPingTest(with completion: @escaping () -> ()){
        
        let group = DispatchGroup()
        
        concurrentQueue.sync {
            group.enter()
            self.pingNext()
            group.leave()
        }
        group.notify(queue: DispatchQueue.main) {
            completion()
        }
    }

    
    @IBAction func runButtonPressed(_ sender: UIButton) {
        
        runPingTest(with: {
            print("####All hosts pinged")
        })
        
        
        pinged = [String]()
        self.populateArray()
        
}

    //MARK:- TableViewMethods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = pinged[indexPath.row]
        cell.textLabel?.textColor = UIColor.white

        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pinged.count
    }


}
