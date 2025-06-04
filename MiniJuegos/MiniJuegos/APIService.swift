import UIKit
import Alamofire

class APIService {
    static let shared = APIService()
    private init() {}
    
    func signup(email: String, pass: String) async {
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
        
        do {
            let response = try await AF.request(url,
                                                method: .post,
                                                parameters: modeloRegister,
                                                encoder: JSONParameterEncoder.default,
                                                headers: headers)
                .serializingDecodable(ModeloLoginResponse.self).value
            
            print("User ID: \(response.user.id)")
            
        } catch let afError as AFError {
            if let data = afError.underlyingError as? URLError {
                print("Error de red: \(data.localizedDescription)")
            } else {
                print("AFError: \(afError)")
            }
        } catch {
            print("Otro error: \(error)")
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
            
            // Guardar los datos solo si la respuesta es válida
            UserDefaults.standard.set(response.access_token, forKey: "Token")
            UserDefaults.standard.set(response.user.id, forKey: "UserID")
            
        } catch let afError as AFError {
            if let data = afError.underlyingError as? URLError {
                print("Error de red: \(data.localizedDescription)")
            } else {
                print("AFError: \(afError)")
            }
        } catch {
            print("Otro error: \(error)")
        }
    }


    
    
    
    
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

