import Foundation
import SwiftData

/// Notitie en logboek bij één onderneming.
///
/// Alles heeft een standaardwaarde en niets is uniek-verplicht: dat is wat
/// CloudKit eist. Zodra iCloud aanstaat synchroniseert dit vanzelf tussen
/// toestellen, zonder dat er aan dit model iets verandert.
@Model
final class Aantekening {
    /// De `id` van de onderneming uit app-data.json.
    var sleutel: String = ""
    var notitie: String = ""
    var gewijzigd: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \Contactmoment.aantekening)
    var log: [Contactmoment]? = []

    init(sleutel: String) {
        self.sleutel = sleutel
    }

    var logGesorteerd: [Contactmoment] {
        (log ?? []).sorted { $0.datum > $1.datum }
    }

    var isLeeg: Bool {
        notitie.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && (log ?? []).isEmpty
    }
}

@Model
final class Contactmoment {
    var datum: Date = Date.now
    var soort: String = Soort.folder.rawValue
    var tekst: String = ""
    var aantekening: Aantekening?

    init(datum: Date = .now, soort: Soort, tekst: String) {
        self.datum = datum
        self.soort = soort.rawValue
        self.tekst = tekst
    }

    var soortWaarde: Soort { Soort(rawValue: soort) ?? .overig }

    enum Soort: String, CaseIterable, Identifiable {
        case folder      = "Folder verstuurd"
        case geenGehoor  = "Gebeld — geen gehoor"
        case gesproken   = "Gebeld — gesproken"
        case interesse   = "Interesse"
        case geenInteresse = "Geen interesse"
        case afspraak    = "Afspraak"
        case overig      = "Overig"
        var id: String { rawValue }
    }
}
