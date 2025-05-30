import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var tittleLoginLabel: UILabel!
    @IBOutlet weak var tittleRegisLabel: UILabel!
    @IBOutlet weak var correoUsuTextField: UITextField!
    @IBOutlet weak var contrasenaTextField: UITextField!
    @IBOutlet weak var loginBoton: UIButton!
    @IBOutlet weak var registerBoton: UIButton!
    @IBOutlet weak var topBoton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    private func setupUI() {
        correoUsuTextField.placeholder = "Usuario o Email"
        contrasenaTextField.placeholder = "Contraseña"
        contrasenaTextField.isSecureTextEntry = true
    }
    
    @IBAction func inciarSesionBoton(_ sender: Any) {

        guard let usernameOrEmail = correoUsuTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                      !usernameOrEmail.isEmpty,
                      let password = contrasenaTextField.text,
                      !password.isEmpty else {
                    showAlert(title: "Error", message: "Por favor completa todos los campos")
                    return
                }
                
                // Intentar login con username
                var loginResult = UserManager.shared.validateLogin(username: usernameOrEmail, password: password)
                
                // Si no funciona con username, intentar con email (opcional)
                if !loginResult.success {
                    // Buscar usuario por email
                    let users = UserManager.shared.getAllUsers()
                    if let userByEmail = users.first(where: { $0.email.lowercased() == usernameOrEmail.lowercased() }) {
                        if userByEmail.password == password {
                            loginResult = (true, userByEmail)
                        }
                    }
                }
                
                if loginResult.success, let user = loginResult.user {
                    // Guardar usuario actual para la sesión
                    UserManager.shared.setCurrentUser(user)
                    
                    // Navegar a FirstViewController
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let firstVC = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
                    navigationController?.pushViewController(firstVC, animated: true)
                } else {
                    showAlert(title: "Error", message: "Usuario o contraseña incorrectos")
                }
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
