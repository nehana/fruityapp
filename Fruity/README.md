# Fruity — Setup Guide

## 1. Create the Xcode project (2 min)
1. Xcode → File → New → Project → **iOS App**
2. Product Name: `Fruity`
3. Interface: **SwiftUI**, Language: **Swift**
4. Uncheck "Use Core Data" (we're using SwiftData instead)
5. Minimum deployment target: **iOS 17.0** (required for SwiftData)

## 2. Drop in these files
Delete the auto-generated `ContentView.swift` and the `App.swift` Xcode gave you,
then drag this whole `Fruity` folder's contents into your project in Xcode
(keep the group structure: `Models/`, `Data/`, `Services/`, `Views/`, `Views/Components/`).
Make sure "Copy items if needed" is checked and your app target is selected.

## 3. Build & run
That's it — no external dependencies, no pods, no config. Cmd+R on a simulator
running iOS 17+.

## ⚠️ If you already had the app installed
This update adds new fields to `LoggedFruit` and a whole new `WantToTryFruit`
model. SwiftData usually handles small additive changes fine, but if you hit
a crash on launch after pulling this update, **delete the app from your
simulator/device and reinstall** — we're still in early development, so
there's no saved data worth preserving through a real migration yet.

## What's included (MVP scope)
- **Passport tab** — persona avatar/tier based on fruits tried, stats, shareable
  card (image share via `ShareLink`, plus a "Copy as Text" button for quick paste)
- **My Fruits tab** — everything you've logged, swipe to delete, tap to edit
- **Discover tab** — full catalog of 32 exotic fruits, filter by region, search,
  tap into detail + fun facts, "Log this fruit" shortcut
- **Local persistence** — SwiftData, fully on-device, nothing leaves the phone

## Known MVP shortcuts (fine for now, flag for v2)
- Username is a plain `@AppStorage` string, no editing UI yet — add a text field
  in Settings or directly on the Passport tab when ready
- "Copy as Text" copies a text summary; true one-tap "copy image to clipboard"
  needs a small `UIActivityViewController` wrapper (ShareLink's built-in share
  sheet already includes a copy option though, so this mostly covers itself)
- No map yet — `Region`/`country` are already on every `Fruit`, so a MapKit view
  with pins grouped by country is a clean follow-up, not a rearchitecture
- Fruit facts are seeded from general knowledge — worth a quick fact-check pass
  before you ship anything publicly
- No photo attachment on log entries — `LoggedFruit` can take a `Data?` photo
  field later if you want users to snap their own pic instead of just the emoji

## Suggested next hour, if you have it
1. Swap the emoji avatars for custom fruit-persona illustrations
2. Add the map view (MapKit `Marker` per unique country in `logged`)
3. Add a Settings sheet for username + maybe a "reset passport" debug action
4. Add more fruits to `FruitCatalog.swift` — the schema scales to hundreds easily
