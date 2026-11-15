import SwiftUI
import SwiftData

struct LijstView: View {
    @Environment(Gegevens.self) private var gegevens
    @Query private var aantekeningen: [Aantekening]
    @State private var keuze: Onderneming?

    private var metAantekening: Set<String> {
        Set(aantekeningen.filter { !$0.isLeeg }.map(\.sleutel))
    }

    var body: some View {
        @Bindable var g = gegevens
        NavigationStack {
            Group {
                if let fout = gegevens.laadfout {
                    ContentUnavailableView("Gegevens ontbreken", systemImage: "exclamationmark.triangle", description: Text(fout))
                } else {
                    lijst
                }
            }
            .navigationTitle("Ondernemingen")
            .searchable(text: $g.zoek, prompt: "Naam, plaats of Kreis")
            .toolbar { toolbar }
            .navigationDestination(item: $keuze) { DetailView(onderneming: $0) }
        }
    }

    private var lijst: some View {
        List {
            Section {
                ForEach(gegevens.gefilterd) { o in
                    Button { keuze = o } label: {
                        Regel(onderneming: o, heeftAantekening: metAantekening.contains(o.id))
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("^[\(gegevens.gefilterd.count) onderneming](inflect: true)")
            }
        }
        .listStyle(.plain)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            @Bindable var g = gegevens
            Menu {
                Picker("Sorteren", selection: $g.sortering) {
                    ForEach(Gegevens.Sortering.allCases) { Text($0.rawValue).tag($0) }
                }
                Divider()
                Toggle("Alleen met telefoonnummer", isOn: $g.alleenMetTelefoon)
                Divider()
                Menu("Zones") {
                    ForEach(gegevens.zones) { band in
                        Toggle(isOn: Binding(
                            get: { g.zichtbareZones.contains(band.zone) },
                            set: { aan in
                                if aan { g.zichtbareZones.insert(band.zone) }
                                else { g.zichtbareZones.remove(band.zone) }
                            })) {
                                Text("Zone \(band.zone) · \(band.omschrijving)")
                            }
                    }
                }
                Menu("Prioriteit") {
                    ForEach(["A", "B", "C", "D"], id: \.self) { p in
                        Toggle(isOn: Binding(
                            get: { g.prioriteiten.contains(p) },
                            set: { aan in
                                if aan { g.prioriteiten.insert(p) } else { g.prioriteiten.remove(p) }
                            })) { Text(p) }
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
    }
}

private struct Regel: View {
    let onderneming: Onderneming
    let heeftAantekening: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            ZoneStip(zone: onderneming.zone)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Text(onderneming.titel)
                        .font(.body.weight(.medium))
                        .foregroundStyle(onderneming.naam == nil ? .secondary : .primary)
                    if heeftAantekening {
                        Circle().fill(.red).frame(width: 6, height: 6)
                    }
                }
                Text(onderneming.adresRegel.isEmpty ? (onderneming.kreis ?? "—") : onderneming.adresRegel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Text("±" + Gegevens.geschatteRijafstand(onderneming.kmOzn).kmTekst)
                    .font(.caption.monospacedDigit())
                if let p = onderneming.prioriteit {
                    Text(p).font(.caption2.weight(.semibold)).foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 3)
        .contentShape(Rectangle())
    }
}

struct ZoneStip: View {
    let zone: Int
    var body: some View {
        Circle()
            .fill(Kleur.zone(zone))
            .frame(width: 10, height: 10)
            .alignmentGuide(.firstTextBaseline) { $0[.bottom] - 1 }
    }
}

enum Kleur {
    /// Dezelfde reeks als op de webkaart: donkerrood dichtbij, licht ver weg.
    static func zone(_ z: Int) -> Color {
        switch z {
        case 1: Color(red: 0.50, green: 0.11, blue: 0.11)
        case 2: Color(red: 0.70, green: 0.19, blue: 0.15)
        case 3: Color(red: 0.85, green: 0.41, blue: 0.17)
        case 4: Color(red: 0.91, green: 0.66, blue: 0.31)
        case 5: Color(red: 0.95, green: 0.84, blue: 0.60)
        default: Color.gray.opacity(0.5)
        }
    }
}
