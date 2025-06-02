import UIKit

class SecondViewController: UIViewController {
    
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var player2Label: UILabel!
    //Images Jugador 1
    @IBOutlet weak var card1ImageView: UIImageView!
    @IBOutlet weak var card2ImageView: UIImageView!
    @IBOutlet weak var card3ImageView: UIImageView!
    @IBOutlet weak var card4ImageView: UIImageView!
    @IBOutlet weak var card5ImageView: UIImageView!
    //Images Jugador 2
    @IBOutlet weak var card6ImageView: UIImageView!
    @IBOutlet weak var card7ImageView: UIImageView!
    @IBOutlet weak var card8ImageView: UIImageView!
    @IBOutlet weak var card9ImageView: UIImageView!
    @IBOutlet weak var card10ImageView: UIImageView!
    //Decoracion
    @IBOutlet weak var card11ImageView: UIImageView!
    
    //Fondo para ganardor / perdor
    @IBOutlet weak var fondo1ImageView: UIImageView!
    @IBOutlet weak var fondo2ImageView: UIImageView!
    
    
    @IBOutlet weak var repartirCartas: UIButton!
    
    // AGREGADO: Variables para recibir los nombres del FirstViewController
    var nombreJugador1: String?
    var nombreJugador2: String?
    
    var mazo: MazoDeCartas?
    var jugador1: Jugador?
    var jugador2: Jugador?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        repartirCartas.layer.cornerRadius = 8
        inicializarJuego()
        card11ImageView.image = UIImage(named: "decoracion")
        
        // Configurar los nombres si vienen del FirstViewController
        if let nombre1 = nombreJugador1 {
            player1Label.text = nombre1
        } else if let usuario = UserManager.shared.getCurrentUser() {
            player1Label.text = usuario.username
        }
        
        if let nombre2 = nombreJugador2 {
            player2Label.text = nombre2
        }
        
        repartirCartas.setTitle("Repartir", for: .normal)
    }
    
    
    
    
    func inicializarJuego() {
        
        // Crear el mazo y mezclarlo
        mazo = MazoDeCartas()
        mazo?.mezclar()
        
    }
    
    
    @IBAction func repartirCards(_ sender: UIButton) {
        //Validacion de acuerdo que tiene el boton de titulo
        if sender.currentTitle == "Repartir" {
            // Validar nombre
            guard let nombre1 = player1Label.text, !nombre1.isEmpty,
                  let nombre2 = player2Label.text, !nombre2.isEmpty else {
                let alerta = UIAlertController(title: "Error", message: "Ingresá los nombres de ambos jugadores.", preferredStyle: .alert)
                alerta.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alerta, animated: true)
                return
            }
            
            

//            player1Label.isHidden = true
//            player2Label.isHidden = true
            fondo1ImageView.isHidden = false
            fondo2ImageView.isHidden = false
            
            sender.setTitle("Volver a Jugar", for: .normal)
            
            
            guard let mazoSeguro = mazo, mazoSeguro.cartas.count >= 10 else {
                inicializarJuego()
                return
            }
            
            jugador1 = Jugador(nombre: nombre1)
            jugador2 = Jugador(nombre: nombre2)
            let mano1 = mazoSeguro.darMano()
            let mano2 = mazoSeguro.darMano()
            
            guard mano1.count == 5 && mano2.count == 5 else {
                inicializarJuego()
                return
            }
            
            jugador1?.cartas = mano1
            jugador2?.cartas = mano2
            
            jugador1?.tipoJugada = analizarJugada(mano1)
            jugador2?.tipoJugada = analizarJugada(mano2)
            
            jugador1?.mostrarCartas()
            jugador2?.mostrarCartas()
            
            let repartiendoAlert = UIAlertController(title: nil, message: "Repartiendo cartas...", preferredStyle: .alert)
            self.present(repartiendoAlert, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.mostrarCartasEnPantalla()
                    repartiendoAlert.dismiss(animated: true) {
                        let mensajeGanador = self.determinarGanador()
                        let ganadorAlert = UIAlertController(title: "¡Fin del juego!", message: mensajeGanador, preferredStyle: .alert)
                        ganadorAlert.addAction(UIAlertAction(title: "Ok", style: .default))
                        self.present(ganadorAlert, animated: true)
                    }
                }
            }
            
            
        } else if sender.currentTitle == "Volver a Jugar" {
            limpiarImagenes()
            
   
//            player1Label.isHidden = false
//            player2Label.isHidden = false
            fondo1ImageView?.backgroundColor = UIColor.clear
            fondo2ImageView?.backgroundColor = UIColor.clear
            
            // Restaurar los nombres originales si venían del FirstViewController
            if let nombre1 = nombreJugador1 {
                player1Label.text = nombre1
            }
            if let nombre2 = nombreJugador2 {
                player2Label.text = nombre2
            }
            
            inicializarJuego()
            
            sender.setTitle("Repartir", for: .normal)
            
        }
    }
    
    func determinarGanador() -> String {
        guard let jugador1 = jugador1, let jugador2 = jugador2 else {
            return "Error: No se pudieron cargar los jugadores"
        }
        
        let resultado = quienGana(jugador1, jugador2)
        print("Resultado: \(resultado)")
        
        
        if resultado.contains(jugador1.nombre) {
            fondo1ImageView.backgroundColor = UIColor.green
            fondo2ImageView.backgroundColor = UIColor.red
        } else if resultado.contains(jugador2.nombre) {
            fondo1ImageView.backgroundColor = UIColor.red
            fondo2ImageView.backgroundColor = UIColor.green
        } else if resultado.contains("Empate") {
            fondo1ImageView.backgroundColor = UIColor.gray
            fondo2ImageView.backgroundColor = UIColor.gray
        } else {
            fondo1ImageView.backgroundColor = UIColor.clear
            fondo2ImageView.backgroundColor = UIColor.clear
        }
        return resultado
        
    }
    
    
    func mostrarCartasEnPantalla() {
        guard let jugador1 = jugador1, let jugador2 = jugador2 else {
            print("Error: Jugadores no encontrados")
            return
        }
        
        // Cartas jugador 1
        let cartas1 = jugador1.cartas
        let imagenes1 = [card1ImageView, card2ImageView, card3ImageView, card4ImageView, card5ImageView]
        
        for i in 0..<min(cartas1.count, imagenes1.count) {
            let nombreImagen = cartas1[i].mostrar()  // Ej: "AS", "5D"
            print("Carta jugador 1 [\(i)]: \(nombreImagen)")
            
            // Verificar que la imagen existe
            if let imagen = UIImage(named: nombreImagen) {
                imagenes1[i]?.image = imagen
            }
        }
        
        // Cartas jugador 2
        let cartas2 = jugador2.cartas
        let imagenes2 = [card6ImageView, card7ImageView, card8ImageView, card9ImageView, card10ImageView]
        
        for i in 0..<min(cartas2.count, imagenes2.count) {
            let nombreImagen = cartas2[i].mostrar()
            
            if let imagen = UIImage(named: nombreImagen) {
                imagenes2[i]?.image = imagen
            }
        }
    }
    
    func limpiarImagenes() {
        let todasLasImagenes = [card1ImageView, card2ImageView, card3ImageView, card4ImageView, card5ImageView,
                                card6ImageView, card7ImageView, card8ImageView, card9ImageView, card10ImageView]
        
        for imageView in todasLasImagenes {
            imageView?.image = nil
            imageView?.backgroundColor = UIColor.clear
        }
        
        print("Imágenes limpiadas para nueva partida")
    }
    
    
}


