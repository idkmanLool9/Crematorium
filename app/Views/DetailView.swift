import SwiftUI
import SwiftData
import MapKit

struct DetailView: View {
    let onderneming: Onderneming

    @Environment(Gegevens.self) private var gegevens
    @Environment(Afstanden.self) private var afstanden
    @Environment(\.modelContext) private var context
    @Environment(\.openURL) private var openURL

    @State private var aantekening: Aantekening?
    @State private var nieuweDatum = Date.now
    @State private var nieuweSoort = Contactmoment.Soort.folder
    @State private var nieuweTekst = ""

    var body: some View {
        List {
            kopSectie
            contactSectie
            logboekSectie
            notitieSectie
        }
        .navigationTitle(onderneming.titel)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            haalAantekening()
            await afstanden.haal(van: gegevens.vertrekpunt.coordinaat, naar: onderneming)
        }
    }

    // MARK: - Kop

    private var kopSectie: some View {
        Section {
            if !onderneming.adresRegel.isEmpty {
                Text(onderneming.adresRegel)
            }
            LabeledContent("Vanaf OZN") {
                if let rit = afstanden.bekend(onderneming.id) {
                    Text("\(rit.afstandTekst) · \(rit.tijdTekst)")
                } else {
                    Text("±" + Gegevens.geschatteRijafstand(onderneming.kmOzn).kmTekst)
                        .foregroundStyle(.secondary)
                }
            }
            LabeledContent("Tot de grens", value: onderneming.kmGrens.kmTekst)
            LabeledContent("Zone") {
                HStack(spacing: 6) {
                    ZoneStip(zone: onderneming.zone)
                    Text(gegevens.band(voor: onderneming.zone).map { "\($0.zone) · \($0.omschrijving)" } ?? "buiten bereik")
                }
            }
            if let k = onderneming.kreis {
                LabeledContent("Kreis", value: k)
            }
            if let s = onderneming.status, !s.isEmpty {
                LabeledContent("Verificatie", value: s)
            }
        }
    }

    // MARK: - Contact

    private var contactSectie: some View {
        Section("Contact") {
            Button {
                openURL(navigatieURL)
            } label: {
                Label("Navigeer", systemImage: "location.fill")
            }

            if let tel = onderneming.eersteTelefoon,
               let url = URL(string: "tel://" + tel.filter { $0.isNumber || $0 == "+" }) {
                Button { openURL(url) } label: {
                    Label(tel, systemImage: "phone.fill")
                }
            }
            if let mail = onderneming.eersteMail, let url = URL(string: "mailto:" + mail) {
                Button { openURL(url) } label: {
                    Label(mail, systemImage: "envelope.fill")
                }
            }
            if let site = onderneming.eersteSite {
                Link(destination: site) {
                    Label(site.host() ?? site.absoluteString, systemImage: "safari.fill")
                }
            }
            if onderneming.eersteTelefoon == nil && onderneming.eersteMail == nil && onderneming.eersteSite == nil {
                Text("Geen contactgegevens bekend — alleen de locatie.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    /// Navigeren op coördinaat: dat kan nooit naar de verkeerde plaats wijzen.
    private var navigatieURL: URL {
        URL(string: "http://maps.apple.com/?daddr=\(onderneming.lat),\(onderneming.lon)&dirflg=d")!
    }

    // MARK: - Logboek

    private var logboekSectie: some View {
        Section("Logboek") {
            if let a = aantekening, !a.logGesorteerd.isEmpty {
                ForEach(a.logGesorteerd) { moment in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(moment.soortWaarde.rawValue).font(.subheadline.weight(.medium))
                            Spacer()
                            Text(moment.datum, format: .dateTime.day().month().year())
                                .font(.caption.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        if !moment.tekst.isEmpty {
                            Text(moment.tekst).font(.callout).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { verwijder(op: $0) }
            } else {
                Text("Nog geen contactmomenten.").foregroundStyle(.secondary)
            }

            DisclosureGroup("Toevoegen") {
                DatePicker("Datum", selection: $nieuweDatum, displayedComponents: .date)
                Picker("Soort", selection: $nieuweSoort) {
                    ForEach(Contactmoment.Soort.allCases) { Text($0.rawValue).tag($0) }
                }
                TextField("Korte aantekening (mag leeg)", text: $nieuweTekst, axis: .vertical)
                Button("Vastleggen") { voegToe() }
                    .disabled(false)
            }
        }
    }

    // MARK: - Notitie

    private var notitieSectie: some View {
        Section("Notitie") {
            TextField("Wat je wilt onthouden over deze onderneming.",
                      text: Binding(
                        get: { aantekening?.notitie ?? "" },
                        set: { nieuw in
                            let a = zorgVoorAantekening()
                            a.notitie = nieuw
                            a.gewijzigd = .now
                        }),
                      axis: .vertical)
                .lineLimit(3...10)
        }
    }

    // MARK: - Opslag

    private func haalAantekening() {
        let sleutel = onderneming.id
        var beschrijving = FetchDescriptor<Aantekening>(
            predicate: #Predicate { $0.sleutel == sleutel })
        beschrijving.fetchLimit = 1
        aantekening = try? context.fetch(beschrijving).first
    }

    @discardableResult
    private func zorgVoorAantekening() -> Aantekening {
        if let a = aantekening { return a }
        let a = Aantekening(sleutel: onderneming.id)
        context.insert(a)
        aantekening = a
        return a
    }

    private func voegToe() {
        let a = zorgVoorAantekening()
        let moment = Contactmoment(datum: nieuweDatum, soort: nieuweSoort,
                                   tekst: nieuweTekst.trimmingCharacters(in: .whitespacesAndNewlines))
        moment.aantekening = a
        context.insert(moment)
        a.gewijzigd = .now
        nieuweTekst = ""
        nieuweDatum = .now
    }

    private func verwijder(op indexen: IndexSet) {
        guard let a = aantekening else { return }
        let gesorteerd = a.logGesorteerd
        for i in indexen where gesorteerd.indices.contains(i) {
            context.delete(gesorteerd[i])
        }
        a.gewijzigd = .now
    }
}
