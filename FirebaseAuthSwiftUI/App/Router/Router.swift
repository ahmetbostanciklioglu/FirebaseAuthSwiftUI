import SwiftUI


final class Router: ObservableObject {
    
    @Published var navPath = NavigationPath()
    
    enum AuthFlow: Hashable, Codable {
        case login,  createAccount, profile, forgotPassword, emailSent
    }
    
    func navigate(to destination: AuthFlow) {
        navPath.append(destination)
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
