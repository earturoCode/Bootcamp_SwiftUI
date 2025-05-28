import UIKit

class TopViewController: UIViewController {

    @IBOutlet weak var topPlayerTable: UITableView!
    // Array para almacenar los puntajes (será actualizado desde ThirdViewController)
    var top5Puntajes: [(jugador: String, puntaje: Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        if top5Puntajes.isEmpty {
            cargarPuntajesDesdeUserDefaults()
        } else {
            // Ya se pasaron puntajes desde ThirdViewController, no recargar
        }

        
        // Configurar la vista
        self.title = "Top 5 Jugadores"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Recargar datos cada vez que aparece la vista
        topPlayerTable.reloadData()
    }
    
    func setupTableView() {
        
        
        topPlayerTable.dataSource = self
        topPlayerTable.delegate = self
        
        // Configuración adicional de la tabla
        topPlayerTable.backgroundColor = UIColor.systemGroupedBackground
        topPlayerTable.separatorStyle = .singleLine
        topPlayerTable.rowHeight = 60
    }
    
    
    // Función para cargar puntajes desde UserDefaults
    func cargarPuntajesDesdeUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "top5Puntajes"),
           let puntajesData = try? JSONDecoder().decode([PuntajeData].self, from: data) {
            top5Puntajes = puntajesData.map { (jugador: $0.jugador, puntaje: $0.puntaje) }
        } else {
            // Si no hay datos guardados, mostrar datos por defecto
            top5Puntajes = [
                ("Juan", 120),
                ("Ana", 100),
                ("Luis", 90),
                ("Carlos", 70)
            ]
        }
    }
    
    // Función para agregar y ordenar un nuevo puntaje (si es necesario)
    func agregarNuevoPuntaje(_ puntaje: (jugador: String, puntaje: Int)) {
        // Agregar el nuevo puntaje al array
        top5Puntajes.append(puntaje)
        
        // Ordenar por puntaje de mayor a menor
        top5Puntajes.sort { $0.puntaje > $1.puntaje }
        
        // Mantener solo los top 5
        if top5Puntajes.count > 5 {
            top5Puntajes = Array(top5Puntajes.prefix(5))
        }
        
        // Actualizar la tabla
        topPlayerTable.reloadData()
    }
}
    
  

extension TopViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return top5Puntajes.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Top 5 de Mejores jugadores"
    }
    
    
//    Se llama cada vez que el tableView necesita una Celda para cada jugador, nombre y puntaje.
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Se define un identificador de celda.
        let cellIdentifier = "celdaConDetalle"
        // Actualiza la celda con el mejor puntaje
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        // Se crea una celda nueva si no hay ninguna disponible
        if cell == nil {
          cell = UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        }
        // Se obtiene el mejor jugador
        let jugador = top5Puntajes[indexPath.row]
        // Se asignan los textos a los labels
          cell?.textLabel?.text = jugador.jugador
        cell?.detailTextLabel?.text = "\(jugador.puntaje) pts"
        return cell!
      }
        
    }
// Estructura para UserDefaults
struct PuntajeData: Codable {
    let jugador: String
    let puntaje: Int
}


