import Foundation
import CoreLocation

/// Eén vestiging uit app-data.json. Alleen lezen; dit verandert nooit tijdens gebruik.
struct Onderneming: Identifiable, Hashable, Decodable {
    let id: String
    let naam: String?
    let straat: String?
    let postcode: String?
    let plaats: String?
    let kreis: String?
    let bundesland: String?
    let lat: Double
    let lon: Double
    let kmGrens: Double
    let kmOzn: Double
    let zone: Int
    let telefoon: [String]?
    let email: [String]?
    let website: [String]?
    let prioriteit: String?
    let status: String?

    var titel: String { naam ?? "Naam niet bekend" }
    var coordinaat: CLLocationCoordinate2D { .init(latitude: lat, longitude: lon) }

    /// Adres op één regel, voor onder de naam.
    var adresRegel: String {
        let plaatsDeel = [postcode, plaats].compactMap { $0 }.joined(separator: " ")
        return [straat, plaatsDeel].compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    var heeftAdres: Bool { straat != nil && plaats != nil }
    var eersteTelefoon: String? { telefoon?.first }
    var eersteMail: String? { email?.first }
    var eersteSite: URL? { website?.first.flatMap(URL.init(string:)) }

    /// Zoeken op naam, plaats, Kreis en postcode tegelijk.
    func past(bij tekst: String) -> Bool {
        guard !tekst.isEmpty else { return true }
        let n = tekst.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let hooiberg = [naam, plaats, kreis, postcode, bundesland]
            .compactMap { $0 }
            .joined(separator: " ")
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        return hooiberg.contains(n)
    }
}

struct Vertrekpunt: Decodable {
    let naam: String
    let lat: Double
    let lon: Double
    var coordinaat: CLLocationCoordinate2D { .init(latitude: lat, longitude: lon) }
}

struct ZoneBand: Decodable, Identifiable {
    let zone: Int
    let van: Int
    let tot: Int
    var id: Int { zone }
    var omschrijving: String { "\(van)–\(tot) km" }
}

struct Bestand: Decodable {
    let versie: Int
    let bijgewerkt: String
    let vertrekpunt: Vertrekpunt
    let zones: [ZoneBand]
    let ondernemingen: [Onderneming]
}
