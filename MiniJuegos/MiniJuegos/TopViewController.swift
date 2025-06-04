import UIKit

// MARK: - Modelos
struct Score: Codable {
    let user_id: String
    let game_id: String
    let score: Int
    let date: String
}

enum TipoVista {
    case top5           // Top 5 - Tocame
    case top10          // Top 10 para login
    case misPartidas    // Solo partidas del jugador actual
}

class TopViewController: UIViewController {

    @IBOutlet weak var topPlayerTable: UITableView!
    
    var puntajesMostrados: [(jugador: String, puntaje: Int)] = []
    var tipoVista: TipoVista = .top5
    var jugadorFiltrado: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        cargarPuntajesDesdeBackend()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarPuntajesDesdeBackend()
    }

    private func setupTableView() {
        topPlayerTable.dataSource = self
        topPlayerTable.delegate = self
    }

    // MARK: - Lógica de red
    func fetchTopScores(completion: @escaping ([Score]) -> Void) {
        guard let url = URL(string: "https://tu-api.com/api/scores") else {
            print("URL inválida")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error al obtener los puntajes: \(error)")
                return
            }

            guard let data = data else {
                print("No se recibió data")
                return
            }

            do {
                let scores = try JSONDecoder().decode([Score].self, from: data)
                DispatchQueue.main.async {
                    completion(scores)
                }
            } catch {
                print("Error al decodificar: \(error)")
            }
        }.resume()
    }

    // MARK: - Lógica para adaptar los puntajes mostrados
    func cargarPuntajesDesdeBackend() {
        fetchTopScores { [weak self] scores in
            guard let self = self else { return }

            switch self.tipoVista {
            case .top5:
                self.puntajesMostrados = scores
                    .sorted { $0.score > $1.score }
                    .prefix(5)
                    .map { ($0.user_id, $0.score) }

            case .top10:
                self.puntajesMostrados = scores
                    .sorted { $0.score > $1.score }
                    .prefix(10)
                    .map { ($0.user_id, $0.score) }

            case .misPartidas:
                guard let jugador = self.jugadorFiltrado else { return }
                self.puntajesMostrados = scores
                    .filter { $0.user_id == jugador }
                    .sorted { $0.score > $1.score }
                    .map { ($0.user_id, $0.score) }
            }

            self.topPlayerTable.reloadData()
        }
    }
}

// MARK: - UITableViewDataSource & Delegate
extension TopViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return puntajesMostrados.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PuntajeCell", for: indexPath)
        let puntaje = puntajesMostrados[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row + 1). \(puntaje.jugador)"
        cell.detailTextLabel?.text = "Puntaje: \(puntaje.puntaje)"
        return cell
    }
}
