import UIKit
import Alamofire

class APIService {
    static let shared = APIService()
    private init() {}

    func signup(email: String, pass: String) async throws {
        guard !email.isEmpty, !pass.isEmpty else {
            print("Email o contraseña vacíos")
            return
        }
        
        let url = "https://lvmybcyhrbisfjouhbrx.supabase.co/auth/v1/signup"
        let modeloRegister = ModeloRegister(email: email, password: pass)
        let headers: HTTPHeaders = [
            "apikey": constants.apikey,
            "Content-Type": "application/json"
        ]
        
        let response = try await AF.request(url,
                                            method: .post,
                                            parameters: modeloRegister,
                                            encoder: JSONParameterEncoder.default,
                                            headers: headers)
            .serializingDecodable(ModeloLoginResponse.self).value
        
        print("User ID: \(response.user.id)")
        
        // Guardar datos del usuario exitoso
        UserDefaults.standard.set(response.access_token, forKey: "Token")
        UserDefaults.standard.set(response.user.id, forKey: "UserID")
    }

    // Función auxiliar para verificar conexión a internet
    private func conexionBackend() async -> Bool {
        return await withCheckedContinuation { continuation in
            let networkManager = NetworkReachabilityManager()
            
            // Verificar estado actual
            let isReachable = networkManager?.isReachable ?? false
            continuation.resume(returning: isReachable)
        }
    }
    
    func login(email: String, pass: String) async {
        guard !email.isEmpty, !pass.isEmpty else {
            print("Email o contraseña vacíos")
            return
        }
        
        let url = "https://lvmybcyhrbisfjouhbrx.supabase.co/auth/v1/token?grant_type=password"
        let modeloLogin = ModeloRegister(email: email, password: pass)
        
        let headers: HTTPHeaders = [
            "apikey": constants.apikey,
            "Content-Type": "application/json"
        ]
        
        do {
            let response = try await AF.request(url,
                                                method: .post,
                                                parameters: modeloLogin,
                                                encoder: JSONParameterEncoder.default,
                                                headers: headers)
                .serializingDecodable(ModeloLoginResponse.self).value
            
            print("Login exitoso")
            print("Token: \(response.access_token)")
            
            UserDefaults.standard.set(response.access_token, forKey: "Token")
            UserDefaults.standard.set(response.user.id, forKey: "UserID")
            
        } catch {
            print("Error en login: \(error.localizedDescription)")
        }
    }
    
    func guardarScore(userId: String, gameId: String, score: Int) async throws {
        let url = "https://lvmybcyhrbisfjouhbrx.supabase.co/rest/v1/scores"
        
        let scoreData: [String: Any] = [
            "user_id": userId,
            "game_id": gameId,
            "score": score,
            "date": ISO8601DateFormatter().string(from: Date())
        ]
        
        guard let token = UserDefaults.standard.string(forKey: "Token") else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token no encontrado"])
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "apikey": constants.apikey,
            "Authorization": "Bearer \(token)"
        ]
        
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
    
    func getScore(gameId: String? = nil, userId: String? = nil, requiresAuth: Bool = true) async throws -> [Score] {
        var url = "https://lvmybcyhrbisfjouhbrx.supabase.co/rest/v1/scores"
        var queryItems: [URLQueryItem] = []
        
        if let userId = userId {
            queryItems.append(URLQueryItem(name: "user_id", value: "eq.\(userId)"))
            print("Filtrando por userId: \(userId)")
        }
        
        if let gameId = gameId {
            queryItems.append(URLQueryItem(name: "game_id", value: "eq.\(gameId)"))
            print("Filtrando por gameId: \(gameId)")
        }
        
        queryItems.append(URLQueryItem(name: "select", value: "*"))
        
        queryItems.append(URLQueryItem(name: "order", value: "score.desc"))
        
        var components = URLComponents(string: url)!
        components.queryItems = queryItems
        url = components.url!.absoluteString
        
        print("URL final: \(url)")
        
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "apikey": constants.apikey
        ]
        
        if requiresAuth {
            guard let token = UserDefaults.standard.string(forKey: "Token") else {
                throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token no encontrado"])
            }
            headers.add(name: "Authorization", value: "Bearer \(token)")
        }
        
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


struct metaData: Codable {
    let nombre: String
}

struct ModeloRegister: Encodable {
    let email: String
    let password: String
}

struct ModeloLoginResponse: Decodable {
    let access_token: String
    let user: User
}

struct User: Decodable {
    let id: String
}

struct Score: Decodable {
    let user_id: String
    let game_id: String
    let score: Int
    let date: String
}
