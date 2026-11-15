# Crematorium — context

Nederlandstalig project. Antwoord in het Nederlands.

## Wat dit is

Levi (Oldenzaal) bouwt samen met Kevin van **OZN in Oldenzaal** een aanbod:
crematie in Nederland, gericht op Duitse nabestaanden. Voorlopig draait alles
onder de bedrijfsnaam van OZN; een eigen KvK-inschrijving komt pas als het iets
wordt.

De volgorde is bewust: **eerst Duitse uitvaartondernemers vinden die partner
willen worden, daarna pas een crematorium vastleggen.** De Duitse ondernemer
brengt de overledene over de grens; daarom wordt alles gemeten vanaf de
**landsgrens**, niet vanaf OZN. Dat is een expliciete keuze van Levi.

## Stand van zaken

- **A-lijst is geverifieerd en klaar om te versturen.** 226 adressen voor de
  folder, 16 om eerst na te bellen, 18 waarschijnlijk gestopt, 15 niet
  versturen (dubbelen en hoofdkantoren).
- **De folder ligt stil.** Mist nog de gegevens van OZN: bedrijfsnaam zoals
  ingeschreven, adres, telefoon, mailadres, contactpersoon en het prijsmodel.
  In alle concepten staat daar nu `[PLACEHOLDER]`.
- **De webpagina in deze repo is af en in gebruik.** Kaart, lijst, marktcijfers,
  navigatieknop, notities en logboek. Draait als los bestand en kan op het
  beginscherm.
- **Volgende stap: een native iOS-app**, voor iPhone en iPad, in SwiftUI.
  Reden om native te gaan is niet de kaart maar het **delen van aantekeningen**
  tussen Levi en Kevin via CloudKit.

## Wat er in de repo staat

| bestand | wat |
|---|---|
| `index.html` | de volledige webpagina, één bestand, gegevens inline |
| `app-data.json` | alle 3.788 vestigingen plus marktcijfers, voor de app |
| `manifest.webmanifest`, `sw.js`, `icon-*.png` | om de pagina op het beginscherm te zetten |
| `data/` | de onderliggende cijfers per deelstaat |

De velduitleg van `app-data.json` staat in `README.md`.

## Wat je moet weten over de gegevens

- **Vestigingen komen uit OpenStreetMap.** Alleen de A-lijst is één voor één
  nagelopen via het Impressum, met een telefoonnummercontrole op netnummer om
  filialen van hoofdkantoren te scheiden. B, C en D zijn **niet** geverifieerd.
  Kijk naar `prioriteit` en `status` voordat je iets als bevestigd behandelt.
- **De lijst mist ongeveer 30% van de markt.** OSM kent niet elke onderneming;
  afgezet tegen de landelijke vuistregel van 180 uitvaarten per onderneming
  ontbreken er naar schatting 1.300 in dit gebied.
- **Afstanden zijn hemelsbreed.** De zones (vijf banden van 80 km vanaf de
  grens) zijn daarop gebouwd en moeten dat blijven. Wat de gebruiker ziet is een
  schatting van de rijafstand met een omrijfactor. In de app hoort dit vervangen
  te worden door `MKDirections`, dat de echte rijafstand en reistijd geeft.
- **Marktcijfers reconciliëren op Destatis**: 83.467.117 inwoners en 1.006.343
  overledenen over 2025. Het crematieaandeel komt uit een enquête onder
  begraafplaatsbeheerders met een respons van een derde — een schatting, geen
  telling, en die telt as buiten de begraafplaats niet mee.
- Twee factoren in het verdienmodel bestaan nergens: welk deel via een partner
  binnenkomt, en welk deel van de nabestaanden crematie in Nederland accepteert.
  Niet invullen, niet schatten. Die blijken pas uit de folderronde.

## Beslissingen die al genomen zijn

- **Geen CarPlay.** Apple geeft daarvoor alleen een entitlement in een vaste
  categorie, en een lijst met adressen in de buurt valt onder "winkelzoeker",
  wat expliciet uitgesloten is. In de auto loopt het via Siri-acties en een
  overdracht naar Apple of Google Maps.
- **MapKit, niet Google Maps.** Gratis, geen sleutel, geen betaalprofiel, en het
  gedraagt zich als iOS.
- **SwiftUI**, zodat dezelfde app op iPhone en iPad draait.
- Navigeren gebeurt op coördinaat, niet op adres: een coördinaat kan nooit naar
  de verkeerde plaats wijzen.

## Toon

Levi werkt snel en in korte berichten. Geen lange uitleg vooraf, wel eerlijk
zijn over wat niet kan of niet klopt. Fouten in de gegevens zijn duur: hieraan
hangen folders die echt verstuurd worden.
