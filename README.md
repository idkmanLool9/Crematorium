# Crematie — kaart Duitse uitvaartondernemingen

Interactieve kaart van alle Duitse uitvaartondernemingen binnen 400 km van de
Nederlandse grens, verdeeld in vijf zones van 80 km. Vertrekpunt is OZN in Oldenzaal.

Bron van de vestigingen: OpenStreetMap. Afstanden zijn hemelsbreed, gemeten vanaf
de landsgrens (en vanaf OZN), niet via de weg.

## Gebruik

Eén statische pagina, geen server nodig. Open `index.html`, of zet de map op
GitHub Pages (Settings → Pages → Deploy from a branch → `main` / `/ (root)`).

Op iPhone/iPad: open de pagina in Safari, deel-knop → *Zet op beginscherm*.
De pagina werkt daarna ook zonder internet.

## app-data.json

Alle gegevens in één bestand, klaar om in een Xcode-project te leggen.

| veld | betekenis |
|---|---|
| `id` | stabiele sleutel (OpenStreetMap-type + id), bruikbaar als primaire sleutel |
| `naam` | bedrijfsnaam, kan `null` zijn |
| `straat` `postcode` `plaats` | adres; alleen gevuld waar het geverifieerd is (2.086 van 3.788) |
| `kreis` `bundesland` | bestuurlijke indeling |
| `lat` `lon` | coördinaat uit OpenStreetMap |
| `kmGrens` | hemelsbrede afstand tot de Nederlandse landsgrens — bepaalt de zone |
| `kmOzn` | hemelsbrede afstand tot OZN in Oldenzaal |
| `zone` | 1 t/m 5 (banden van 80 km), 0 = verder dan 400 km |
| `telefoon` `email` `website` | lijsten, kunnen meerdere waarden bevatten of `null` zijn |
| `prioriteit` | A/B/C/D, score op kansrijkheid als partner |
| `status` | uitkomst van de verificatie, leeg als niet gecontroleerd |

Daarnaast `markt` met inwoners, overledenen en geschatte crematies per zone en
voor de grensstrook, en `zones` met de grenzen van elke band.

Let op: de A-lijst is één voor één geverifieerd, de rest niet. Zie `prioriteit`
en `status` voordat je iets als bevestigd behandelt.
