import Foundation
import AppAuth
import Combine
import Security

class GoogleAuthService: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var userEmail: String? = nil
    @Published var error: String? = nil
    
    private var authState: OIDAuthState? {
        didSet {
            isSignedIn = authState?.isAuthorized ?? false
            if isSignedIn {
                saveAuthState()
            } else {
                clearAuthState()
            }
        }
    }
    
    // MARK: - Google OAuth2 Config
    private let clientID = "1085183123334-fadglpni9ukaktssjdgqkgauf2kb6m75.apps.googleusercontent.com" 
    private let redirectURI = "com.googleusercontent.apps.1085183123334-fadglpni9ukaktssjdgqkgauf2kb6m75:/oauthredirect"
    private let issuer = URL(string: "https://accounts.google.com")!
    private let scopes = [
        OIDScopeOpenID,                // "openid"
        OIDScopeProfile,               // "profile"
        OIDScopeEmail,                 // "email"
        "https://www.googleapis.com/auth/calendar",
        "https://www.googleapis.com/auth/gmail.modify"
    ]
    
    private var currentAuthorizationFlow: OIDExternalUserAgentSession?
    private let keychainKey = "GoogleAuthState"
    
    init() {
        restoreAuthState()
    }
    
    // MARK: - Sign In
    func signIn(presentingWindow: NSWindow) {
        OIDAuthorizationService.discoverConfiguration(forIssuer: issuer) { config, error in
            guard let config = config else {
                DispatchQueue.main.async { self.error = error?.localizedDescription }
                return
            }
            let request = OIDAuthorizationRequest(
                configuration: config,
                clientId: self.clientID,
                clientSecret: nil,
                scopes: self.scopes,
                redirectURL: URL(string: self.redirectURI)!,
                responseType: OIDResponseTypeCode,
                additionalParameters: nil
            )
            self.currentAuthorizationFlow = OIDAuthState.authState(
                byPresenting: request,
                presenting: presentingWindow
            ) { authState, error in
                if let authState = authState {
                    self.authState = authState
                    self.fetchUserInfo()
                } else {
                    DispatchQueue.main.async { self.error = error?.localizedDescription }
                }
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        authState = nil
        userEmail = nil
        clearAuthState()
    }
    
    // MARK: - Token Access
    func getAccessToken(completion: @escaping (String?) -> Void) {
        authState?.performAction { accessToken, _, error in
            completion(accessToken)
        }
    }
    
    // MARK: - User Info
    private func fetchUserInfo() {
        getAccessToken { token in
            guard let token = token else { return }
            var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v3/userinfo")!)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, _, _ in
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let email = json["email"] as? String {
                    DispatchQueue.main.async { self.userEmail = email }
                }
            }.resume()
        }
    }
    
    // MARK: - Persistent Auth State (Keychain)
    private func saveAuthState() {
        guard let authState = authState else { return }
        let archived = try? NSKeyedArchiver.archivedData(withRootObject: authState, requiringSecureCoding: true)
        guard let data = archived else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func restoreAuthState() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data {
            if let restored = try? NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data) {
                self.authState = restored
                self.fetchUserInfo()
            }
        }
    }
    
    private func clearAuthState() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]
        SecItemDelete(query as CFDictionary)
    }
} 