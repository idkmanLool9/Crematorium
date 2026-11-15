import SwiftUI
import MapKit

struct KaartView: View {
    @Environment(Gegevens.self) private var gegevens
    @State private var positie: MapCameraPosition = .region(
        MKCoordinateRegion(center: .init(latitude: 51.4, longitude: 9.0),
                           span: MKCoordinateSpan(latitudeDelta: 8.5, longitudeDelta: 8.5)))
    @State private var keuze: Onderneming?
    @State private var toonVerkeer = false

    /// Boven de duizend punten wordt een kaart traag. Bij ver uitzoomen tonen we
    /// daarom alleen wat dichtbij ligt; zodra je inzoomt komt de rest erbij.
    @State private var zichtbaar: [Onderneming] = []

    var body: some View {
        NavigationStack {
            Map(position: $positie, selection: $keuze) {
                Annotation(gegevens.vertrekpunt.naam,
                           coordinate: gegevens.vertrekpunt.coordinaat) {
                    ZStack {
                        Circle().fill(Kleur.zone(1).opacity(0.2)).frame(width: 26, height: 26)
                        Circle().fill(Kleur.zone(1)).frame(width: 11, height: 11)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
                .annotationTitles(.visible)

                ForEach(zichtbaar) { o in
                    Marker(o.titel, coordinate: o.coordinaat)
                        .tint(Kleur.zone(o.zone))
                        .tag(o)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll, showsTraffic: toonVerkeer))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                werkBij(regio: context.region)
            }
            .navigationTitle("Kaart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(isOn: $toonVerkeer) {
                        Label("Verkeer", systemImage: "car.fill")
                    }
                    .toggleStyle(.button)
                }
            }
            .navigationDestination(item: $keuze) { DetailView(onderneming: $0) }
            .onAppear { werkBij(regio: nil) }
        }
    }

    private func werkBij(regio: MKCoordinateRegion?) {
        let kandidaten = gegevens.gefilterd
        guard let regio else {
            zichtbaar = Array(kandidaten.prefix(400))
            return
        }
        let marge = 1.25
        let dLat = regio.span.latitudeDelta * marge / 2
        let dLon = regio.span.longitudeDelta * marge / 2
        let inBeeld = kandidaten.filter {
            abs($0.lat - regio.center.latitude) < dLat && abs($0.lon - regio.center.longitude) < dLon
        }
        // Ver uitgezoomd: de dichtstbijzijnde eerst, en afkappen.
        zichtbaar = inBeeld.count <= 500 ? inBeeld : Array(inBeeld.sorted { $0.kmOzn < $1.kmOzn }.prefix(500))
    }
}
