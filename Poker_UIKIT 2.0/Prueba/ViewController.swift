import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var player1Label: UILabel!
    @IBOutlet weak var player2Label: UILabel!
    @IBOutlet weak var name1TextField: UITextField!
    @IBOutlet weak var name2TextField: UITextField!
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
    //De onda
    @IBOutlet weak var card11ImageView: UIImageView!
    
    @IBOutlet weak var repartirCartas: UIButton!
    
    var mazo: MazoDeCartas?
    var jugador1: Jugador?
    var jugador2: Jugador?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inicializarJuego()
        card11ImageView.image = UIImage(named: "decoracion")

    }
    
    func inicializarJuego() {
        
        // Crear el mazo y mezclarlo
        mazo = MazoDeCartas()
        mazo?.mezclar()
        
        // Crear jugadores vacíos (los nombres se asignarán al repartir)
        jugador1 = Jugador(nombre: "")
        jugador2 = Jugador(nombre: "")
    }
        
    @IBAction func repartirCards(_ sender: Any) {
        //Validar nombre
        guard let nombre1 = name1TextField.text, !nombre1.isEmpty,
              let nombre2 = name2TextField.text, !nombre2.isEmpty else {
            let alerta = UIAlertController(title: "Error", message: "Ingresá los nombres de ambos jugadores.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }
        //validar
        guard let mazoSeguro = mazo, mazoSeguro.cartas.count >= 10 else {
            inicializarJuego() // Reinicializar si hay problema
            return
        }
        
        jugador1 = Jugador(nombre: nombre1)
        jugador2 = Jugador(nombre: nombre2)
        
        let mano1 = mazoSeguro.darMano()
        let mano2 = mazoSeguro.darMano()
        
        // Verificar que se repartieron 5 cartas a cada jugador
        guard mano1.count == 5 && mano2.count == 5 else {
            inicializarJuego() // Reinicializar
            return
        }
        
        jugador1?.cartas = mano1
        jugador2?.cartas = mano2
        
        jugador1?.tipoJugada = analizarJugada(mano1)
        jugador2?.tipoJugada = analizarJugada(mano2)
        
        
        // Mostrar cartas en consola para debug
        jugador1?.mostrarCartas()
        jugador2?.mostrarCartas()
        
        // Mostrar el primer mensaje de "Repartiendo cartas..."
        let repartiendoAlert = UIAlertController(title: nil, message: "Repartiendo cartas...", preferredStyle: .alert)
        self.present(repartiendoAlert, animated: true, completion: {
            // Esperar 2 segundos para simular el reparto
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.mostrarCartasEnPantalla()
                
                // Cerrar el alert de "Repartiendo..."
                repartiendoAlert.dismiss(animated: true, completion: {
                    let mensajeGanador = self.determinarGanador()
                    
                    let ganadorAlert = UIAlertController(title: "¡Fin del juego!", message: mensajeGanador, preferredStyle: .alert)
                    ganadorAlert.addAction(UIAlertAction(title: "Jugar otra vez", style: .default, handler: { _ in
                        self.inicializarJuego()
                        self.limpiarImagenes()
                    }))
                    self.present(ganadorAlert, animated: true, completion: nil)
                })
            }
        })
    }
    
    func determinarGanador() -> String {
        guard let jugador1 = jugador1, let jugador2 = jugador2 else {
            return "Error: No se pudieron cargar los jugadores"
        }
        
        let resultado = quienGana(jugador1, jugador2)
        print("Resultado: \(resultado)")
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
