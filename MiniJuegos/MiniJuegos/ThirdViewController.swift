import UIKit

struct PuntajeData: Codable {
    let jugador: String
    let puntaje: Int
}

class ThirdViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var namej1TextField: UILabel!
    @IBOutlet weak var puntajeLabel: UILabel!
    @IBOutlet weak var startBoton: UIButton!
    @IBOutlet weak var verTop5: UIButton!
    @IBOutlet weak var areaGenerarLabel: UILabel!

    var nombreJugador1: String?

    var timer: Timer?
    var gameTimer: Timer?
    var segundos = 10
    var puntaje = 0
    var juegoActivo = false
    var objetosCirculares: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        startBoton.layer.cornerRadius = 8
        verTop5.layer.cornerRadius = 8
        inicializarUI()

        if let nombre = nombreJugador1 {
            namej1TextField.text = nombre
        } else {
            namej1TextField.text = "Jugador"
        }
    }

    func guardarPuntajeEnAPI() {
        guard let userId = UserDefaults.standard.string(forKey: "UserID"), !userId.isEmpty else {
            print("No hay UserID guardado")
            return
        }
        
        guard let token = UserDefaults.standard.string(forKey: "Token"), !token.isEmpty else {
            print("No hay Token guardado")
            return
        }
        
        let gameId = "1"
        
        Task {
            do {
                // Llamamos a tu función `guardarScore` pasándole `userId`, `gameId` y `score`
                try await APIService.shared.guardarScore(userId: userId, score: puntaje)
                print("Puntaje guardado exitosamente para userId: \(userId) y gameId: \(gameId)")
            } catch {
                print("Error al guardar puntaje en API: \(error)")
                DispatchQueue.main.async {
                    self.mostrarErrorGuardado()
                }
            }
        }
    }

    
    func mostrarErrorGuardado() {
        let alerta = UIAlertController(
            title: "Error",
            message: "No se pudo guardar el puntaje. Verifica tu conexión a internet.",
            preferredStyle: .alert
        )
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }

    // Función para inicializar la UI
    func inicializarUI() {
        // Configurar timer inicial (10 segundos)
        timerLabel.text = "10 s"
        
        // Configurar puntaje inicial (0 puntos)
        puntajeLabel.text = "Puntuación: 0"
        
        // Reiniciar valores
        segundos = 10
        puntaje = 0
        
        // Asegurar que no hay bolitas visibles al inicio
        objetosCirculares.forEach { $0.removeFromSuperview() }
        objetosCirculares.removeAll()
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        iniciarJuego()
    }
    
    func iniciarJuego() {
        if juegoActivo {
            return
        }
        
        // Configurar el timer inicial correctamente
        timerLabel.text = "10 s"
        
        // Reiniciar valores
        segundos = 10
        puntaje = 0
        juegoActivo = true
        
        // Actualizar puntaje a 0 al iniciar el juego
        puntajeLabel.text = "Puntuación: 0"
        startBoton.setTitle("JUGANDO...", for: .normal)
        startBoton.backgroundColor = .systemRed
        startBoton.isEnabled = false
        
        // Limpiar cualquier bolita existente antes de empezar
        objetosCirculares.forEach { $0.removeFromSuperview() }
        objetosCirculares.removeAll()
        
        // Iniciar timer del juego
        iniciarTimer()
        
        // Ahora las bolitas solo aparecen después de presionar START
        iniciarGeneracionObjetos()
    }
    
    func iniciarTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(actualizarTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func actualizarTimer() {
        segundos -= 1
        
        // Actualizar el timerLabel con cuenta regresiva
        timerLabel.text = "\(segundos) s"
        
        if segundos <= 0 {
            finalizarJuego()
        }
    }
    
    func iniciarGeneracionObjetos() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 2.0, // Aparece cada 2 segundos
                                         target: self,
                                         selector: #selector(crearObjetoCircular),
                                         userInfo: nil,
                                         repeats: true)
        
        // Crear primer objeto inmediatamente
        crearObjetoCircular()
    }

    @objc func crearObjetoCircular() {
        if !juegoActivo { return }
                
        // Remover objetos existentes
        objetosCirculares.forEach { $0.removeFromSuperview() }
        objetosCirculares.removeAll()
        
        // Tamaño del círculo
        let tamano: CGFloat = 60
        
        // Calcular posición SOLAMENTE dentro del área de areaGenerarLabel
        let margen: CGFloat = 10
        
        // Obtener las dimensiones exactas del areaGenerarLabel
        let areaFrame = areaGenerarLabel.frame
        let minX = areaFrame.origin.x + margen
        let maxX = areaFrame.origin.x + areaFrame.width - tamano - margen
        let minY = areaFrame.origin.y + margen
        let maxY = areaFrame.origin.y + areaFrame.height - tamano - margen
        
        let randomX = CGFloat.random(in: minX...maxX)
        let randomY = CGFloat.random(in: minY...maxY)
        
        // Crear círculo
        let circulo = UIView(frame: CGRect(x: randomX, y: randomY, width: tamano, height: tamano))
        circulo.backgroundColor = obtenerColorAleatorio()
        circulo.layer.cornerRadius = tamano / 2
        circulo.layer.borderWidth = 3
        circulo.layer.borderColor = UIColor.white.cgColor
        
        // Agregar sombra para mejor visibilidad
        circulo.layer.shadowColor = UIColor.black.cgColor
        circulo.layer.shadowOffset = CGSize(width: 2, height: 2)
        circulo.layer.shadowOpacity = 0.3
        circulo.layer.shadowRadius = 4
        
        // Agregar gesto de tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(objetoTocado(_:)))
        circulo.addGestureRecognizer(tapGesture)
        circulo.isUserInteractionEnabled = true
        
        // Animación de aparición
        circulo.alpha = 0
        circulo.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        view.addSubview(circulo)
        objetosCirculares.append(circulo)
        
        // Animar aparición
        UIView.animate(withDuration: 0.3, animations: {
            circulo.alpha = 1
            circulo.transform = CGAffineTransform.identity
        })
        
        // Programar desaparición automática después de 2 segundos
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.objetosCirculares.contains(circulo) {
                self.removerObjeto(circulo)
            }
        }
    }

    @objc func objetoTocado(_ gesture: UITapGestureRecognizer) {
        guard let circulo = gesture.view, juegoActivo else { return }
        
        // Incrementar puntaje y actualizar puntajeLabel inmediatamente
        puntaje += 10
        puntajeLabel.text = "Puntuación: \(puntaje)"
        
        // Animación de desaparición con efecto
        UIView.animate(withDuration: 0.2, animations: {
            circulo.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            circulo.alpha = 0.7
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                circulo.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                circulo.alpha = 0
            } completion: { _ in
                self.removerObjeto(circulo)
            }
        }
        
        // Efecto de vibración
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    func removerObjeto(_ objeto: UIView) {
        objeto.removeFromSuperview()
        if let index = objetosCirculares.firstIndex(of: objeto) {
            objetosCirculares.remove(at: index)
        }
    }

    func obtenerColorAleatorio() -> UIColor {
        let colores: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemOrange,
            .systemPurple, .systemPink, .systemYellow, .systemTeal
        ]
        return colores.randomElement() ?? .systemBlue
    }

    func finalizarJuego() {
        juegoActivo = false
        
        timer?.invalidate()
        gameTimer?.invalidate()
        timer = nil
        gameTimer = nil
        
        objetosCirculares.forEach { $0.removeFromSuperview() }
        objetosCirculares.removeAll()
        
        startBoton.setTitle("START", for: .normal)
        startBoton.backgroundColor = .systemGreen
        startBoton.isEnabled = true
        
        timerLabel.text = "10 s"
        segundos = 10
        
        // Guardar puntaje en API
        guardarPuntajeEnAPI()
        
        // Mostrar resultado final
        let nombreJugador = namej1TextField.text ?? "Jugador"
        mostrarResultado(jugador: nombreJugador, puntuacion: puntaje)
    }

    func mostrarResultado(jugador: String, puntuacion: Int) {
        let alerta = UIAlertController(
            title: "¡Fin del Juego!",
            message: "\(jugador), tu puntaje final es: \(puntuacion) puntos",
            preferredStyle: .alert
        )
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }

    @IBAction func verTop5Pressed(_ sender: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "TopViewController") as? TopViewController else { return }
        vc.tipoVista = .top5
        navigationController?.pushViewController(vc, animated: true)
    }
}
