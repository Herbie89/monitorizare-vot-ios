//  Created by Code4Romania

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = MVColors.black.color
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let guideButton = UIBarButtonItem(image: UIImage(named:"guideIcon"), style: .plain, target: self, action: #selector(RootViewController.pushGuideViewController))
        let callButton = UIBarButtonItem(image: UIImage(named:"callIcon"), style: .plain, target: self, action: #selector(RootViewController.performCall))
        self.navigationItem.rightBarButtonItems = [callButton, guideButton]
    }
    
    func pushGuideViewController() {
        if let _ = self.navigationController?.childViewControllers.last as? GuideViewController {
            return
        }
        
        if let guideViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GuideViewController") as? GuideViewController {
            self.navigationController?.pushViewController(guideViewController, animated: true)
        }
    }
    
    func performCall() {
        let phoneCallPath = "telprompt://0800080200"
        if let phoneCallURL = NSURL(string: phoneCallPath) {
            UIApplication.shared.openURL(phoneCallURL as URL)
        }
    }

}
