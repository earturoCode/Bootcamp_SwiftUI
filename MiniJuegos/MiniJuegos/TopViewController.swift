    import UIKit

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
            setupNavigationTitle()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            cargarPuntajesDesdeBackend()
        }

        private func setupTableView() {
            topPlayerTable.dataSource = self
            topPlayerTable.delegate = self
        }
        private func setupNavigationTitle() {
                switch tipoVista {
                case .top5:
                    title = "Top 5 - Tocame"
                case .top10:
                    title = "Top 10 General"
                case .misPartidas:
                    title = "Mis Partidas"
                }
            }
            
            func cargarPuntajesDesdeBackend() {
                Task {
                    do {
                        var scores: [Score]
                        
                        switch tipoVista {
                        case .top5:
                            scores = try await APIService.shared.getScore(gameId: "tocame")
                            // o con userId también
                            puntajesMostrados = Array(scores.prefix(5))
                                .map { ($0.user_id, $0.score) }
                            
                        case .top10:
                            scores = try await APIService.shared.getScore(requiresAuth: false)
                            puntajesMostrados = Array(scores.prefix(10))
                                .map { ($0.user_id, $0.score) }
                            
                        case .misPartidas:
                            let jugador = jugadorFiltrado ?? UserDefaults.standard.string(forKey: "UserID") ?? ""
                            scores = try await APIService.shared.getScore(gameId: "tocame", userId: jugador)
                        }
                        
                        DispatchQueue.main.async {
                            self.topPlayerTable.reloadData()
                        }
                        
                    } catch {
                        print("Error al cargar puntajes: \(error)")
                        DispatchQueue.main.async {
                            self.showErrorAlert()
                        }
                    }
                }
            }
            
            private func showErrorAlert() {
                let alert = UIAlertController(
                    title: "Error",
                    message: "No se pudieron cargar los puntajes",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }

extension TopViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return puntajesMostrados.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PuntajeCell", for: indexPath)
        let puntaje = puntajesMostrados[indexPath.row]
        
        // Configurar la celda
        cell.textLabel?.text = "\(indexPath.row + 1). \(puntaje.jugador)"
        cell.detailTextLabel?.text = "Puntaje: \(puntaje.puntaje)"
        
        // Estilo para el top 3
        if indexPath.row < 3 && tipoVista != .misPartidas {
            cell.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.3)
        } else {
            cell.backgroundColor = UIColor.systemBackground
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

      
