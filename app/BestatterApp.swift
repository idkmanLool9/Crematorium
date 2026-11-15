import SwiftUI
import SwiftData

@main
struct BestatterApp: App {
    @State private var gegevens = Gegevens()
    @State private var afstanden = Afstanden()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(gegevens)
                .environment(afstanden)
        }
        .modelContainer(for: [Aantekening.self, Contactmoment.self])
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Lijst", systemImage: "list.bullet") { LijstView() }
            Tab("Kaart", systemImage: "map") { KaartView() }
        }
    }
}
