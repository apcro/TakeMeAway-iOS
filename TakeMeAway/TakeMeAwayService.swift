//
//  TakeMeAwayService.swift
//  TakeMeAway
//
// (C) 2017-present Tom Gordon, Rob Reeve & Junaid Rahim

import Foundation
import Moya
import Moya_Marshal

struct QueuedRequest {
    var target: TakeMeAwayAPI
    var success: (Response) -> Void
    var error: (TakeMeAwayServiceError) -> Void
    var failure: (MoyaError) -> Void
}

final class TakeMeAwayService {
    
    private(set) var reachability: ReachabilityManager!

    enum AuthStatus {
        case loggedOut
        case registering
        case authenticating
        case authenticated
    }
    private var status: AuthStatus = .loggedOut
    
    
    private let authPlugin = TakeMeAwayHMACPlugin()
    private let debugPlugin = NetworkLoggerPlugin(verbose: true)
    public var authToken: String? {
        didSet {
            if authToken != nil {
                status = .authenticated
                let tokenPlugin = TakeMeAwayTokenPlugin(tokenClosure: self.authToken!)
                provider = MoyaProvider<TakeMeAwayAPI>(plugins: [tokenPlugin, authPlugin, debugPlugin])
            } else {
                status = .loggedOut
                provider = MoyaProvider<TakeMeAwayAPI>(plugins: [authPlugin, debugPlugin])
            }
            
        }
    }
    
    private var provider: MoyaProvider<TakeMeAwayAPI>
    private var queuedRequests: [QueuedRequest] = []
    
    init(reachabilityManager: ReachabilityManager, token: String? = nil, creds: LoginCredentials? = nil) {
        self.reachability = reachabilityManager
        if token != nil {
            authToken = token
            status = .authenticated
            let tokenPlugin = AccessTokenPlugin(tokenClosure: token!)
            provider = MoyaProvider<TakeMeAwayAPI>(plugins: [tokenPlugin, authPlugin, debugPlugin])
        } else {
            // create provider without token auth because we don't have token yet
            provider = MoyaProvider<TakeMeAwayAPI>(plugins: [authPlugin, debugPlugin])
            
            // check for username and password
            if let creds = creds {
                authenticate(username: creds.username, password: creds.password!, type: "normal", success: nil, failure: nil)
            }
        }
        
        // listen for reachability and process queued requests
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(reachabilityDidChange(_:)), name: NSNotification.Name.reachabilityChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func reachabilityDidChange(_: Notification) {
        if reachability.isOnline() {
            processQueuedRequests()
        }
    }
    
    
    // generic function for all requests
    public func request(target: TakeMeAwayAPI, success successCallback: @escaping (Response) -> Void,
                                     error errorCallback: @escaping (TakeMeAwayServiceError) -> Void,
                                     failure failureCallback: @escaping (MoyaError) -> Void) {
        
        if reachability.isOnline() {
            // filter requests that require authorisation
            if target.authorizationType != .none {
                
                switch status {
                    
                case .loggedOut:
                    // return error saying we aren't authenticated
                    errorCallback(.notYetAuthenticated)
                    return
                    
                case .authenticating, .registering:
                    // queue request for when we get our auth response back
                    let queuedRequest = QueuedRequest(target: target, success: successCallback, error: errorCallback, failure: failureCallback)
                    queuedRequests.append(queuedRequest)
                    print("queued request to \(target.path)")
                    return
                    
                case .authenticated:
                    // safe to fire request
                    break
                }
            }
            
            executeRequest(target: target, successCallback: successCallback, errorCallback: errorCallback, failureCallback: failureCallback)
        } else {
            errorCallback(.serviceNotAvailable)
            let queuedRequest = QueuedRequest(target: target, success: successCallback, error: errorCallback, failure: failureCallback)
            queuedRequests.append(queuedRequest)
            print("queued request to \(target.path)")
        }
    }
    
    // convenience method that authenticates and stores token for future requests automatically
    public func authenticate(username: String, password: String, type: String, success successCallback: ((LoginResponse) -> Void)?,
                             failure failureCallback: ((Error) -> Void)?) {
        
        if reachability.isOnline() {
            // change status so we know to queue requests received in the mean time
            status = .authenticating
            
            // send auth request
            provider.request(.login(username: username, password: password, type: type)) { (result) in
                
                switch result {
                case .success(let response):
                    do {
                        // convert response to model and save token for future requests
                        let loginResponse: LoginResponse = try response.map(to: LoginResponse.self)
                        self.status = .authenticated
                        self.authToken = loginResponse.token
                        
                        // hand response model back via callback
                        if let successCallback = successCallback {
                            successCallback(loginResponse)
                        }
                        
                        // process queued requests
                        self.processQueuedRequests()
                    } catch {
                        // likely serialisation error?
                        print("Authentication failed: \(error)")
                        if let failureCallback = failureCallback {
                            failureCallback(error)
                        }
                    }
                    
                case .failure(let error):
                    if let failureCallback = failureCallback {
                        failureCallback(error)
                    }
                }
            }
        } else {
            if let failureCallback = failureCallback {
                failureCallback(TakeMeAwayServiceError.serviceNotAvailable)
            }
        }
        
    }
    
    public func register(name: String, email: String, password: String, success successCallback: ((RegisterResponse) -> Void)?,
                         failure failureCallback: ((Error) -> Void)?) {
        
        if reachability.isOnline() {
            status = .registering
            
            // fire request
            provider.request(.register(email: email, password: password, name: name, locale: "en-gb")) { (result) in
                switch result {
                case .success(let response):
                    do {
                        let registerResponse: RegisterResponse = try response.map(to: RegisterResponse.self)
                        if registerResponse.token != nil {
                            // registered successfully - save token and consider authenticated
                            self.authToken = registerResponse.token
                            self.status = .authenticated
                            
                            // hand response model back via callback
                            if let successCallback = successCallback {
                                successCallback(registerResponse)
                            }
                            
                            // process queued requests
                            self.processQueuedRequests()
                            
                        } else {
                            // no token in response, registration failed
                            self.status = .loggedOut
                        }
                    } catch {
                        // likely serialisation error
                        print("Registration failed: \(error)")
                    }
                case .failure(let error):
                    if let failureCallback = failureCallback {
                        failureCallback(error)
                    }
                }
            }
        } else {
            if let failureCallback = failureCallback {
                failureCallback(TakeMeAwayServiceError.serviceNotAvailable)
            }
        }
    }
    
    public func logout() {
        authToken = nil
    }
    
    // MARK: Private API
    
    private func processQueuedRequests() {
        let toProcess = queuedRequests
        queuedRequests = []
        for req in toProcess {
            print("retrying queued request for \(req.target.path)")
            request(target: req.target, success: req.success, error: req.error, failure: req.failure)
        }
    }
    
    private func executeRequest(target: TakeMeAwayAPI, successCallback: @escaping (Response) -> Void, errorCallback: @escaping (TakeMeAwayServiceError) -> Void, failureCallback: @escaping (MoyaError) -> Void) {
        provider.request(target) { (result) in
            switch result {
            case .success(let response):
                if response.statusCode == 400 {
                    // auth token has probably expired, try to re-authenticate, otherwise assume user is logged out
                    // TODO: reauthenticate!
                    errorCallback(TakeMeAwayServiceError.requestNotAuthorised)
                }
                else if response.statusCode >= 200 && response.statusCode <= 300 {
                    successCallback(response)
                } else {
                    let error = TakeMeAwayServiceError.invalidResponseType
                    errorCallback(error)
                }
            case .failure(let error):
                failureCallback(error)
            }
        }
    }
}


