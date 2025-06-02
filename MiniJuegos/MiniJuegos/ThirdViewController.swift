import UIKit

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var namej1TextField: UILabel!
    @IBOutlet weak var puntajeLabel: UILabel!
    @IBOutlet weak var startBoton: UIButton!
    
    @IBOutlet weak var verTop5: UIButton!
    @IBOutlet weak var areaGenerarLabel: UILabel!
    
    // Variable para recibir el nombre del jugador desde FirstViewController
    var nombreJugador1: String?
    
    
    var timer: Timer?
    var gameTimer: Timer?
    var segundos = 30
    var puntaje = 0
    var juegoActivo = false
    var objetosCirculares: [UIView] = []
    //  Usar UserDefaults para persistir los puntajes entre sesiones
    var listaPuntajes: [(jugador: String, puntaje: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startBoton.layer.cornerRadius = 8
        verTop5.layer.cornerRadius = 8
        //  Inicializar la UI correctamente desde el inicio
        inicializarUI()
        cargarPuntajes()
        // Mostrar el nombre del jugador recibido desde FirstViewController
        if let nombre = nombreJugador1 {
            namej1TextField.text = nombre
        } else {
            namej1TextField.text = "Jugador"
        }
    }
    
    // Función para cargar puntajes desde UserDefaults
    func cargarPuntajes() {
        if let data = UserDefaults.standard.data(forKey: "top5Puntajes"),
           let puntajesData = try? JSONDecoder().decode([PuntajeData].self, from: data) {
            listaPuntajes = puntajesData.map { (jugador: $0.jugador, puntaje: $0.puntaje) }
        } else {
            // Datos por defecto si no hay nada guardado
            listaPuntajes = []
        }
    }
    
    //    función para guardar puntajes en UserDefaults
    func guardarPuntajes() {
        let puntajesData = listaPuntajes.map { PuntajeData(jugador: $0.jugador, puntaje: $0.puntaje) }
        if let data = try? JSONEncoder().encode(puntajesData) {
            UserDefaults.standard.set(data, forKey: "top5Puntajes")
            UserDefaults.standard.synchronize() // Forzar sincronización
        }
    }
    
    // Función para inicializar la UI
    func inicializarUI() {
        // Configurar timer inicial (30 segundos)
        timerLabel.text = "10 s"
        
        // Configurar puntaje inicial (0 puntos)
        puntajeLabel.text = "Puntuación: 0"
        
        // Asegurar que no hay bolitas visibles al inicio
        objetosCirculares.forEach { $0.removeFromSuperview() }
        objetosCirculares.removeAll()
    }
    
    @IBAction func startBotonPresionado(_ sender: UIButton) {
        iniciarJuego()
    }
    
    @IBAction func topmejoresBoton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "TopViewController") as? TopViewController else { return }
        vc.tipoVista = .top5  // ← Top 5 general
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @objc func iniciarJuego() {
        
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
        gameTimer = Timer.scheduledTimer(timeInterval: 2, // Aparece cada 1.5 segundos
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
        let margen: CGFloat = 10 // Margen más pequeño para aprovechar mejor el espacio
        
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
        
        // Agregar sombra para mejor visibilidad - ESTA DEMAS
        circulo.layer.shadowColor = UIColor.black.cgColor
        circulo.layer.shadowOffset = CGSize(width: 2, height: 2)
        circulo.layer.shadowOpacity = 0.3
        circulo.layer.shadowRadius = 4
        
        // Agregar gesto de tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(objetoTocado(_:)))
        circulo.addGestureRecognizer(tapGesture)
        circulo.isUserInteractionEnabled = true
        
//         Animación de aparición - ESTA DEMAS
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
        
        // Efecto de vibración - ESTA DEMAS
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
        
        
        // Guardar el puntaje final del jugador
        if let nombre = nombreJugador1 {
            agregarYGuardarPuntaje(jugador: nombre, puntaje: puntaje)
        }
        
        timerLabel.text = "10 s"
        segundos = 10
        
        let nombreJugador = namej1TextField.text ?? "Jugador"
        mostrarResultado(jugador: nombreJugador, puntuacion: puntaje)
    }
    
    //        Centraliza la lógica de agregar y guardar puntajes
    func agregarYGuardarPuntaje(jugador: String, puntaje: Int) {
        // Agregar el nuevo puntaje SIN limitar
        listaPuntajes.append((jugador: jugador, puntaje: puntaje))
        // Ordenar por puntaje descendente
        listaPuntajes.sort { $0.puntaje > $1.puntaje }
        
//        if listaPuntajes.count > 5 {
//            listaPuntajes = Array(listaPuntajes.prefix(5))
//        }
        // Guardar TODOS los puntajes (no solo los primeros 5)
        guardarPuntajes()
    }
    
    
    
    func mostrarResultado(jugador: String, puntuacion: Int) {
        let alert = UIAlertController(title: "¡Juego Terminado!",
                                      message: " \(jugador)\n 🏆 Puntuación final: \(puntuacion)",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Jugar de Nuevo", style: .default) { _ in
            self.inicializarUI()
        })
        
        alert.addAction(UIAlertAction(title: "Volver al Menú", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    func mostrarAlerta(mensaje: String) {
        let alert = UIAlertController(title: "Atención",
                                      message: mensaje,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Limpiar recursos al salir
    deinit {
        timer?.invalidate()
        gameTimer?.invalidate()
        
    }
    
}
