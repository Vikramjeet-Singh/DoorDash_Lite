//
//  ViewController.swift
//  DoorDashLite
//
//  Created by Vikramjeet Singh on 4/6/18.
//  Copyright © 2018 Vikramjeet Singh. All rights reserved.
//

import UIKit

final class AddressViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension AddressViewController {
    
    // MARK: - Unwind Segue
    
    @IBAction func closeNearbyList(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }
}

