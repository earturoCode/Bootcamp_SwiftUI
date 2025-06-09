import UIKit        // Librería para interfaces gráficas en iOS
import Alamofire    // Librería para manejar peticiones HTTP

class APIService {
    static let shared = APIService() // Instancia singleton
    private init() {}                // Constructor privado para evitar múltiples instancias

    // Función para registrar un nuevo usuario
    func signup(email: String, pass: String) async throws {
        // Validación básica de campos vacíos
        guard !email.isEmpty, !pass.isEmpty else {
            print("Email o contraseña vacíos")
            return
        }
        
        // URL del endpoint de registro de Supabase
        let url = "https://lvmybcyhrbisfjouhbrx.supabase.co/auth/v1/signup"
        
        // Modelo con los datos que se enviarán en el cuerpo de la solicitud
        let modeloRegister = ModeloRegister(email: email, password: pass)
        
        // Cabeceras requeridas por la API
        let headers: HTTPHeaders = [
            "apikey": constants.apikey,                 // Clave de API
            "Content-Type": "application/json"         // Tipo de contenido JSON
        ]
        
        // Envío de la solicitud POST con los datos del nuevo usuario
        let response = try await AF.request(url,
                                            method: .post,
                                            parameters: modeloRegister,
                                            encoder: JSONParameterEncoder.default,
                                            headers: headers)
            .serializingDecodable(ModeloLoginResponse.self).value
        
        // Impresión del ID del nuevo usuario
        print("User ID: \(response.user.id)")
        
        // Guardado de token y user ID en UserDefaults
        UserDefaults.standard.set(response.access_token, forKey: "Token")
        UserDefaults.standard.set(response.user.id, forKey: "UserID")
    }

    // Función auxiliar para verificar conexión a internet
    private func conexionBackend() async -> Bool {
        return await withCheckedContinuation { continuation in
            let networkManager = NetworkReachabilityManager()
            let isReachable = networkManager?.isReachable ?? false
            continuation.resume(returning: isReachable)
        }
    }

    // Función para iniciar sesión
    func login(email: String, pass: String) async {
        // Validación de campos vacíos
        guard !email.isEmpty, !pass.isEmpty else {
            print("Email o contraseña vacíos")
            return
        }
        
        // URL del endpoint de login
        let url = "https://lvmybcyhrbisfjouhbrx.supabase.co/auth/v1/token?grant_type=password"
        let modeloLogin = ModeloRegister(email: email, password: pass)
        
        // Cabeceras necesarias
        let headers: HTTPHeaders = [
            "apikey": constants.apikey,
            "Content-Type": "application/json"
        ]
        
        do {
            // Petición POST para login
            let response = try await AF.request(url,
                                                method: .post,
                                                parameters: modeloLogin,
                                                encoder: JSONParameterEncoder.default,
                                                headers: headers)
                .serializingDecodable(ModeloLoginResponse.self).value
            
            print("Login exitoso")
            print("Token: \(response.access_token)")
            
            // Guardado del token y user ID
            UserDefaults.standard.set(response.access_token, forKey: "Token")
            UserDefaults.standard.set(response.user.id, forKey: "UserID")
            
        } catch {
            print("Error en login: \(error.localizedDescription)")
        }
    }

    // Función para guardar el puntaje de un usuario en la base de datos
    func guardarScore(userId: String, score: Int) async throws {
        let url = "https://lvmybcyhrbisfjouhbrx.supabase.co/rest/v1/scores"
        
        // Datos que se enviarán en el cuerpo del POST
        let scoreData: [String: Any] = [
            "user_id": userId,
            "game_id": "1",
            "score": score,
            "date": ISO8601DateFormatter().string(from: Date()) // Fecha en formato estándar
        ]
        
        // Se obtiene el token desde UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token no encontrado"])
        }
        
        // Cabeceras con autenticación
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "apikey": constants.apikey,
            "Authorization": "Bearer \(token)"
        ]
        
        // Envío de la solicitud POST para guardar el puntaje
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .post,
                       parameters: scoreData,
                       encoding: JSONEncoding.default,
                       headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    print("Puntaje guardado exitosamente")
                    continuation.resume()
                case .failure(let error):
                    print("Error guardando puntaje: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // Función para obtener los puntajes desde la base de datos
    func getScore(gameId: String = "1", userId: String? = nil, requiresAuth: Bool = true) async throws -> [Score] {
        var url = "https://lvmybcyhrbisfjouhbrx.supabase.co/rest/v1/scores"
        var queryItems: [URLQueryItem] = []
        
        // Filtro por ID del juego
        queryItems.append(URLQueryItem(name: "game_id", value: "eq.\(gameId)"))
        
        // Filtro adicional si se proporciona el userId
        if let userId = userId {
            queryItems.append(URLQueryItem(name: "user_id", value: "eq.\(userId)"))
            print("Filtrando por userId: \(userId)")
        }
        
        // Especifica que se desea obtener todos los campos y ordenarlos por puntaje descendente
        queryItems.append(URLQueryItem(name: "select", value: "*"))
        queryItems.append(URLQueryItem(name: "order", value: "score.desc"))
        
        // Construcción de la URL final con parámetros
        var components = URLComponents(string: url)!
        components.queryItems = queryItems
        url = components.url!.absoluteString
        
        print("URL final: \(url)")
        
        // Cabeceras necesarias
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "apikey": constants.apikey
        ]
        
        // Añadir autenticación si se requiere
        if requiresAuth {
            guard let token = UserDefaults.standard.string(forKey: "Token") else {
                throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token no encontrado"])
            }
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
        // Envío de la solicitud GET para obtener los puntajes
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url,
                       method: .get,
                       headers: headers)
            .validate()
            .responseDecodable(of: [Score].self) { response in
                switch response.result {
                case .success(let scores):
                    continuation.resume(returning: scores)
                case .failure(let error):
                    print("Error obteniendo puntajes: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}


// Modelo que se envía al registrarse o iniciar sesión
struct ModeloRegister: Encodable {
    let email: String
    let password: String
}

// Respuesta que se obtiene al registrarse o iniciar sesión
struct ModeloLoginResponse: Decodable {
    let access_token: String
    let user: User
}

// Modelo del usuario
struct User: Decodable {
    let id: String
}

// Modelo de un puntaje
struct Score: Decodable {
    let user_id: String
    let game_id: String
    let score: Int
    let date: String
}
