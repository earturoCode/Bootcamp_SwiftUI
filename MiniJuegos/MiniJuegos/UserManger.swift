import Foundation

// Variables para el usuario
struct User: Codable {
    let username: String
    let email: String
    let password: String
}

// UserManager Class
class UserManager {
    static let shared = UserManager()
    private let userDefaultsKey = "RegisteredUsers"
    
    private init() {}
    
    // Guardar los Users
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
    
    func getAllUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    // Validar el Login
    func validateLogin(username: String, password: String) -> (success: Bool, user: User?) {
        let users = getAllUsers()
        
        if let user = users.first(where: {
            $0.username.lowercased() == username.lowercased() && $0.password == password
        }) {
            return (true, user)
        }
        
        return (false, nil)
    }
    
    // Verificar si el Usu existe
    func usernameExists(_ username: String) -> Bool {
        let users = getAllUsers()
        return users.contains(where: { $0.username.lowercased() == username.lowercased() })
    }
    
    // Verificar si el correo ya existe
    func emailExists(_ email: String) -> Bool {
        let users = getAllUsers()
        return users.contains(where: { $0.email.lowercased() == email.lowercased() })
    }
    
    // para mantener sesión abierta
    func getCurrentUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: "CurrentUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
    
    // para mantener sesión abierta
    func setCurrentUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "CurrentUser")
        }
    }
    
    // Logout
    func logout() {
        UserDefaults.standard.removeObject(forKey: "CurrentUser")
    }
}

