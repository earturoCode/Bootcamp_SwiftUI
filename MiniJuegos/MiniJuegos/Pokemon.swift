import Foundation
import Alamofire
import UIKit

struct Pokemon: Decodable {
    let name: String
    let height: Int
    let weight: Int
}
class PokeViewController: UIViewController {

    let nameLabel = UILabel()
    let heightLabel = UILabel()
    let weightLabel = UILabel()
    let searchButton = UIButton(type: .system)
    let textField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }

    func setupUI() {
        // TextField
        textField.placeholder = "Nombre del Pokémon"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)

        // Button
        searchButton.setTitle("Buscar", for: .normal)
        searchButton.addTarget(self, action: #selector(searchPokemon), for: .touchUpInside)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchButton)

        // Labels
        [nameLabel, heightLabel, weightLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.systemFont(ofSize: 18)
            view.addSubview($0)
        }

        // Constraints
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.widthAnchor.constraint(equalToConstant: 200),

            searchButton.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 20),
            searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            nameLabel.topAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 40),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            heightLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            heightLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            weightLabel.topAnchor.constraint(equalTo: heightLabel.bottomAnchor, constant: 20),
            weightLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    @objc func searchPokemon() {
        guard let name = textField.text?.lowercased(), !name.isEmpty else {
            showError("Escribe un nombre de Pokémon")
            return
        }

        let url = "https://pokeapi.co/api/v2/pokemon/\(name)"

        AF.request(url).responseDecodable(of: Pokemon.self) { response in
            switch response.result {
            case .success(let pokemon):
                self.nameLabel.text = "Nombre: \(pokemon.name.capitalized)"
                self.heightLabel.text = "Altura: \(pokemon.height)"
                self.weightLabel.text = "Peso: \(pokemon.weight)"
            case .failure:
                self.showError("Pokémon no encontrado")
            }
        }
    }

    func showError(_ message: String) {
        nameLabel.text = ""
        heightLabel.text = ""
        weightLabel.text = ""
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

