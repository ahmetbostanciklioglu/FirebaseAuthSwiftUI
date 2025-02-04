import UIKit
import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}


@main
struct FirebaseAuthSwiftUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authViewModel = AuthViewModel()
    @ObservedObject private var router = Router()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.navPath, root: {
                ContentView()
                    .navigationDestination(for: Router.AuthFlow.self) { destination in
                        switch destination {
                        case .login:
                            LoginView()
                        case .createAccount:
                            CreateAccountView()
                        case .profile:
                            ProfileView()
                        case .forgotPassword:
                            ForgotPasswordView()
                        case .emailSent:
                            EmailSentView()
                        }
                    }
            })
            .environmentObject(authViewModel)
            .environmentObject(router)
        }
    }
}
