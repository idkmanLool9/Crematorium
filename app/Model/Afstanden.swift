import Foundation
import MapKit

/// Echte rijafstand en reistijd via Apple Maps, op het toestel zelf berekend.
/// Gratis, geen sleutel. Resultaten worden onthouden zolang de app draait,
/// want elke aanvraag kost een netwerkrondje.
@Observable
final class Afstanden {
    struct Rit: Equatable {
        let meters: CLLocationDistance
        let seconden: TimeInterval

        var afstandTekst: String { (meters / 1000).kmTekst }
        var tijdTekst: String {
            let m = Int(seconden / 60)
            return m < 60 ? "\(m) min" : "\(m / 60) u \(m % 60) min"
        }
    }

    private var cache: [String: Rit] = [:]
    private var bezig: Set<String> = []

    func bekend(_ id: String) -> Rit? { cache[id] }

    /// Vraagt de rit op als we hem nog niet hebben. Mislukt dit (geen bereik,
    /// geen route), dan gebeurt er niets en blijft de schatting staan.
    @MainActor
    func haal(van vertrek: CLLocationCoordinate2D, naar doel: Onderneming) async {
        guard cache[doel.id] == nil, !bezig.contains(doel.id) else { return }
        bezig.insert(doel.id)
        defer { bezig.remove(doel.id) }

        let verzoek = MKDirections.Request()
        verzoek.source = MKMapItem(placemark: MKPlacemark(coordinate: vertrek))
        verzoek.destination = MKMapItem(placemark: MKPlacemark(coordinate: doel.coordinaat))
        verzoek.transportType = .automobile
        verzoek.departureDate = .now        // rekent mee met het verwachte verkeer

        do {
            let antwoord = try await MKDirections(request: verzoek).calculateETA()
            cache[doel.id] = Rit(meters: antwoord.distance, seconden: antwoord.expectedTravelTime)
        } catch {
            // Stil laten vallen: de schatting blijft zichtbaar.
        }
    }
}
