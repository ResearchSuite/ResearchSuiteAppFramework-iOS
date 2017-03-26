//
//  RSAFApplicationDelegate.swift
//  Pods
//
//  Created by James Kizer on 3/22/17.
//
//

import UIKit
import ResearchKit
import ReSwift
import ResearchSuiteResultsProcessor
import ResearchSuiteTaskBuilder

open class RSAFApplicationDelegate: UIResponder, UIApplicationDelegate, ORKPasscodeDelegate {
    
    open var window: UIWindow?
    
//    var initializeStateClosure: (() -> Void)?
//    var resetStateClosure: (() -> Void)?
    
    public var reduxManager: RSAFReduxManager?
    
    public var reduxStore: Store<RSAFCombinedState>? {
        return reduxManager?.store
    }
    
    //the following are subscribers
    var persistenceManager: RSAFCombinedPersistentStoreSubscriber?
    var reduxStateManager: RSAFReduxStateManager?
    
    var taskBuilderManager: RSAFTaskBuilderManager?
    var resultsProcessorManager: RSAFResultsProcessorManager?
    
    open func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        if UserDefaults.standard.object(forKey: "FirstRun") == nil {
            UserDefaults.standard.set("1stRun", forKey: "FirstRun")
            UserDefaults.standard.synchronize()
            do {
                try ORKKeychainWrapper.resetKeychain()
            } catch let error {
                print("Got error \(error) when resetting keychain")
            }
        }
        
        self.initializeState()
        
        if let store = self.reduxStore,
            let state = store.state as? RSAFCombinedState {
            self.showViewController(state: state)
        }

        return true
    }
    
    open func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        lockScreen()
        return true
    }
    
