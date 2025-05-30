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
    }
    
    
    @IBAction func inciarSesionBoton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let firstVC = storyboard.instantiateViewController(withIdentifier: "FirstViewController") as! FirstViewController
        navigationController?.pushViewController(firstVC, animated: true)
    }
    
    @IBAction func registrarBoton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "SingUpViewController") as! SingUpViewController
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func topTenBoton(_ sender: Any) {
        guard let puntajesVC = storyboard?.instantiateViewController(withIdentifier: "TopViewController") as? TopViewController else { return }
        
        // Pasar los puntajes actualizados
        navigationController?.pushViewController(puntajesVC, animated: true)
        
        
    }
}
