//
//  LandingViewController.swift
//  FoundAndLostItems
//
//  Created by Maram F on 11/06/1443 AH.
//

import UIKit
import Lottie

struct AnimatHeader{
    var animationViews : AnimationView?
    var title : String?
    var description : String?
}

var headerSet = [AnimatHeader]()

class LandingViewController: UIViewController {
    @IBOutlet weak var appNameLabel: UILabel!{
        didSet{
            appNameLabel.text = "appName".localized
        }
    }
    var timer : Timer?
    @IBOutlet weak var headerControl: UIPageControl!
    @IBOutlet weak var LanguageButtonOutlet: UIButton!{
        didSet{
            LanguageButtonOutlet.setTitle("arEn".localized, for: .normal)
           
        }
        
    }
    
    @IBOutlet weak var headerCollectionView: UICollectionView!{
        didSet{
            headerCollectionView.delegate = self
            headerCollectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var viewBGOutlet: UIView!{
        didSet{
            viewBGOutlet.layer.cornerRadius = 15
            viewBGOutlet.layer.masksToBounds = true
            viewBGOutlet.layer.shadowOpacity = 0.2
            viewBGOutlet.layer.shadowRadius = 4
            viewBGOutlet.layer.masksToBounds = false
        }
    }
    @IBOutlet weak var registerButtonOutlet: UIButton!{
        didSet{
            registerButtonOutlet.setTitle("register".localized, for: .normal)
        }
    }
    
   
    
    @IBOutlet weak var loginButtonOutlet: UIButton!{
    
        didSet{
            loginButtonOutlet.setTitle("login".localized, for: .normal)
        }

    }
    var currentCellIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerSet = [AnimatHeader]()
        headerSet.append(AnimatHeader(animationViews: .init(name: "searchPic" ), title: "title1".localized, description: "desc1".localized))
        headerSet.append(AnimatHeader(animationViews: .init(name: "phonecallImage" ), title: "title2".localized, description: "desc2".localized))
        headerSet.append(AnimatHeader(animationViews: .init(name: "locationAnimation" ), title: "title3".localized, description: "desc3".localized))
        headerControl.numberOfPages = headerSet.count

        startTimer()
    }
    

    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(moveToNextIndex), userInfo: nil, repeats: true)
    }
    
    @objc func moveToNextIndex(){
        if currentCellIndex < headerSet.count-1{
            currentCellIndex += 1
        }else{
            currentCellIndex = 0
        }
     
        headerCollectionView.scrollToItem(at: IndexPath(item: currentCellIndex, section: 0), at: .centeredHorizontally, animated: true)
        headerControl.currentPage = currentCellIndex
    }
    
    @IBAction func infoButton(_ sender: UIButton) {
        Alert.showAlert(strTitle: "", strMessage: "Application Developed Maram Faqih \n For final project in \n Tuwaiq Academy", viewController: self)
    }
    @IBAction func changeLanguageButton(_ sender: UIButton) {
        var lang = ""
        if let userDefaultLang = UserDefaults.standard.string(forKey: "currentLanguage"){
                lang = userDefaultLang
        }
 
         if lang == "en" {

             lang = "ar"
             UIView.appearance().semanticContentAttribute = .forceRightToLeft

        }else{
  
            lang = "en"
            UIView.appearance().semanticContentAttribute = .forceLeftToRight

        }
       
        Bundle.setLanguage(lang)
        UserDefaults.standard.set(lang, forKey: "currentLanguage")
        
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = storyboard.instantiateInitialViewController()

    }
}
     }

extension LandingViewController:  UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return headerSet.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headerCell", for: indexPath) as! headerCollectionViewCell
     
        cell.titleCell.text = headerSet[indexPath.row].title
        cell.descriptionCell.text = headerSet[indexPath.row].description
        

        headerSet[indexPath.row].animationViews?.frame = cell.animationViewCell.bounds
        headerSet[indexPath.row].animationViews?.contentMode = .scaleAspectFit
        headerSet[indexPath.row].animationViews?.center = cell.animationViewCell.center
        
        headerSet[indexPath.row].animationViews?.loopMode = .loop
        headerSet[indexPath.row].animationViews?.animationSpeed = 0.6
        cell.animationViewCell.addSubview(headerSet[indexPath.row].animationViews!)
        headerSet[indexPath.row].animationViews?.play()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0,0,1)
        UIView.animate(withDuration: 1 , animations: {
              cell.layer.transform = CATransform3DMakeScale(1,1,1)
          })
    }
}