//    open func setLoggedInAndShowViewController(loggedIn: Bool, completion: @escaping () -> Void) {
//        let store = self.reduxStoreManager?.store
//        store?.dispatch(CTFActionCreators.setLoggedIn(loggedIn: loggedIn), callback: { (state) in
//            self.showViewController(state: state)
//            completion()
//        })
//    }
    
    open func isSignedIn(state: RSAFCombinedState) -> Bool {
        guard let coreState = state.coreState as? RSAFCoreState else {
            return false
        }
        return RSAFCoreSelectors.isLoggedIn(coreState)
    }
    
    open func showViewController(state: RSAFCombinedState) {
        
        guard let window = self.window,
            let coreState = state.coreState as? RSAFCoreState else {
            return
        }
        
        //check for case where a failure occurs during login
        if isSignedIn(state: state) && !ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            self.signOut()
        }
        
        if isSignedIn(state: state) && ORKPasscodeViewController.isPasscodeStoredInKeychain() {
            
            if let vc = self.instantiateMainViewController(),
                vc as? RSAFRootViewControllerProtocol != nil {
                window.rootViewController = vc
                return
            }
            
        }
        else {
            if let vc = self.instantiateOnboardingViewController(),
                vc as? RSAFRootViewControllerProtocol != nil {
                window.rootViewController = vc
                return
            }
        }
        
        return
    }
    
    open func instantiateMainViewController() -> UIViewController? {
        return nil
    }
    
    open func instantiateOnboardingViewController() -> UIViewController? {
        return nil
    }
    
    
    /**
     Convenience method for presenting a modal view controller.
     */
    open func presentViewController(_ viewController: UIViewController, animated: Bool, completion: (() -> Void)?) {
        guard let rootVC = self.window?.rootViewController else { return }
        var topViewController: UIViewController = rootVC
        while (topViewController.presentedViewController != nil) {
            topViewController = topViewController.presentedViewController!
        }
        topViewController.present(viewController, animated: animated, completion: completion)
    }
    
    /**
     Convenience method for transitioning to the given view controller as the main window
     rootViewController.
     */
    open func transition(toRootViewController: UIViewController, animated: Bool) {
        guard let window = self.window else { return }
        if (animated) {
            UIView.transition(with: window,
                              duration: 0.6,
                              options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: {
                                window.rootViewController = toRootViewController
            },
                              completion: nil)
        }
        else {
            window.rootViewController = toRootViewController
        }
    }
    
    // ------------------------------------------------
    // MARK: Passcode Display Handling
    // ------------------------------------------------
    
    open weak var passcodeViewController: UIViewController?
    
    /**
     Should the passcode be displayed. By default, if there isn't a catasrophic error,
     the user is registered and there is a passcode in the keychain, then show it.
     */
    open func shouldShowPasscode() -> Bool {
        return (self.passcodeViewController == nil) &&
            ORKPasscodeViewController.isPasscodeStoredInKeychain()
    }
    
    open func instantiateViewControllerForPasscode() -> UIViewController? {
        return ORKPasscodeViewController.passcodeAuthenticationViewController(withText: nil, delegate: self)
    }
    
    open func lockScreen() {
        
        guard self.shouldShowPasscode(), let vc = instantiateViewControllerForPasscode() else {
            return
        }
        
        window?.makeKeyAndVisible()
        
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .coverVertical
        
        passcodeViewController = vc
        presentViewController(vc, animated: false, completion: nil)
    }
    
    open func dismissPasscodeViewController(_ animated: Bool) {
        self.passcodeViewController?.presentingViewController?.dismiss(animated: animated, completion: nil)
    }
    
    open func resetPasscode() {
        
        // Dismiss the view controller unanimated
        dismissPasscodeViewController(false)
        
        self.signOut()
    }
    
    // MARK: ORKPasscodeDelegate
    
    open func passcodeViewControllerDidFinish(withSuccess viewController: UIViewController) {
        dismissPasscodeViewController(true)
    }
    
    open func passcodeViewControllerDidFailAuthentication(_ viewController: UIViewController) {
        // Do nothing in default implementation
    }
    
    open func passcodeViewControllerForgotPasscodeTapped(_ viewController: UIViewController) {
        
        let title = "Reset Passcode"
        let message = "In order to reset your passcode, you'll need to log out of the app completely and log back in using your email and password."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            self.resetPasscode()
        })
        alert.addAction(logoutAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    open func subscribeToStore(store: Store<RSAFCombinedState>) {
        //these should always exist
        store.subscribe(self.persistenceManager!)
        store.subscribe(self.reduxStateManager!)
    }
    
    open func unsubscribeFromStore(store: Store<RSAFCombinedState>) {
        
        store.unsubscribe(self.persistenceManager!)
        store.unsubscribe(self.reduxStateManager!)
        
    }
    
    
    open func resultsProcessorManager(store: Store<RSAFCombinedState>) -> RSAFResultsProcessorManager {
        return RSAFResultsProcessorManager(store: store, backEnd: RSAFFakeBackEnd())
    }
    
    open func taskBuilderManager(stateHelper: RSTBStateHelper) -> RSAFTaskBuilderManager {
        return RSAFTaskBuilderManager(stateHelper: stateHelper)
    }
    
    open func loadCombinedReducer() -> RSAFCombinedReducer {
        return RSAFCombinedReducer(
            coreReducer: RSAFCoreReducer(),
            middlewareReducer: RSAFBaseReducer(),
            appReducer: RSAFBaseReducer()
        )
    }
    
    open func loadPersistenceManager(stateManager: RSAFStateManager.Type) -> RSAFCombinedPersistentStoreSubscriber {
        return RSAFCombinedPersistentStoreSubscriber(
            coreSubscriber: RSAFCorePersistentStoreSubscriber(stateManager: stateManager),
            middlewareSubscriber: RSAFBasePersistentStoreSubscriber(stateManager: stateManager),
            appSubscriber: RSAFBasePersistentStoreSubscriber(stateManager: stateManager)
        )
    }
    
    
    open func initializeState() {
        
        let keychainStateManager:RSAFStateManager.Type = RSAFKeychainStateManager.self
        let persistenceManager = loadPersistenceManager(stateManager: keychainStateManager)
        let persistedState: RSAFCombinedState = persistenceManager.loadState()
        let combinedReducer: RSAFCombinedReducer = loadCombinedReducer()
        
        let storeManager: RSAFReduxManager = RSAFReduxManager(initialState: persistedState, reducer: combinedReducer)
        
        let reduxStateHelper = RSAFReduxStateManager(store: storeManager.store)
        let taskBuilderManager  = self.taskBuilderManager(stateHelper: reduxStateHelper)
        let resultsProcessorManager = self.resultsProcessorManager(store: storeManager.store)
        
        self.reduxManager = storeManager
        self.reduxStateManager = reduxStateHelper
        self.persistenceManager = persistenceManager
        self.taskBuilderManager = taskBuilderManager
        self.resultsProcessorManager = resultsProcessorManager

        self.subscribeToStore(store: storeManager.store)
        
    }
    
    open func resetState() {
        
        if let store = self.reduxManager?.store {
            self.unsubscribeFromStore(store: store )
        }
        
        self.reduxManager = nil
        self.persistenceManager = nil
        self.taskBuilderManager = nil
        self.resultsProcessorManager = nil
        
        RSAFKeychainStateManager.clearKeychain()
        
        self.initializeState()
        
        
    }
    
    open func signOut() {
        self.resetState()
    }
}
