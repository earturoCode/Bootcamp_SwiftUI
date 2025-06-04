import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var tittleLoginLabel: UILabel!
    @IBOutlet weak var tittleRegisLabel: UILabel!
    @IBOutlet weak var correoUsuTextField: UITextField!
    @IBOutlet weak var contrasenaTextField: UITextField!
    @IBOutlet weak var loginBoton: UIButton!
    @IBOutlet weak var registerBoton: UIButton!
    @IBOutlet weak var topBoton: UIButton!
    
    let url = "https://lvmybcyhrbisfjouhbrx.supabase.co/auth/v1/token?grant_type=password"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loginBoton.layer.cornerRadius = 8
        topBoton.layer.cornerRadius = 8
    }
    
    private func setupUI() {
        contrasenaTextField.isSecureTextEntry = true
    }
    
    @IBAction func iniciarSesionBoton(_ sender: Any) {
        
        guard let usernameOrEmail = correoUsuTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !usernameOrEmail.isEmpty,
              let password = contrasenaTextField.text,
              !password.isEmpty else {
            showAlert(title: "Error", message: "Por favor completa todos los campos")
            return
        }
        
        let parameters: [String: Any] = [
            "email": usernameOrEmail,
            "password": password,
            "grant_type": "password"
        ]
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "apikey": constants.apikey, // ← API key real
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "Token"))" // ← API key real
        ]
        
        print("Enviando request a: \(url)")
        print("Con parámetros: \(parameters)")
        
        AF.request(url,
                  method: .post,
                  parameters: parameters,
                  encoding: JSONEncoding.default,
                  headers: headers)
            .validate(statusCode: 200..<300)  // ← Validar solo códigos 2xx
            .responseData { response in
                print("Response status code: \(response.response?.statusCode ?? 0)")
                
                switch response.result {
                case .success(let data):
                    do {
                        if let value = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print("Respuesta de Supabase: \(value)")
                            
                            DispatchQueue.main.async {
                                // Verificar si hay error en la respuesta
                                if let error = value["error"] as? [String: Any],
                                   let errorMessage = error["message"] as? String {
                                    self.showAlert(title: "Error de autenticación", message: errorMessage)
                                } else if let accessToken = value["access_token"] as? String {
                                    // Login exitoso
                                    print("Token recibido: \(accessToken)")
                                    self.handleLoginSuccess()
                                } else {
                                    self.showAlert(title: "Error", message: "Respuesta inesperada del servidor")
                                }
                            }
                        }
                    } catch {
                        print("Error parsing JSON: \(error)")
                        DispatchQueue.main.async {
                            self.showAlert(title: "Error", message: "Error procesando la respuesta del servidor")
                        }
                    }
                    
                case .failure(let error):
                    print("Error completo: \(error)")
                    
                    DispatchQueue.main.async {
                        // Diferentes tipos de errores de red
                        if let urlError = error.underlyingError as? URLError {
                            switch urlError.code {
                            case .notConnectedToInternet:
                                self.showAlert(title: "Sin conexión", message: "Verifica tu conexión a internet")
                            case .timedOut:
                                self.showAlert(title: "Tiempo agotado", message: "La conexión tardó demasiado")
                            case .cannotFindHost:
                                self.showAlert(title: "Servidor no encontrado", message: "No se pudo conectar al servidor")
                            case .networkConnectionLost:
                                self.showAlert(title: "Conexión perdida", message: "Se perdió la conexión durante la petición")
                            default:
                                self.showAlert(title: "Error de red", message: "Error de conexión: \(urlError.localizedDescription)")
                            }
                        } else {
                            self.showAlert(title: "Error", message: "Error al iniciar sesión: \(error.localizedDescription)")
                        }
                    }
                }
            }
    }
    
    private func handleLoginSuccess() {
        // Navegar a FirstViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstVC = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
        navigationController?.pushViewController(firstVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func registrarBoton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "SingUpViewController") as! SingUpViewController
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func topTenBoton(_ sender: Any) {
        guard let puntajesVC = storyboard?.instantiateViewController(withIdentifier: "TopViewController") as? TopViewController else { return }
        puntajesVC.tipoVista = .top10
        navigationController?.pushViewController(puntajesVC, animated: true)
    }
}

extension LoginViewController {
    
    func testWithoutHeaders() {
        // Versión simplificada para testing
        guard let usernameOrEmail = correoUsuTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !usernameOrEmail.isEmpty,
              let password = contrasenaTextField.text,
              !password.isEmpty else {
            showAlert(title: "Error", message: "Por favor completa todos los campos")
            return
        }
        
        let parameters: [String: Any] = [
            "email": usernameOrEmail,
            "password": password,
            "grant_type": "password"
        ]
        
        AF.request(url,
                  method: .post,
                  parameters: parameters,
                  encoding: JSONEncoding.default)
            .responseData { response in
                print("Status code: \(response.response?.statusCode ?? 0)")
                print("Response: \(String(data: response.data ?? Data(), encoding: .utf8) ?? "No data")")
                
                switch response.result {
                case .success(let data):
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw response: \(jsonString)")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
    }
}
