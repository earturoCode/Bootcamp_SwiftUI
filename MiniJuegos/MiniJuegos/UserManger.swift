import Foundation

// MARK: - User Model
struct User: Codable {
    let username: String
    let email: String
    let password: String
}

// MARK: - UserManager Class
class UserManager {
    static let shared = UserManager()
    private let userDefaultsKey = "RegisteredUsers"
    
    private init() {}
    
    // MARK: - Save User
    func saveUser(_ user: User) -> (success: Bool, message: String) {
        var users = getAllUsers()
        
        // Verificar si el usuario ya existe
        if users.contains(where: { $0.username.lowercased() == user.username.lowercased() }) {
            return (false, "El nombre de usuario ya está en uso")
        }
        
        // Verificar si el email ya existe
        if users.contains(where: { $0.email.lowercased() == user.email.lowercased() }) {
            return (false, "El correo electrónico ya está registrado")
        }
        
        // Agregar nuevo usuario
        users.append(user)
        
        // Guardar en UserDefaults
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            return (true, "Usuario registrado exitosamente")
        }
        
        return (false, "Error al guardar el usuario")
    }
    
    // MARK: - Get All Users
    func getAllUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    // MARK: - Validate Login
    func validateLogin(username: String, password: String) -> (success: Bool, user: User?) {
        let users = getAllUsers()
        
        if let user = users.first(where: {
            $0.username.lowercased() == username.lowercased() && $0.password == password
        }) {
            return (true, user)
        }
        
        return (false, nil)
    }
    
    // MARK: - Check if username exists
    func usernameExists(_ username: String) -> Bool {
        let users = getAllUsers()
        return users.contains(where: { $0.username.lowercased() == username.lowercased() })
    }
    
    // MARK: - Check if email exists
    func emailExists(_ email: String) -> Bool {
        let users = getAllUsers()
        return users.contains(where: { $0.email.lowercased() == email.lowercased() })
    }
    
    // MARK: - Get current user (optional - para mantener sesión)
    func getCurrentUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: "CurrentUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    // MARK: - Set current user (optional - para mantener sesión)
    func setCurrentUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "CurrentUser")
        }
    }
    
    // MARK: - Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "CurrentUser")
    }
    
    // MARK: - Debug: Print all users (solo para desarrollo)
    func printAllUsers() {
        let users = getAllUsers()
        print("=== USUARIOS REGISTRADOS ===")
        for user in users {
            print("Usuario: \(user.username), Email: \(user.email)")
        }
        print("=============================")
    }
}

