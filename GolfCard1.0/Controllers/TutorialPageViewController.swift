//
//  TutorialPageViewController.swift
//  GolfCard1.0
//
//  Created by Felipe Ballesteros on 2018-06-18.
//  Copyright © 2018 Felipe Ballesteros. All rights reserved.
//

import UIKit

protocol TutorialPageDelegate: class {
  func setControlConfig(count: Int)
  func updateControl(at: Int)
}

extension TutorialPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    
    guard let currentIndex = tutorialViewList.index(of: viewController) else {
      return nil
    }
    let previousIndex = currentIndex - 1
    if previousIndex < 0 || previousIndex >= tutorialViewList.count { return nil }
    return tutorialViewList[previousIndex]
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let currentIndex = tutorialViewList.index(of: viewController) else {
      return nil
    }
    let nextIndex = currentIndex + 1
    if nextIndex < 0 || nextIndex >= tutorialViewList.count { return nil }
    return tutorialViewList[nextIndex]
  }
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    guard
      let currentViewController = viewControllers?.first,
      let index = tutorialViewList.index(of: currentViewController)
      else{
        return
    }
      print("updating")
      tutorialPageDelegate?.updateControl(at: index)
  }
}

class TutorialPageViewController: UIPageViewController {
  
  private(set) lazy var tutorialViewList: [UIViewController] = {
    return [getViewController(number: 0),
            getViewController(number: 1),
            getViewController(number: 2),
            getViewController(number: 3)]
  }()
  
  weak var tutorialPageDelegate: TutorialPageDelegate?
  
  @IBOutlet weak var pageControl: UIPageControl!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let firstViewController = tutorialViewList.first {
      setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
    }
    
    dataSource = self
    delegate = self
    tutorialPageDelegate?.setControlConfig(count: tutorialViewList.count)
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  private func getViewController(number: Int) -> UIViewController {
    return UIStoryboard(name: "Main", bundle: nil) .
      instantiateViewController(withIdentifier: "TutorialViewController_\(number)")
  }
}

