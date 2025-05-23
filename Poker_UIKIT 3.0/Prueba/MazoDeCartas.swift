import Foundation

struct Carta {
    let valor: String
    let palo: String

    func mostrar() -> String {
        return "\(valor)\(palo)"
    }

    func valoresCartas() -> Int {
        switch valor {
        case "A": return 14
        case "K": return 13
        case "Q": return 12
        case "J": return 11
        case "T": return 10
        default: return Int(valor) ?? 0
        }
    }
}

// Jugador tiene un nombre y cartas en la mano
struct Jugador {
    let nombre: String
    var cartas: [Carta]
    var tipoJugada: String?

    init(nombre: String) {
        self.nombre = nombre
        self.cartas = []
        self.tipoJugada = nil
    }

    // Muestra las cartas del jugador
    func mostrarCartas() {
        print("\(nombre) tiene: ", terminator: "")
        for carta in cartas {
            print(carta.mostrar() + " ", terminator: "")
        }
        print("")
    }
}

//Clase para gestionar el mazo de cartas
class MazoDeCartas {
    var cartas: [Carta] = []

    // Constructor que crea todas las cartas
    init() {
        let valores = [
            "A", "2", "3", "4", "5", "6", "7", "8", "9", "T", "J", "Q", "K",
        ]
        let palos = ["S", "H", "D", "C"]

        // Crear cada combinación de valor y palo
        for palo in palos {
            for valor in valores {
                let nuevaCarta = Carta(valor: valor, palo: palo)
                cartas.append(nuevaCarta)
            }
        }
    }

    // Mezcla las cartas con shuffle()
    func mezclar() {
        cartas.shuffle()
    }

    //Reparte una carta del mazo
    func sacarCarta() -> Carta? {
        if cartas.isEmpty {
            return nil
        }
        return cartas.removeFirst()
    }

    // Entrega 5 cartas para una mano
    func darMano() -> [Carta] {
        var mano: [Carta] = []

        // Intenta dar 5 cartas
        for _ in 1...5 {
            if let carta = sacarCarta() {
                mano.append(carta)
            } else {
                break  // Si no hay más cartas, termina
            }
        }

        return mano
    }
}

// Función  para detectar si hay una escalera
func esEscalera(_ cartas: [Carta]) -> Bool {
    // Obtener los valores y ordenarlos
    var valores: [Int] = cartas.map { $0.valoresCartas() }
    valores.sort()

    // Eliminar duplicados para manejar posibles errores
    let valoresUnicos = Array(Set(valores)).sorted()

    // Caso especial: A-2-3-4-5
    if valoresUnicos == [2, 3, 4, 5, 14] {
        return true
    }

    // Debe haber 5 valores distintos
    if valoresUnicos.count != 5 {
        return false
    }

    // Comprobar si cada valor es uno más que el anterior
    for i in 0..<valoresUnicos.count - 1 {  //Verificar que estén en secuencia, sino no cumple no es escalera
        if valoresUnicos[i + 1] != valoresUnicos[i] + 1 {
            return false
        }
    }

    return true
}

// Función simple para detectar si hay color (mismo palo)
func esColor(_ cartas: [Carta]) -> Bool {
    let primerPalo = cartas[0].palo

    // Si alguna carta tiene palo diferente, no es color
    for carta in cartas {
        if carta.palo != primerPalo {
            return false
        }
    }

    return true  //Si pasó todas las pruebas, es escalera
}

// Función para contar repeticiones de cada valor
func contarRepeticiones(_ cartas: [Carta]) -> [Int] {
    var conteo: [Int: Int] = [:]  //Diccionario

    // Contar cuántas veces aparece cada valor
    for carta in cartas {
        let valor = carta.valoresCartas()
        if conteo[valor] != nil {
            conteo[valor]! += 1
        } else {
            conteo[valor] = 1
        }
    }

    // Ordenar las repeticiones de mayor a menor
    return conteo.values.sorted(by: >)
}

// Función para encontrar el tipo de jugada
func analizarJugada(_ cartas: [Carta]) -> String {
    let hayEscalera = esEscalera(cartas)
    let hayColor = esColor(cartas)
    let repeticiones = contarRepeticiones(cartas)

    // Verificar cada jugada posible en orden de importancia
    if hayEscalera && hayColor {
        return "Escalera de Color"
    } else if repeticiones == [4, 1] {
        return "Póker"
    } else if repeticiones == [3, 2] {
        return "Full House"
    } else if hayColor {
        return "Color"
    } else if hayEscalera {
        return "Escalera"
    } else if repeticiones.first == 3 {
        return "Trío"
    } else if repeticiones == [2, 2, 1] {
        return "Doble Par"
    } else if repeticiones.first == 2 {
        return "Par"
    } else {
        return "Carta Alta"
    }
}

