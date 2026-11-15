import Foundation
import Observation

/// Laadt app-data.json uit de bundel en houdt de filters bij.
@Observable
final class Gegevens {
    private(set) var alle: [Onderneming] = []
    private(set) var zones: [ZoneBand] = []
    private(set) var vertrekpunt = Vertrekpunt(naam: "OZN, Oldenzaal", lat: 52.3125, lon: 6.9319)
    private(set) var laadfout: String?

    var zoek: String = ""
    var zichtbareZones: Set<Int> = [1, 2, 3, 4, 5]
    var alleenMetTelefoon = false
    var prioriteiten: Set<String> = []          // leeg = alles
    var sortering: Sortering = .ozn

    enum Sortering: String, CaseIterable, Identifiable {
        case ozn = "Dichtstbij OZN"
        case grens = "Dichtstbij de grens"
        case naam = "Op naam"
        var id: String { rawValue }
    }

    init() { laad() }

    private func laad() {
        guard let url = Bundle.main.url(forResource: "app-data", withExtension: "json") else {
            laadfout = "app-data.json zit niet in de bundel. Sleep het bestand in het project en zet het aan onder Target → Build Phases → Copy Bundle Resources."
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let bestand = try JSONDecoder().decode(Bestand.self, from: data)
            alle = bestand.ondernemingen
            zones = bestand.zones
            vertrekpunt = bestand.vertrekpunt
        } catch {
            laadfout = "app-data.json kon niet gelezen worden: \(error.localizedDescription)"
        }
    }

    /// De lijst zoals hij op dit moment getoond moet worden.
    var gefilterd: [Onderneming] {
        var r = alle.filter { o in
            zichtbareZones.contains(o.zone)
                && o.past(bij: zoek)
                && (!alleenMetTelefoon || o.eersteTelefoon != nil)
                && (prioriteiten.isEmpty || prioriteiten.contains(o.prioriteit ?? ""))
        }
        switch sortering {
        case .ozn:   r.sort { $0.kmOzn < $1.kmOzn }
        case .grens: r.sort { $0.kmGrens < $1.kmGrens }
        case .naam:  r.sort { $0.titel.localizedStandardCompare($1.titel) == .orderedAscending }
        }
        return r
    }

    func band(voor zone: Int) -> ZoneBand? { zones.first { $0.zone == zone } }

    /// Hemelsbreed naar een schatting over de weg. Duitsland heeft een mediane
    /// omrijfactor van 1,20; korte ritten rijden relatief verder om dan lange.
    /// Dit is een noodoplossing: zodra MKDirections de echte afstand geeft,
    /// hoort die hier te vervangen.
    static func geschatteRijafstand(_ km: Double) -> Double {
        let factor = km < 30 ? 1.32 : (km < 150 ? 1.26 : 1.20)
        return km * factor
    }
}

extension Double {
    /// "16 km" of "6,6 km"
    var kmTekst: String {
        self < 10 ? String(format: "%.1f km", self).replacingOccurrences(of: ".", with: ",")
                  : String(format: "%.0f km", self)
    }
}
