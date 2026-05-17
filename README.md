# st_appearance

Strata's character appearance editor — clothing, hair, face, tattoos,
outfits, presets, wardrobe, faction uniforms, and text-code sharing.

**What you get:**

- Full appearance editor — clothing & props, hair, face, tattoos, colors,
  walk style, accessories, ped model, animations, in-editor camera
- Outfits & presets — save / favorite / categorize
- Wardrobe slots — per-character "saved looks" persisted across sessions
- Faction uniforms — boss-grade staff save shared work outfits; employees
  one-click equip them (gated by job/gang membership + grade)
- Text-code sharing — generate a code for an outfit, paste to receive
  (with rate limits + payload caps)
- Admin / staff edit — open another player's appearance editor
- Interaction zones — drop the menu on a coord and players walking up get
  a target; supports clothing-shop / boss-office / barber-style scenes
- English UI strings, externalised in `locales/en.json` for easy editing
- Strict blacklist + payload-size enforcement server-side
- DB-backed: `st_appearance`, `_presets`, `_outfits`, `_job_outfits`,
  `_faction_uniforms`, `_share_codes`, `_wardrobe`

## Setup

1. Drop the resource into `resources/[strata]/st_appearance/`.
2. Build the UI (see below).
3. In `server.cfg`:
   ```
   ensure st_appearance
   ```
   Order it after `ox_core`, `ox_lib`, `oxmysql`, and `st_log`.
4. Tables auto-create on first boot via the bootstrap thread in
   `server/db.lua`.

## Build the UI

```sh
cd web
bun install
bun run dev    # http://localhost:5173 — browser preview with mock data
bun run build  # → ./dist  (committed assets served by FiveM)
```

## Configuration

All runtime config lives in `config.lua`. Highlights:

| Field                                  | Purpose                                                                          |
|----------------------------------------|----------------------------------------------------------------------------------|
| `pedMenu`                              | `/pedmenu` admin command — model swap UI with optional model whitelist.          |
| `limits`                               | Server-side caps: `maxPresets`, `maxOutfits`, `maxPayloadSize`.                  |
| `freezeDuringCustomization`            | Lock the ped in place while the editor is open.                                  |
| `invincibleDuringCustomization`        | Set the ped invincible while the editor is open.                                 |
| `hideRadar`                            | Hide the radar while the editor is open.                                         |
| `cameraTransitionTime`                 | ms — preset / zoom interp duration.                                              |
| `cameraPresets` / `cameraOffsets`      | Preset list + per-preset offset relative to the ped.                             |
| `lightingPresets` / `lightingTimes`    | Studio-light time-of-day overrides.                                              |
| `disabledComponents` / `disabledProps` | Numeric drawable IDs hidden from the UI.                                         |
| `interaction.zones`                    | World-space targets that open the editor (clothing shop, hair, etc.).            |
| `wardrobe.maxSlots`                    | Per-character wardrobe slot cap (default 4).                                     |
| `factionUniforms`                      | Master switch + boss-grade rules + ACE permission for managing uniforms.         |
| `share`                                | Rate limits + TTL defaults for outfit share codes.                               |
| `admin`                                | `/setappearance` command + ACE permission.                                       |
| `rcoreTattoosCompatibility`            | If `true`, the Tattoos tab is hidden and rcore_tattoos manages them.             |

## Commands

| Command          | Permission                | Action                                               |
|------------------|---------------------------|------------------------------------------------------|
| `/appearance`    | when `config.debug = true`| open the full menu yourself                          |
| `/pedmenu`       | optional ACE              | open the ped-model picker                            |
| `/uniforms`      | none                      | open faction uniform list (employees of a job/gang)  |
| `/saveuniform`   | boss-grade or ACE         | save current outfit as a faction uniform             |
| `/setappearance` | admin ACE                 | open another player's appearance editor              |
| `/reloadskin`    | none                      | re-apply your saved appearance from the DB           |

## Exports

```lua
exports.st_appearance:open({ tabs?, pedMenu? })       -- open the editor
exports.st_appearance:close()                          -- close it
exports.st_appearance:applyAppearance(ped, appearance) -- apply to an arbitrary ped

exports.st_appearance:getPlayerAppearance(src)         -- server: read saved appearance
exports.st_appearance:setPlayerAppearance(src, data)   -- server: write + push to client
exports.st_appearance:getPlayerOutfits(src)
exports.st_appearance:getPlayerOutfit(src, outfitId)
exports.st_appearance:isFactionBoss(src)
```

## Layout

```
st_appearance/
├── fxmanifest.lua
├── config.lua             runtime tunables
├── shared/
│   ├── types.lua          ---@meta — Appearance, Outfit, Preset, Uniform, ShareCode
│   ├── logger.lua         local print helper
│   ├── locale.lua         loads locales/en.json + t() helper
│   ├── security.lua       payload validation helpers
│   ├── blacklist.lua      configurable model / draw blocks
│   ├── data.lua           component IDs, prop IDs, labels, walk styles, animations
│   └── tattoos.lua        full GTA tattoo catalog
├── locales/
│   └── en.json            UI string table
├── client/
│   ├── framework.lua      bridge — getPlayerData, getIdentifier (ox_core)
│   ├── nui.lua            NUI bridge + setConfig payload
│   ├── ped.lua            ped manipulation, appearance apply, walk style
│   ├── camera.lua         editor camera state machine + presets
│   ├── animation.lua      preview animations
│   ├── menu.lua           menu open / close, allowedTabs filter
│   ├── zones.lua          interaction zone spawners
│   ├── interaction.lua    open-from-zone callbacks
│   ├── sharing.lua        generate / import outfit share codes
│   ├── wardrobe.lua       per-slot wardrobe save / load
│   ├── uniforms.lua       faction uniform menu (employees + bosses)
│   ├── admin.lua          admin edit-another-player flow
│   └── main.lua           entry — NUI message handlers, lifecycle
└── server/
    ├── framework.lua      bridge — Ox.GetPlayer, getPlayerData, money helpers
    ├── db.lua             schema bootstrap + all queries
    ├── cache.lua          per-source state cache (load on first touch, persist on unload)
    ├── sharing.lua        share-code generate / import / revoke
    ├── wardrobe.lua       wardrobe slot CRUD
    └── main.lua           entry — events, callbacks, exports, payload validation
```

Uses ox_lib helpers — `lib.requestModel`, `lib.notify`, `lib.callback`,
`cache.ped`, `cache.playerId`.

## Dependencies

- `ox_core` — character + identifier resolution
- `ox_lib` — callbacks, cache, request helpers, notifications
- `oxmysql` — persistence layer
- `st_log` — structured logging

## Credits

Originally based on [`juddlie/juddlie_appearance`](https://github.com/juddlie/juddlie_appearance)
by [juddlie](https://github.com/juddlie). Heavily edited from the original —
ox_core-only framework bridge, NUI rewritten on the Strata `nui-kit` (Mantine v5 +
Montserrat), feature cull (no marketplace / drops / randomizer / store / outfit
wheel — sharing kept), faction uniforms + wardrobe slots added, server-side
payload validation hardened, English-only locale, full LuaLS annotations,
flat file layout — but the underlying tattoo / clothing / component data and
the core editor surface trace back to juddlie's work. Thank you.

## License

MIT — see [`LICENSE`](./LICENSE).
