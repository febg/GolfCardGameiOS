//
//  TutorialViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-19.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, TutorialPageDelegate {
  func setControlConfig(count: Int) {
    pageControlConfig(count: count)
  }
  
  func updateControl(at: Int) {
      pageControl.currentPage = at
  }
  

  
  @IBOutlet weak var pageControl: UIPageControl!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "tutorialSegue" {
      if let childVC = segue.destination as? TutorialPageViewController {
        //Some property on ChildVC that needs to be set
        childVC.tutorialPageDelegate = self
      }
    }
  }
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  private func pageControlConfig(count: Int) {
        pageControl.numberOfPages = count
        pageControl.currentPage = 0
  }

}
