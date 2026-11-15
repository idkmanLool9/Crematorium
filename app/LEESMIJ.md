# De app in Xcode zetten

De Swift-bestanden staan hier klaar. Het enige wat op een Mac moet gebeuren:

1. **Xcode → File → New → Project → iOS → App.**
   Naam `Bestatter`, interface **SwiftUI**, taal **Swift**, storage **None**
   (SwiftData zetten we zelf op). Sla hem op in deze map.
2. **Sleep de map `app/` in de projectnavigator**, met *Copy items if needed*
   uit — de bestanden staan hier al. Verwijder het lege `ContentView.swift`
   en de `…App.swift` die Xcode zelf maakte: `BestatterApp.swift` vervangt die.
3. **Sleep `app-data.json` erbij** en controleer onder *Target → Build Phases →
   Copy Bundle Resources* dat het bestand erin staat. Zonder die stap vindt de
   app zijn gegevens niet en krijg je een nette foutmelding in beeld.
4. **Bouwen en draaien.** Werkt op de simulator en op je eigen toestel.

## Later, als het betaalde account actief is

Voor synchronisatie tussen jou en Kevin:

- *Target → Signing & Capabilities → + Capability → iCloud*, vink **CloudKit**
  aan en maak een container.
- Voeg **Background Modes → Remote notifications** toe.
- In `BestatterApp.swift` de modelcontainer op CloudKit zetten.

Het datamodel is daar al op gebouwd: alle velden hebben een standaardwaarde en
er zijn geen unieke sleutels, want dat eist CloudKit. Er hoeft dus niets aan
`Aantekening.swift` te veranderen.

## Wat nog ontbreekt

- **Dagroute.** Meerdere adressen in één rit, door de app op volgorde gezet en
  doorgegeven aan Apple Maps (tot vijftien stops). Dit is het stuk dat Maps
  zelf niet doet en dat de app de moeite waard maakt.
- **Siri-acties**, zodat je onderweg handsfree het volgende adres krijgt en na
  een bezoek iets kunt inspreken.
- **Clustering op de kaart.** Nu wordt er afgekapt op 500 punten in beeld.
- De schatting van de rijafstand hoort te verdwijnen zodra `MKDirections`
  overal het echte getal levert; die code staat in `Afstanden.swift`.
