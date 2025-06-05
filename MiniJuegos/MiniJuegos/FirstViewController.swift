import UIKit
class FirstViewController: UIViewController, UIScrollViewDelegate {
    
    //Jugadores
    @IBOutlet weak var player1Label: UILabel!
    //Boton para jugar
    @IBOutlet weak var playBoton: UIButton!
    //Puntajes
    @IBOutlet weak var puntajesBoton: UIButton!
    //Ayuda
    @IBOutlet weak var helpBoton: UIButton!
    @IBOutlet weak var rulesTextView: UITextView!
    //Elegir juego
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var nextBoton: UIButton!
    @IBOutlet weak var backBoton: UIButton!
    
    let games = ["Poker", "Tocame","Pokedex"]
    var juegoSeleccionado = 0 // índice del juego actual
    var jugador1: Jugador?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBoton.layer.cornerRadius = 8
        puntajesBoton.layer.cornerRadius = 8
        
        if let nombre = UserDefaults.standard.string(forKey: "username") {
            player1Label.text = nombre
        }
        
        pageControll.numberOfPages = games.count
        pageControll.currentPage = 0
        
        mostrarImagenActual()
        validarBoton()
        
        for (index, nombreImagen) in games.enumerated() {
            let imageView = UIImageView(frame: CGRect(
                x: CGFloat(index) * scrollView.frame.size.width,
                y: 0,
                width: scrollView.frame.size.width,
                height: scrollView.frame.size.height
            ))
            imageView.image = UIImage(named: nombreImagen)
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
        }
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configurarScroll()
    }

    
    func actualizarBotonesNavegacion() {
        backBoton.isEnabled = juegoSeleccionado > 0
        nextBoton.isEnabled = juegoSeleccionado < games.count - 1
    }
    func configurarScroll() {
        scrollView.subviews.forEach { $0.removeFromSuperview() }

        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(games.count), height: scrollView.frame.size.height)

        for (index, nombreImagen) in games.enumerated() {
            let imageView = UIImageView(frame: CGRect(
                x: CGFloat(index) * scrollView.frame.size.width,
                y: 0,
                width: scrollView.frame.size.width,
                height: scrollView.frame.size.height
            ))
            if let img = UIImage(named: nombreImagen) {
                imageView.image = img
            } else {
                print("Imagen no encontrada: \(nombreImagen)")
            }
            imageView.contentMode = .scaleAspectFit
            scrollView.addSubview(imageView)
        }
    }

    
    func mostrarImagenActual() {
        let nombreJuego = games[juegoSeleccionado]
        pageControll.currentPage = juegoSeleccionado
        print("Juego actual: \(nombreJuego)")
    }

    
    @IBAction func nextPage(_ sender: Any) {
        if juegoSeleccionado < games.count - 1 {
            juegoSeleccionado += 1
            scrollToPage(index: juegoSeleccionado)
        }
    }
    
    
    @IBAction func backPage(_ sender: Any) {
        if juegoSeleccionado > 0 {
            juegoSeleccionado -= 1
            scrollToPage(index: juegoSeleccionado)
        }
    }
    func scrollToPage(index: Int) {
        juegoSeleccionado = index
        let offset = CGPoint(x: CGFloat(index) * scrollView.frame.size.width, y: 0)
        scrollView.setContentOffset(offset, animated: true)
        mostrarImagenActual()
        actualizarBotonesNavegacion()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageIndex = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
        juegoSeleccionado = pageIndex
        pageControll.currentPage = pageIndex
    }
    
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            if juegoSeleccionado < games.count - 1 {
                juegoSeleccionado += 1
            }
        } else if gesture.direction == .right {
            if juegoSeleccionado > 0 {
                juegoSeleccionado -= 1
            }
        }
    }

    
    //    ---------------------------------------------
    
    @objc func validarBoton() {
        let texto1 = player1Label.text ?? ""
        playBoton.isEnabled = !texto1.isEmpty
        playBoton.alpha = texto1.isEmpty ? 0.5 : 1.0
    }
    
    @IBAction func puntajesTotalBoton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "TopViewController") as? TopViewController else { return }

        // Verificar si el usuario está logueado
        if let _ = UserDefaults.standard.string(forKey: "Token") {
            // Usuario logueado - Mostrar Top 5 (mis puntajes + Top 5)
            vc.tipoVista = .top5
        } else {
            // Usuario no logueado - Mostrar Top 10 general
            vc.tipoVista = .top10
        }

        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ayudaReglasJuegos(_ sender: Any) {
        let juegoActual = games[juegoSeleccionado]
        rulesTextView.isUserInteractionEnabled = false
        switch juegoActual {
        case "Poker":
            rulesTextView.text = """
                Reglas de Poker:
                - Cada jugador recibe 5 cartas.
                - Se permiten una o más rondas de apuesta.
                - El jugador con la mejor combinación gana (Escalera real, Poker, Full, etc.).
                """
        case "Tocame":
            rulesTextView.text = """
                Reglas de Tocame:
                - El jugador debe tocar rápidamente el círculo cuando aparezca para sumar puntos.
                - Si toca en el momento incorrecto, pierde puntos.
                - Gana quien acumule más puntos al final.
                """
        case "Pokedex":
            rulesTextView.text = """
                Reglas de Pokédex:
                - Explorá y buscá Pokémon para llenar tu Pokédex.
                - Tocá para atrapar y conocer datos de cada uno.
                - Completá la colección descubriendo todos los Pokémon.
                """
        default:
            rulesTextView.text = "No hay reglas disponibles para este juego."
        }
    }
    
    
    
    @IBAction func jugarBoton(_ sender: Any) {
        guard let nombre1 = player1Label.text, !nombre1.isEmpty else {
            let alerta = UIAlertController(title: "Error", message: "Por favor ingresá el nombre del jugador 1.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }
        
        // Crear Jugador 1 y Jugador 2(PC)
        jugador1 = Jugador(nombre: nombre1)
        let juego = games[juegoSeleccionado]
        
        
        switch juego {
        case "Poker":
            let poker = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SecondViewController") as! SecondViewController
            poker.nombreJugador1 = nombre1
            poker.nombreJugador2 = "CPU"
            self.show(poker, sender: nil)
            
        case "Tocame":
            let tocame = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ThirdViewController") as! ThirdViewController
            tocame.nombreJugador1 = nombre1
            self.show(tocame, sender: nil)
            
        case "Pokedex":
            let poke = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "PokeViewController") as! PokeViewController
            self.show(poke, sender: nil)
            
        default:
            break
        }
        
    }
    
    
}
