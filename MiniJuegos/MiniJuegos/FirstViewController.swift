
import UIKit

class FirstViewController: UIViewController {
    
    //Elegir juego
    @IBOutlet weak var pickeerTextField: UITextField!
    //Jugadores
    @IBOutlet weak var player1Label: UILabel!
    //Boton para jugar
    @IBOutlet weak var playBoton: UIButton!
    
    @IBOutlet weak var puntajesBoton: UIButton!
    
    @IBOutlet weak var helpBoton: UIButton!
    
    @IBOutlet weak var rulesTextView: UITextView!
    
    let games = ["Poker", "Tocame"]
    var pickerView = UIPickerView()
    var jugador1: Jugador?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let usuario = UserManager.shared.getCurrentUser() {
                player1Label.text = usuario.username
            }
//          Deshabilitar la edición directa del texto en el picker
            pickeerTextField.tintColor = .clear // oculta el cursor
//          Configurar Picker
            pickerView.delegate = self
            pickerView.dataSource = self
            pickeerTextField.inputView = pickerView
//          Para que se cierre el teclado/picker al tocar fuera
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
            view.addGestureRecognizer(tapGesture)
//            Deshabilitar botón inicialmente
            playBoton.isEnabled = false
            playBoton.alpha = 0.5
    }
    
    
    @objc func validarBoton() {
        let texto1 = player1Label.text ?? ""
        
        // Para cualquier juego solo validamos el nombre del jugador 1
        if !texto1.isEmpty {
            playBoton.isEnabled = true
            playBoton.alpha = 1.0
        } else {
            playBoton.isEnabled = false
            playBoton.alpha = 0.5
        }
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    @IBAction func puntajesTotalBoton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "TopViewController") as? TopViewController else { return }
        vc.tipoVista = .misPartidas  // ← Solo mis puntajes
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ayudaReglasJuegos(_ sender: Any) {
        guard let juegoSeleccionado = pickeerTextField.text else {
                rulesTextView.text = "Por favor, selecciona un juego para ver las reglas."
                return
            }

            switch juegoSeleccionado {
            case "Poker":
                rulesTextView.isUserInteractionEnabled = false
                rulesTextView.text = """
                Reglas de Poker:
                - Cada jugador recibe 5 cartas.
                - Se permiten una o más rondas de apuesta.
                - El jugador con la mejor combinación gana (Escalera real, Poker, Full, etc.).
                """
            case "Tocame":
                rulesTextView.isUserInteractionEnabled = false
                rulesTextView.text = """
                Reglas de Tocame:
                - El jugador debe tocar rápidamente el circulo cuando aparezca para sumar puntos.
                - Si toca en el momento incorrecto, pierde puntos.
                - Gana quien acumule más puntos al final.
                """
            default:
                rulesTextView.text = "No hay reglas disponibles para este juego."
            }
    }
    
    
    @IBAction func jugarBoton(_ sender: Any) {
        guard let juegoSeleccionado = pickeerTextField.text, !juegoSeleccionado.isEmpty else {
            let alerta = UIAlertController(title: "Error", message: "Por favor selecciona un juego.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }
        
        
        
        guard let nombre1 = player1Label.text, !nombre1.isEmpty else {
            let alerta = UIAlertController(title: "Error", message: "Por favor ingresá el nombre del jugador 1.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }
        
        // Crear Jugador 1 y Jugador 2(PC)
        jugador1 = Jugador(nombre: nombre1)
        
        if juegoSeleccionado == "Poker" {
            let poker = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SecondViewController") as! SecondViewController
            
            poker.nombreJugador1 = nombre1
            poker.nombreJugador2 = "CPU"
            
            self.show(poker, sender: nil)
            
        } else if juegoSeleccionado == "Tocame" {
            let tocame = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ThirdViewController") as! ThirdViewController
            
            tocame.nombreJugador1 = nombre1
            
            self.show(tocame, sender: nil)
        }
    }

}
extension FirstViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerView {
            return games.count
        }
        return 0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return games[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickeerTextField.text = games[row]
        pickeerTextField.resignFirstResponder()
        validarBoton()
        
    }
}
