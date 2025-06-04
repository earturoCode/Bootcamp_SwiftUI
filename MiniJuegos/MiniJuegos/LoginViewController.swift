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
    
    let url = "https://YOUR_SUPABASE_URL/auth/v1/token"  // URL de Supabase para login
    
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
        
        // Preparar datos para la solicitud a Supabase
        let parameters: [String: Any] = [
            "email": usernameOrEmail,
            "password": password
        ]
        
        // Realizar solicitud POST a Supabase para obtener token
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("Respuesta de Supabase: \(value)")
                    // Aquí puedes manejar la respuesta de éxito o error
                    DispatchQueue.main.async {
                        if let response = value as? [String: Any], let error = response["error"] {
                            self.showAlert(title: "Error", message: error as! String)
                        } else {
                            // Aquí puedes extraer la información que necesitas del response
                            self.handleLoginSuccess()
                        }
                    }
                    
                case .failure(let error):
                    print("Error de red: \(error)")
                    self.showAlert(title: "Error", message: "Hubo un error al iniciar sesión")
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
        puntajesVC.tipoVista = .top10  // ← Esto hace la magia
        navigationController?.pushViewController(puntajesVC, animated: true)
    }
}
