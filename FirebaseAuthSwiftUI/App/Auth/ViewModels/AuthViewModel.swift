import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var isError: Bool = false
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    init() {
        Task {
            await loadCurrentUser()
        }
    }
    
    // MARK: - Uygulama ilk yüklendiğinde mevcut(current) user yüklenecek
    func loadCurrentUser() async {
        // Mevcut kullanıcı var mı veya boş mu onu kontrol ediyor
        if let user = auth.currentUser {
            
            // açık olan hesap kullanıcısı, kullanıcı oturumuna(user session) atanıyor
            userSession = user
            await fetchUser(by: user.uid)
        }
    }
    
    
    //MARK: - Login sayfasında bu fonksiyon çalışacak
    func login(email: String, password: String) async {
        do {
            //Authentication'daki signIn email ve password ile giriş yapılıyor
            let authResult = try await auth.signIn(withEmail: email, password: password)
            
            //kullanıcı oturumununa giriş yapan kullanıcı, kullanıcı oturumuna(user session) atanıyor
            userSession = authResult.user
            
            await fetchUser(by: authResult.user.uid)
        } catch {
            isError = true
        }
    }
    
    //MARK: - Bir User hesabı create yani oluşturuluyor
    func createUser(email: String, fullName: String, password: String) async {
        do {
            //auth'a signIn email ve password ile kayıt yapılıyor
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            
            await storeUserInFirestore(uid: authResult.user.uid, email: email, fullName: fullName)
        } catch {
            isError = true
        }
    }
         
    
    //MARK: Firestore'a bir User verisi kaydediliyor
    func storeUserInFirestore(uid: String, email: String, fullName: String) async {
        let user = User(uid: uid, email: email, fullName: fullName)
        
        do {
            //MARK: Burada firestore'a "users" collectionPath'li document olaraktan kaydediliyor.
            try firestore.collection("users").document(uid).setData(from: user)
        } catch {
            isError = true
        }
    }
       
    
    //MARK: Firestore'daki kullanıcı uid ile fetch ediliyor
    func fetchUser(by uid: String) async {
        do {
            //MARK: Burada firestore'a kaydedilen "users" collectionPath'li document alınıp currentUser(User struct'ına)'a kaydediliyor.
            let document = try await firestore.collection("users").document(uid).getDocument()
            currentUser = try document.data(as: User.self)
        } catch {
            isError = true
        }
    }
    
    func signOut() {
        do {
            userSession = nil
            currentUser = nil
            
            try auth.signOut()
        } catch {
            isError = true
        }
    }
    
    func deleteAccount() async {
        do {
            userSession = nil
            currentUser = nil
            deleteUser(by: auth.currentUser?.uid ?? "")
            
            try await auth.currentUser?.delete()
        } catch {
            isError = true
        }
    }
    
    private func deleteUser(by uid: String) {
        firestore.collection("users").document(uid).delete()
    }
    
    
    func resetPassword(by email: String) async {
        do {
            try await auth.sendPasswordReset(withEmail: email)
        } catch {
            isError = true
        }
    }
}
