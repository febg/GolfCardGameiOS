//
//  FirstTutorialViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-23.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

class FirstTutorialViewController: UIViewController {

    @IBOutlet private var cards: [UIButton]!
  
   @IBAction private func cardAction(_ sender: UIButton){
    print("you touched card \(sender.tag)")
  }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
