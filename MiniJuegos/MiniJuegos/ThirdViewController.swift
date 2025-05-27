import UIKit

class ThirdViewController: UIViewController {
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var namej1TextField: UILabel!
    @IBOutlet weak var puntajeLabel: UILabel!
    @IBOutlet weak var startBoton: UIButton!

    @IBOutlet weak var areaGenerarLabel: UILabel!
    
    // Variable para recibir el nombre del jugador desde FirstViewController
    var nombreJugador1: String?
    
    var timer: Timer?
    var gameTimer: Timer?
    var segundos = 30
    var puntaje = 0
    var juegoActivo = false
    var objetosCirculares: [UIView] = []
    
    override func viewDidLoad() {
            super.viewDidLoad()
        //  Inicializar la UI correctamente desde el inicio
          inicializarUI()
          
          // Mostrar el nombre del jugador recibido desde FirstViewController
          if let nombre = nombreJugador1 {
              namej1TextField.text = nombre
          } else {
              namej1TextField.text = "Jugador"
          }
        }
    
    // Función para inicializar la UI
     func inicializarUI() {
         // Configurar timer inicial (30 segundos)
         timerLabel.text = "30 s"
         
         // Configurar puntaje inicial (0 puntos)
         puntajeLabel.text = "Puntuación: 0"
         
         // Asegurar que no hay bolitas visibles al inicio
         objetosCirculares.forEach { $0.removeFromSuperview() }
         objetosCirculares.removeAll()
     }
            
    @IBAction func startBotonPresionado(_ sender: UIButton) {
        iniciarJuego()
    }
    
    @objc func iniciarJuego() {
            
            if juegoActivo {
                return
            }
            
            // Configurar el timer inicial correctamente
            timerLabel.text = "30 s"

            // Reiniciar valores
            segundos = 30
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
            gameTimer = Timer.scheduledTimer(timeInterval: 1.5, // Aparece cada 1.5 segundos
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
            
            // Animación de aparición - ESTA DEMAS
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
            
            // Detener timers
            timer?.invalidate()
            gameTimer?.invalidate()
            timer = nil
            gameTimer = nil
            
            // Limpiar todas las bolitas al finalizar el juego
            objetosCirculares.forEach { $0.removeFromSuperview() }
            objetosCirculares.removeAll()
            
            // Restaurar UI
            startBoton.setTitle("START", for: .normal)
            startBoton.backgroundColor = .systemGreen
            startBoton.isEnabled = true
            
            // Resetear timer a 30 segundos
            timerLabel.text = "30 s"
            
            // Mostrar resultado
            let nombreJugador = namej1TextField.text ?? "Jugador"
            mostrarResultado(jugador: nombreJugador, puntuacion: puntaje)
            
            // Resetear para próximo juego
            segundos = 30
            // MODIFICACIÓN: NO resetear el puntaje aquí para que se mantenga visible hasta el próximo juego
        }
        
        func mostrarResultado(jugador: String, puntuacion: Int) {
            let alert = UIAlertController(title: "¡Juego Terminado!",
                                        message: " \(jugador)\n 🏆 Puntuación final: \(puntuacion)",
                                        preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Jugar de Nuevo", style: .default) { _ in
                //  Resetear completamente la UI para un nuevo juego
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
