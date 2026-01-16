import UIKit
import Alamofire

struct SignUpRequest: Codable {
    let username: String
    let email: String
    let password: String
}


class SingUpViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Crear Cuenta"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Nombre de usuario"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Correo electrónico"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Contraseña"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirmar contraseña"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Registrarse", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let alreadyHaveAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "¿Ya tienes una cuenta?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Iniciar sesión", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()

    }
    
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add en la pantalla
        view.addSubview(titleLabel)
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(signUpButton)
        view.addSubview(alreadyHaveAccountLabel)
        view.addSubview(loginButton)
        
        // constraints
        NSLayoutConstraint.activate([
            // Titulos
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Name TextField
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Email TextField
            emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password TextField
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Confirm Password TextField
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 50),
            
            // Sign Up Button
            signUpButton.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 30),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Ya tiene cuenta label
            alreadyHaveAccountLabel.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 30),
            alreadyHaveAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Login Button
            loginButton.topAnchor.constraint(equalTo: alreadyHaveAccountLabel.bottomAnchor, constant: 10),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    @objc private func loginButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    @objc private func signUpButtonTapped() {
        // Validar campos vacíos
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty,
              let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            showAlert(title: "Error", message: "Por favor completa todos los campos")
            return
        }
        
        // Validar formato de email básico
        guard email.contains("@") && email.contains(".") else {
            showAlert(title: "Error", message: "Por favor ingresa un email válido")
            return
        }
        
        // Validar longitud mínima de contraseña
        guard password.count >= 6 else {
            showAlert(title: "Error", message: "La contraseña debe tener al menos 6 caracteres")
            return
        }
        
        // Validar que las contraseñas coincidan
        guard password == confirmPassword else {
            showAlert(title: "Error", message: "Las contraseñas no coinciden")
            return
        }
        
        // Deshabilitar botón y mostrar loading
        signUpButton.isEnabled = false
        signUpButton.setTitle("Registrando...", for: .normal)
        signUpButton.backgroundColor = .systemGray
        
        // Llamar al servicio para hacer la solicitud de registro
        Task {
            do {
                try await APIService.shared.signup(email: email, pass: password)
                
                // Guardar el nombre de usuario
                UserDefaults.standard.set(name, forKey: "username")
                
                // Mostrar éxito en el hilo principal
                await MainActor.run {
                    self.showSuccessAndNavigate()
                }
                
            } catch {
                await MainActor.run {
                    let errorMessage: String
                    
                    // Verificar si es un error de red/conexión
                    if let afError = error as? AFError {
                        switch afError {
                        case .sessionTaskFailed(let sessionError):
                            if let urlError = sessionError as? URLError {
                                switch urlError.code {
                                case .notConnectedToInternet, .networkConnectionLost, .timedOut:
                                    errorMessage = "No tienes conexión a internet. Por favor verifica tu conexión e inténtalo de nuevo."
                                default:
                                    errorMessage = "Error de conexión. Inténtalo de nuevo."
                                }
                            } else {
                                errorMessage = "Error de red. Inténtalo de nuevo."
                            }
                        case .responseValidationFailed:
                            errorMessage = "Este email ya está registrado o hay un problema con los datos."
                        default:
                            errorMessage = "Error de conexión con el servidor."
                        }
                    } else {
                        errorMessage = "Ocurrió un error inesperado: \(error.localizedDescription)"
                    }
                    
                    self.showAlert(title: "Error", message: errorMessage)
                    self.resetButton()
                }
            }
        }
    }
    // Método auxiliar para resetear el botón
    private func resetButton() {
        signUpButton.isEnabled = true
        signUpButton.setTitle("Registrarse", for: .normal)
        signUpButton.backgroundColor = .systemBlue
    }

    // Método auxiliar para mostrar éxito y navegar
    private func showSuccessAndNavigate() {
        resetButton()
        
        let alert = UIAlertController(title: "¡Éxito!", message: "Usuario registrado exitosamente", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continuar", style: .default) { _ in
            // Navegar al siguiente controlador
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let firstVC = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as? FirstViewController {
                self.navigationController?.pushViewController(firstVC, animated: true)
            }
        })
        present(alert, animated: true)
    }

    
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true, completion: nil)
    }
    
}
