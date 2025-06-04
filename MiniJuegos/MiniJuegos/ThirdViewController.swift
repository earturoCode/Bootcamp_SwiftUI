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
    var segundos = 30
    var puntaje = 0
    var juegoActivo = false
    var objetosCirculares: [UIView] = []
    var listaPuntajes: [(jugador: String, puntaje: Int)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        startBoton.layer.cornerRadius = 8
        verTop5.layer.cornerRadius = 8
        inicializarUI()
        cargarPuntajes()

        if let nombre = nombreJugador1 {
            namej1TextField.text = nombre
        } else {
            namej1TextField.text = "Jugador"
        }
    }

    func inicializarUI() {
        puntaje = 0
        segundos = 30
        puntajeLabel.text = "Puntaje: 0"
        timerLabel.text = "Tiempo: 30"
    }

    func cargarPuntajes() {
        if let data = UserDefaults.standard.data(forKey: "top5Puntajes"),
           let puntajesData = try? JSONDecoder().decode([PuntajeData].self, from: data) {
            listaPuntajes = puntajesData.map { ($0.jugador, $0.puntaje) }
        } else {
            listaPuntajes = []
        }
    }

    func guardarPuntajes() {
        let nuevosPuntajes = listaPuntajes.map { PuntajeData(jugador: $0.jugador, puntaje: $0.puntaje) }
        if let data = try? JSONEncoder().encode(nuevosPuntajes) {
            UserDefaults.standard.set(data, forKey: "top5Puntajes")
        }
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        if juegoActivo { return }
        juegoActivo = true
        inicializarUI()

        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempo), userInfo: nil, repeats: true)
        timer = Timer.scheduledTimer(timeInterval: 1.2, target: self, selector: #selector(generarObjeto), userInfo: nil, repeats: true)
    }

    @objc func actualizarTiempo() {
        segundos -= 1
        timerLabel.text = "Tiempo: \(segundos)"
        if segundos <= 0 {
            finalizarJuego()
        }
    }

    func finalizarJuego() {
        juegoActivo = false
        gameTimer?.invalidate()
        timer?.invalidate()
        eliminarObjetos()
        mostrarResultadoFinal()

        if let nombre = nombreJugador1 {
            listaPuntajes.append((jugador: nombre, puntaje: puntaje))
            listaPuntajes.sort { $0.puntaje > $1.puntaje }
            if listaPuntajes.count > 5 {
                listaPuntajes = Array(listaPuntajes.prefix(5))
            }
            guardarPuntajes()
        }
    }

    func eliminarObjetos() {
        for objeto in objetosCirculares {
            objeto.removeFromSuperview()
        }
        objetosCirculares.removeAll()
    }

    func mostrarResultadoFinal() {
        let alerta = UIAlertController(title: "Fin del Juego", message: "Tu puntaje final es \(puntaje)", preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: nil))
        present(alerta, animated: true, completion: nil)
    }

    @objc func generarObjeto() {
        guard juegoActivo else { return }

        let tamaño: CGFloat = 50
        let maxX = areaGenerarLabel.bounds.width - tamaño
        let maxY = areaGenerarLabel.bounds.height - tamaño

        let x = CGFloat.random(in: 0...maxX)
        let y = CGFloat.random(in: 0...maxY)

        let circulo = UIView(frame: CGRect(x: x, y: y, width: tamaño, height: tamaño))
        circulo.backgroundColor = .systemBlue
        circulo.layer.cornerRadius = tamaño / 2
        circulo.clipsToBounds = true
        circulo.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(objetoTocado(_:)))
        circulo.addGestureRecognizer(tap)

        areaGenerarLabel.addSubview(circulo)
        objetosCirculares.append(circulo)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let index = self.objetosCirculares.firstIndex(of: circulo) {
                self.objetosCirculares.remove(at: index)
                circulo.removeFromSuperview()
            }
        }
    }

    @objc func objetoTocado(_ sender: UITapGestureRecognizer) {
        if let circulo = sender.view {
            circulo.removeFromSuperview()
            if let index = objetosCirculares.firstIndex(of: circulo) {
                objetosCirculares.remove(at: index)
            }
            puntaje += 1
            puntajeLabel.text = "Puntaje: \(puntaje)"
        }
    }

    @IBAction func verTop5Pressed(_ sender: UIButton) {
        // Aquí podrías ir a otro ViewController que muestre el Top 5
        print("Top 5: \(listaPuntajes)")
    }
}
