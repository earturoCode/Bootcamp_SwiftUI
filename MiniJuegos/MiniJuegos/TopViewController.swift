import UIKit

// Estructura para UserDefaults
struct PuntajeData: Codable {
    let jugador: String
    let puntaje: Int
}

// enum para definir qué tipo de vista mostrar
enum TipoVista {
    case top5           // Top 5 - Tocame
    case top10          // Top 10 para login
    case misPartidas    // Solo partidas del jugador actual
}

class TopViewController: UIViewController {

    @IBOutlet weak var topPlayerTable: UITableView!
    
    // Array para almacenar los puntajes mostrados
    var puntajesMostrados: [(jugador: String, puntaje: Int)] = []
    
    // Propiedades de configuración
    var tipoVista: TipoVista = .top5
    var jugadorFiltrado: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configurarVista()
        cargarPuntajes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarPuntajes()
        topPlayerTable.reloadData()
    }
    
    // Configuración de vista para los top
    func configurarVista() {
        switch tipoVista {
        case .top5:
            self.title = "Top 5 Jugadores"
        case .top10:
            self.title = "Top 10 Mejores Puntajes"
        case .misPartidas:
            if let jugador = jugadorFiltrado {
                self.title = "Mis Puntajes - \(jugador)"
            } else if let usuario = UserManager.shared.getCurrentUser() {
                self.title = "Mis Puntajes - \(usuario.username)"
            } else {
                self.title = "Mis Puntajes"
            }
        }
    }
    
    func setupTableView() {
        topPlayerTable.dataSource = self
        topPlayerTable.delegate = self
        
        // Configuración adicional de la tabla
        topPlayerTable.backgroundColor = UIColor.systemGroupedBackground
        topPlayerTable.separatorStyle = .singleLine
        topPlayerTable.rowHeight = 60
    }
    
    // Carga de datos de puntajes
    func cargarPuntajes() {
        switch tipoVista {
        case .top5:
            cargarTop5()
        case .top10:
            cargarTop10()
        case .misPartidas:
            cargarMisPuntajes()
        }
    }
    
    private func cargarTop5() {
        if let data = UserDefaults.standard.data(forKey: "top5Puntajes"),
           let puntajesData = try? JSONDecoder().decode([PuntajeData].self, from: data) {
            
            let todosPuntajes = puntajesData.map { (jugador: $0.jugador, puntaje: $0.puntaje) }
            let puntajesOrdenados = todosPuntajes.sorted { $0.puntaje > $1.puntaje }
            puntajesMostrados = Array(puntajesOrdenados.prefix(5))
        } else {
            puntajesMostrados = []
        }
    }
    
    private func cargarTop10() {
        if let data = UserDefaults.standard.data(forKey: "top5Puntajes"),
           let puntajesData = try? JSONDecoder().decode([PuntajeData].self, from: data) {
            
            let todosPuntajes = puntajesData.map { (jugador: $0.jugador, puntaje: $0.puntaje) }
            let puntajesOrdenados = todosPuntajes.sorted { $0.puntaje > $1.puntaje }
            puntajesMostrados = Array(puntajesOrdenados.prefix(10))
        } else {
            puntajesMostrados = []
        }
    }
    
    private func cargarMisPuntajes() {
        // Determinar qué jugador filtrar
        let nombreJugador: String
        if let jugadorEspecifico = jugadorFiltrado {
            nombreJugador = jugadorEspecifico
        } else if let usuario = UserManager.shared.getCurrentUser() {
            nombreJugador = usuario.username
        } else {
            puntajesMostrados = []
            return
        }
        
        if let data = UserDefaults.standard.data(forKey: "top5Puntajes"),
           let puntajesData = try? JSONDecoder().decode([PuntajeData].self, from: data) {
            
            // Filtrar solo los puntajes del jugador específico
            let puntajesDelJugador = puntajesData
                .filter { $0.jugador == nombreJugador }
                .map { (jugador: $0.jugador, puntaje: $0.puntaje) }
                .sorted { $0.puntaje > $1.puntaje }
            
            puntajesMostrados = puntajesDelJugador
        } else {
            puntajesMostrados = []
        }
    }
    
    // Gestión de puntajes
    func guardarPuntajesEnUserDefaults() {
        // Esta función mantiene todos los puntajes, no solo los mostrados
        var todosPuntajes: [(jugador: String, puntaje: Int)] = []
        
        if let data = UserDefaults.standard.data(forKey: "top5Puntajes"),
           let puntajesData = try? JSONDecoder().decode([PuntajeData].self, from: data) {
            todosPuntajes = puntajesData.map { (jugador: $0.jugador, puntaje: $0.puntaje) }
        }
        
        let datos = todosPuntajes.map { PuntajeData(jugador: $0.jugador, puntaje: $0.puntaje) }
        if let encoded = try? JSONEncoder().encode(datos) {
            UserDefaults.standard.set(encoded, forKey: "top5Puntajes")
        }
    }
    
    func agregarNuevoPuntaje(_ puntaje: (jugador: String, puntaje: Int)) {
        // Cargar todos los puntajes actuales
        var todosPuntajes: [(jugador: String, puntaje: Int)] = []
        
        if let data = UserDefaults.standard.data(forKey: "top5Puntajes"),
           let puntajesData = try? JSONDecoder().decode([PuntajeData].self, from: data) {
            todosPuntajes = puntajesData.map { (jugador: $0.jugador, puntaje: $0.puntaje) }
        }
        
        // Agregar el nuevo puntaje
        todosPuntajes.append(puntaje)
        
        // Guardar todos los puntajes
        let datos = todosPuntajes.map { PuntajeData(jugador: $0.jugador, puntaje: $0.puntaje) }
        if let encoded = try? JSONEncoder().encode(datos) {
            UserDefaults.standard.set(encoded, forKey: "top5Puntajes")
        }
        
        // Recargar la vista actual
        cargarPuntajes()
        topPlayerTable.reloadData()
    }
}
extension TopViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return puntajesMostrados.isEmpty ? 1 : puntajesMostrados.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tipoVista {
        case .top5:
            return "Top 5 de Mejores Jugadores"
        case .top10:
            return "Top 10 de Mejores Jugadores"
        case .misPartidas:
            if let jugador = jugadorFiltrado {
                return "Partidas de \(jugador)"
            } else if let usuario = UserManager.shared.getCurrentUser() {
                return "Partidas de \(usuario.username)"
            } else {
                return "Mis Partidas"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "celdaConDetalle"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        if puntajesMostrados.isEmpty {
            // Mensajes personalizados según el tipo de vista
            switch tipoVista {
            case .top5, .top10:
                cell.textLabel?.text = "No hay puntajes registrados"
                cell.detailTextLabel?.text = "¡Sé el primero en jugar!"
            case .misPartidas:
                cell.textLabel?.text = "No tienes puntajes registrados"
                cell.detailTextLabel?.text = "¡Juega para obtener tu primer puntaje!"
            }
            cell.detailTextLabel?.textColor = .systemGray
        } else {
            let jugador = puntajesMostrados[indexPath.row]
            
            // Formato diferente según el tipo de vista
            switch tipoVista {
            case .top5, .top10:
                cell.textLabel?.text = "\(indexPath.row + 1). \(jugador.jugador)"
                cell.detailTextLabel?.text = "\(jugador.puntaje) pts"
                cell.detailTextLabel?.textColor = .red
            case .misPartidas:
                cell.textLabel?.text = "Partida \(indexPath.row + 1)"
                cell.detailTextLabel?.text = "\(jugador.puntaje) pts"
                cell.detailTextLabel?.textColor = .systemGreen
            }
        }
        
        return cell
    }
}