//Se evalua cada jugada posible
func valorJugada(_ jugada: String) -> Int {
    switch jugada {
    case "Escalera de Color":
        return 8
    case "Póker":
        return 7
    case "Full House":
        return 6
    case "Color":
        return 5
    case "Escalera":
        return 4
    case "Trío":
        return 3
    case "Doble Par":
        return 2
    case "Par":
        return 1
    default:
        return 0  // Carta Alta
    }
}

// Función para el desempate
func compararCartasAltas(_ cartas1: [Carta], _ cartas2: [Carta]) -> Int {
    let valores1 = cartas1.map { $0.valoresCartas() }.sorted(by: >)
    let valores2 = cartas2.map { $0.valoresCartas() }.sorted(by: >)

    // Comparar carta por carta
    for i in 0..<min(valores1.count, valores2.count) {
        if valores1[i] > valores2[i] {
            return 1
        } else if valores2[i] > valores1[i] {
            return 2
        }
    }

    return 0  // Empate verdadero (todas las cartas iguales)
}

// Función para mostrar el valor como texto
func mostrarValor(_ valor: Int) -> String {
    switch valor {
    case 14:
        return "As"
    case 13:
        return "Rey"
    case 12:
        return "Reina"
    case 11:
        return "Jota"
    case 10:
        return "10"
    default:
        return "\(valor)"
    }
}

// Función para determinar quién gana
func quienGana(_ jugador1: Jugador, _ jugador2: Jugador) -> String {
    // Asegurarse de que hay jugadas detectadas
    guard let jugada1 = jugador1.tipoJugada, let jugada2 = jugador2.tipoJugada
    else {
        return "Error: falta analizar las jugadas"
    }

    let valor1 = valorJugada(jugada1)
    let valor2 = valorJugada(jugada2)

    // Comparar los valores de las jugadas
    if valor1 > valor2 {
        return "\(jugador1.nombre) gana con \(jugada1)"
    } else if valor2 > valor1 {
        return "\(jugador2.nombre) gana con \(jugada2)"
    } else {
        // Si tienen la misma jugada, comparar todas las cartas en orden
        let resultado = compararCartasAltas(jugador1.cartas, jugador2.cartas)

        if resultado == 1 {

            let valoresOrdenados = jugador1.cartas.map { $0.valoresCartas() }
                .sorted(by: >)
            let cartasTexto = valoresOrdenados.map { mostrarValor($0) }.joined(
                separator: ", "
            )
            return
                "\(jugador1.nombre) gana con \(jugada1) (cartas altas: \(cartasTexto))"
        } else if resultado == 2 {
            let valoresOrdenados = jugador2.cartas.map { $0.valoresCartas() }
                .sorted(by: >)
            let cartasTexto = valoresOrdenados.map { mostrarValor($0) }.joined(
                separator: ", "
            )
            return
                "\(jugador2.nombre) gana con \(jugada2) (cartas altas: \(cartasTexto))"
        } else {
            return
                "¡Empate perfecto! Ambos tienen exactamente las mismas cartas."
        }
    }
}

func jugarPoker() {

    // Crear y preparar el mazo
    let mazo = MazoDeCartas()
    print("Mazo creado con \(mazo.cartas.count) cartas")

    // Mezclar las cartas
    mazo.mezclar()
    print("Mezclando mazo...")

    // Crear jugadores
    var jugador1 = Jugador(nombre: "Pepito")
    var jugador2 = Jugador(nombre: "Jose")

    // Repartir cartas
    print("\nRepartiendo cartas...")
    jugador1.cartas = mazo.darMano()
    jugador2.cartas = mazo.darMano()

    // Mostrar las cartas de cada jugador
    jugador1.mostrarCartas()
    jugador2.mostrarCartas()

    // Analizar las jugadas
    print("\nAnalizando jugadas...")
    jugador1.tipoJugada = analizarJugada(jugador1.cartas)
    jugador2.tipoJugada = analizarJugada(jugador2.cartas)

    print("\(jugador1.nombre) tiene: \(jugador1.tipoJugada!)")
    print("\(jugador2.nombre) tiene: \(jugador2.tipoJugada!)")

    // Determinar el ganador
    print("\n_________RESULTADO_________")
    print(quienGana(jugador1, jugador2))
    print("___________________________")

}

