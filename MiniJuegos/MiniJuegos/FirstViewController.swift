
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickeerTextField.inputView = pickerView
        
        // Para que se cierre el teclado/picker al tocar fuera
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPicker))
        view.addGestureRecognizer(tapGesture)
        
    }
    @objc func dismissPicker() {
        view.endEditing(true)
    }

    
    @IBAction func irAFormulario(_ sender: UIButton) {
        let segundoVC = SecondViewController()
        present(segundoVC, animated: true, completion: nil)
    }
    
    @IBAction func navegarBoton(_ sender: Any) {
        //        let secondViewController = SecondViewController()
                let SecondViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        //        namej1TextField.text = nil
                //secondViewController.name = namej1TextField.text ?? "tu nombre"
        //        self.navigationController?.pushViewController(SecondViewController, animated: true)
                self.show(SecondViewController, sender: nil)
        //        self.present(secondViewController, animated: true , completion: nil)
        //        performSegue(withIdentifier: "goToSecondVC", sender: nil)
        
        
    }


    @objc func validarBoton() {
        let texto1 = namej1TextField.text ?? ""
        let texto2 = namej2TextField.text ?? ""
        
        if !texto1.isEmpty && !texto2.isEmpty {
            playBoton.isEnabled = true
            playBoton.alpha = 1.0
        } else {
            playBoton.isEnabled = false
            playBoton.alpha = 0.5
        }
    }
    

    @IBAction func jugarBoton(_ sender: Any) {
    
        
        guard let nombre1 = namej1TextField.text, !nombre1.isEmpty,
              let nombre2 = namej2TextField.text, !nombre2.isEmpty else {
            let alerta = UIAlertController(title: "Error", message: "Ingresá los nombres de ambos jugadores.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
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
    }
}
