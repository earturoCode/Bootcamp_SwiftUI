
import UIKit

class FirstViewController: UIViewController {
    //Titulo
    @IBOutlet weak var tittleLabel: UILabel!
    //Elegir juego
    @IBOutlet weak var pickeerTextField: UITextField!
    //Jugadores
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var player2Label: UILabel!
    //Nombre de jugadores
    @IBOutlet weak var namej1TextField: UITextField!
    @IBOutlet weak var namej2TextField: UITextField!
    //Boton para jugar
    @IBOutlet weak var playBoton: UIButton!
    
        
    let games = ["Poker", "Tocame"]
    var pickerView = UIPickerView()
    var jugador1: Jugador?
    var jugador2: Jugador?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//      Deshabilitar la edición directa del texto en el picker
        pickeerTextField.isUserInteractionEnabled = true
        // Configurar Picker
        pickerView.delegate = self
        pickerView.dataSource = self
        pickeerTextField.inputView = pickerView
        
        // Para que se cierre el teclado/picker al tocar fuera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tapGesture)
        
        // Validar cuando cambie el texto
        namej1TextField.addTarget(self, action: #selector(validarBoton), for: .editingChanged)
        namej2TextField.addTarget(self, action: #selector(validarBoton), for: .editingChanged)
        pickeerTextField.addTarget(self, action: #selector(validarBoton), for: .editingChanged)
        
        
        // Deshabilitar botón inicialmente
        playBoton.isEnabled = false
        playBoton.alpha = 0.5
        
    }
    
    
    @objc func validarBoton() {
        let texto1 = namej1TextField.text ?? ""
        let texto2 = namej2TextField.text ?? ""
        
        // Lógica de validación según el juego seleccionado
        if pickeerTextField.text == "Poker" {
            // Mostrar campo del jugador 2
            namej2TextField.isHidden = false
            player2Label.isHidden = false
            // Para Poker necesitamos ambos nombres
            if !texto1.isEmpty && !texto2.isEmpty {
                playBoton.isEnabled = true
                playBoton.alpha = 1.0
                self.view.layoutIfNeeded()
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            } else {
                playBoton.isEnabled = false
                playBoton.alpha = 0.5
            }
        } else if pickeerTextField.text == "Tocame" {
            // Para Tocame solo necesitamos el primer nombre
            // Ocultar campo del jugador 2
            namej2TextField.isHidden = true
            player2Label.isHidden = true
            
            if !texto1.isEmpty {
                playBoton.isEnabled = true
                playBoton.alpha = 1.0
            } else {
                playBoton.isEnabled = false
                playBoton.alpha = 0.5
            }
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            // No hay juego seleccionado
            playBoton.isEnabled = false
            playBoton.alpha = 0.5
            // Mostrar ambos campos por defecto
            namej2TextField.isHidden = false
            player2Label.isHidden = false
        }
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    

    
    
    @IBAction func jugarBoton(_ sender: Any) {
        // Validar que hay un juego seleccionado
        guard let juegoSeleccionado = pickeerTextField.text, !juegoSeleccionado.isEmpty else {
            let alerta = UIAlertController(title: "Error", message: "Por favor selecciona un juego.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }
        
        guard let nombre1 = namej1TextField.text, !nombre1.isEmpty else {
            // Mostrar alerta si falta el primer nombre
            let alerta = UIAlertController(title: "Error", message: "Por favor ingresá el nombre del jugador 1.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }
        
        // Validación específica por juego
        if juegoSeleccionado == "Poker" {
            // Para Poker necesitamos ambos nombres
            guard let nombre2 = namej2TextField.text, !nombre2.isEmpty else {
                let alerta = UIAlertController(title: "Error", message: "Por favor ingresá ambos nombres para Poker.", preferredStyle: .alert)
                alerta.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alerta, animated: true)
                return
            }
            // Navegar al juego de Poker (SecondViewController)
            let poker = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SecondViewController") as! SecondViewController
            
            // Pasar los nombres al SecondViewController
            poker.nombreJugador1 = nombre1
            poker.nombreJugador2 = nombre2
            
            jugador1 = Jugador(nombre: nombre1)
            jugador2 = Jugador(nombre: nombre2)
            
            print("Navegando a Poker con jugadores: \(nombre1) y \(nombre2)")
            self.show(poker, sender: nil)
            
        } else if juegoSeleccionado == "Tocame" {
            // Navegar al juego Tocame (ThirdViewController)
            let tocame = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ThirdViewController") as! ThirdViewController
            // IMPORTANTE: Pasar el nombre del jugador al ThirdViewController
            tocame.nombreJugador1 = nombre1
            
            jugador1 = Jugador(nombre: nombre1)
            
            print("Navegando a Tocame con jugador: \(nombre1)")
            self.show(tocame, sender: nil)
        } else {
            // Juego no reconocido
            let alerta = UIAlertController(title: "Error", message: "Juego no reconocido: \(juegoSeleccionado)", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
        }
    }
}
extension FirstViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return games.count
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
