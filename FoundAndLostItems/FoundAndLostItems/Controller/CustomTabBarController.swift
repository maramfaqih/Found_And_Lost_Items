//
//  CustomTabBarController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 26/05/1443 AH.
//

import UIKit

class CustomTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.items?[1].title = "My Post"
        tabBar.items?[4].title = "profile"
//        UITabBar.appearance().unselectedItemTintColor = UIColor(displayP3Red: 1, green: 1, blue: 1 , alpha: 1)
        UITabBar.appearance().unselectedItemTintColor = .black
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
