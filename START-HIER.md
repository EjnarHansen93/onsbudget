# OnsBudget overzetten naar Claude Code

## 1. Wat je nodig hebt
- **Claude Code** — in de Claude desktop-app (tab *Code*) of in de terminal (`npm install -g @anthropic-ai/claude-code`, dan `claude`).
- **Git** + toegang tot GitHub-account `EjnarHansen93` (om te kunnen pushen).
- **Node.js** (enkel nodig voor lokaal testen met `npx serve .`).
- Optioneel: **Supabase-connector** in Claude Code, zodat Claude de database kan bekijken/aanpassen.

## 2. Bestanden in dit pakket
| Bestand | Wat |
|---|---|
| `index.html` | De volledige app (ongewijzigd, zoals nu live) |
| `manifest.webmanifest`, `icon-512.png`, `.nojekyll` | PWA + GitHub Pages |
| `CLAUDE.md` | **Projectcontext** — Claude Code leest dit automatisch bij elke sessie |
| `supabase/schema.sql` | Het volledige databaseschema (tabellen, indexen, policies, realtime) |

## 3. Stappen
1. Clone je repo:  
   `git clone https://github.com/EjnarHansen93/onsbudget.git && cd onsbudget`
2. Kopieer `CLAUDE.md`, `START-HIER.md` en de map `supabase/` uit dit pakket in die map.
3. Commit ze: `git add . && git commit -m "Claude Code context toegevoegd" && git push`
4. Start Claude Code in de map `onsbudget` (desktop-app: *Open folder*; terminal: `claude`).
5. Eerste prompt, bijvoorbeeld:  
   > Lees CLAUDE.md en index.html. Geef me een kort overzicht en stel de 3 nuttigste verbeteringen voor.

## 4. Huidige stand (26/09/2026)
- 3 profielen · 83 transacties · 5 spaarrekeningen · 4 vaste kosten in Supabase.
- Spaarpotten en vaste kosten (oorspronkelijk "v2") zitten er al in.
- Grootste open punten: beveiliging (iedereen met de key kan erbij), notities enkel lokaal op één gsm.
