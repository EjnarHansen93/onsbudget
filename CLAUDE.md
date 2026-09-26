# OnsBudget — projectcontext voor Claude Code

Gedeelde budget-app (inkomsten/uitgaven per maand, WAKOSTA-stijl) voor Ejnar en Shauni.
Mobiel-eerst PWA, Nederlandstalige UI (Belgisch: `nl-BE`, euro, komma als decimaal).
Communiceer met Ejnar in het Nederlands, kort en actiegericht.

## Stack & opbouw
- **Eén bestand:** `index.html` (~1000 regels). Geen build-stap, geen `package.json`.
- React 18 + ReactDOM (UMD via jsDelivr) · `@babel/standalone` compileert de JSX **in de browser**
  (code staat in `<script type="text/plain" id="app-src">`, wordt onderaan via `Babel.transform` + `eval` gestart).
- `@supabase/supabase-js@2` (UMD) voor data + realtime.
- `manifest.webmanifest` + `icon-512.png` → "Toevoegen aan beginscherm".
- `.nojekyll` voor GitHub Pages.
- Styling: plain CSS in `<style>`, kleurtokens op `:root` (`--purple #7B57FF`, `--mint #5FD9C0`, …).

## Hosting / deploy
- GitHub repo `EjnarHansen93/onsbudget`, gehost op **GitHub Pages** vanaf `main` (root).
- Deploy = committen + pushen naar `main`; Pages publiceert binnen ~1 min.
- Lokaal testen: `npx serve .` of `python3 -m http.server 8000` en open `http://localhost:8000`.
  (Let op: lokaal praat je met de **live** Supabase-database.)

## Supabase
- Project ref: `lkzxkovpswyllzunrqks` (regio eu-west-1). URL + anon key staan bovenaan de app-code (`SUPA_URL`, `SUPA_KEY`).
- Volledig schema: `supabase/schema.sql`. Tabellen:
  - `budget_profiles` (id, name, position) — 3 rekeningen: "Gezamenlijk", "Shauni privé", "Rekening 3" (hernoembaar).
  - `budget_transactions` (profile_id, type `in|uit`, amount ≥ 0, category, description, date, savings_id?, recurring_id?)
  - `budget_savings` (profile_id, name, position) — spaarrekeningen.
  - `budget_recurring` (profile_id, type, amount, category, description, day 1–31, active, start_date, generated_until) — vaste kosten.
  - `budget_notes` (profile_id, text, amount?, done) — notities op de Sparen-tab (gedeeld, realtime).
- Realtime staat aan op alle 5 tabellen; de app herlaadt bij elke wijziging (`channel('budget-rt')`).
- **Schemawijzigingen** altijd als migratie (Supabase MCP `apply_migration` of CLI), en `supabase/schema.sql` bijwerken.
  Nooit data wissen zonder expliciete toestemming — er staat echte data in.

## Domeinlogica (belangrijk)
- Bedragen altijd positief; richting zit in `type` (`in` = groen/+, `uit` = rood/−).
- Categorieën zijn hardcoded in `CATS` (keys als `boodschappen`, `andere_uit`, …). Onbekende keys vallen terug op grijze "clip".
- **Sparen** = transactie met `category='sparen'` + `savings_id`:
  storten → `type='uit'` (verlaagt maandsaldo, verhoogt spaarpot); opnemen → `type='in'`.
  Spaarsaldo = Σ(uit) − Σ(in) voor die `savings_id`.
- **Vaste kosten:** `materializeRecurring()` draait client-side bij elke `loadData`: maakt voor elke actieve regel
  per maand (van `start_date`, max 24 maanden terug) een transactie met `recurring_id`, **enkel t.e.m. vandaag**
  en enkel na `generated_until` (dat daarna wordt bijgewerkt). Zo komen verwijderde/verplaatste transacties
  niet terug. De unieke index `(recurring_id, date)` + `upsert … ignoreDuplicates` vangt races tussen gsm's op.
  Pauzeren = `active=false`; bij heractiveren zet de app `generated_until` op vandaag (geen inhaalmaanden).
- **Notities** staan in `budget_notes`. Oude lokale notities (`localStorage.budget_notes_<profileId>`) worden
  bij het laden één keer naar Supabase overgezet.
- Toegangscode-poort (`ACCESS_CODE = "samen"`) is puur client-side; `localStorage.budget_ok` onthoudt login,
  `localStorage.budget_profile` het actieve profiel. **Bewuste keuze van Ejnar: zo houden** (geen e-mail-login).

## Tabs / schermen
Budget (maandsaldo, in/uit-donuts, transactielijst) · Sparen (potten + notities) · Overzicht (donut per categorie → detail) ·
Profielen (hernoemen, actief kiezen, Vaste kosten beheren, uitloggen) · FAB "+" → `AddSheet` (IN / UIT / SPAREN).

## Bekende aandachtspunten / mogelijke volgende stappen
1. **Beveiliging:** anon key + `using (true)`-policies ⇒ wie de key uit de paginabron haalt kan alles lezen/wijzigen.
   Ejnar wil de toegangscode behouden (geen Supabase Auth) — niet opnieuw voorstellen tenzij hij erom vraagt.
2. ~~Notities naar Supabase~~ — gedaan (`budget_notes`).
3. ~~Vaste kosten in de toekomst / komen terug na verwijderen~~ — gedaan (`generated_until`).
4. **Performance:** Babel in de browser maakt de eerste load traag. Migratie naar Vite + React (build naar `dist/`,
   GitHub Actions → Pages) is de logische stap als de app verder groeit. Tot dan: niets opsplitsen dat de no-build setup breekt.
5. `window.confirm` wordt gebruikt voor verwijderen — werkt, maar past niet in de stijl.
6. Geen tests. Bij grotere wijzigingen: handmatig testen op gsm-breedte (≤ 480px).

## Werkafspraken
- Houd de UI in het Nederlands en in de bestaande stijl (paarse header met ronde onderkant, witte kaarten, mint "OPSLAAN").
- Kleine, gerichte wijzigingen; toon wat je veranderd hebt vóór je pusht.
- Controleer na elke wijziging dat de pagina nog laadt (Babel-fouten tonen "Er ging iets mis" in rood).
