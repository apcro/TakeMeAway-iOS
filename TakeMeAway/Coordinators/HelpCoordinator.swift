//
//  HelpCoordinator.swift
//  TakeMeAway
//
//  Created by Luke Oglesby on 08/01/2018.
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim
//

import Foundation
import Coordinator

final class HelpCoordinator: NavigationCoordinator, NeedsDependency {
    var dependencies: AppDependency? {
        didSet { updateChildCoordinatorDependencies() }
    }
    
    override init(rootViewController: UINavigationController? = nil) {
        let nc = rootViewController ?? UINavigationController()
        super.init(rootViewController: nc)
        
        nc.delegate = self
    }
    
    //    Declaration of all local pages (ViewControllers)
    enum Page {
        case onboarding
        case faq
        case termsAndConditions
        case privacy
        case feedback
        case reviews
    }
    var page: Page = .faq
    
    // set page
    func display(page: Page) {
        rootViewController.parentCoordinator = self
        rootViewController.delegate = self
        
        setupActivePage(page)
    }
    
    //    Coordinator lifecycle
    override func start(with completion: @escaping () -> Void = {}) {
        super.start(with: completion)
        
        setupActivePage()
    }
    
    //    MARK:- Coordinating Messages
    //    must be placed here, due to current Swift/ObjC limitations

    override func submitFeedback(sender: Any?, feedback: String, completion: @escaping (Error?) -> Void) {
        guard let api = dependencies?.apiManager else {
            completion( nil ) // TODO: add error with description explaining we couldn't get a reference to the api manager
            return
        }
        api.request(target: .submitFeedback(feedback: feedback), success: {(response) in
            completion(nil)
        }, error: {(error) in
            completion(error)
        }, failure: {(error) in
            completion(error)
        })
    }

}

fileprivate extension HelpCoordinator {
    func setupActivePage(_ enforcedPage: Page? = nil) {
        let p = enforcedPage ?? page
        page = p
        
        switch p {
        case .onboarding:
            
            let vc = OnboardingViewController.init(nibName: "OnboardingViewController", bundle: Bundle.main)
            if let helpManager = dependencies?.helpManager {
                vc.pages = helpManager.onboardingPages

                vc.edgesForExtendedLayout = [UIRectEdge.top, UIRectEdge.bottom]
            }
            show(vc)
        case .faq:
            let vc = TermsConditionsViewController.init(nibName: "TermsConditionsViewController", bundle: Bundle.main)
            if let helpManager = dependencies?.helpManager {
                vc.content = helpManager.faqURL
            }
            show(vc)
            
        case .termsAndConditions:
            let vc = TermsConditionsViewController.init(nibName: "TermsConditionsViewController", bundle: Bundle.main)
            if let helpManager = dependencies?.helpManager {
                vc.content = helpManager.termsURL
            }
            show(vc)
        
        case .privacy:
            let vc = TermsConditionsViewController.init(nibName: "TermsConditionsViewController", bundle: Bundle.main)
            if let helpManager = dependencies?.helpManager {
                vc.content = helpManager.privacyURL
            }
            show(vc)
            
        case .reviews:
            let vc = TermsConditionsViewController.init(nibName: "TermsConditionsViewController", bundle: Bundle.main)
            
            let uri = UserDefaults.standard.string(forKey: "reviewuri")
            
            vc.content = uri!
            show(vc)
            
        case .feedback:
            let vc = SendFeedbackViewController.init(nibName: "SendFeedbackViewController", bundle: Bundle.main)
            show(vc)
        }
    }
}
