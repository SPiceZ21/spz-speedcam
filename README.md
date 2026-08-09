# spz-speedcam

> Speed camera network with personal and global records · `v1.0.0`

## Overview

`spz-speedcam` places speed cameras around the map. Pass one above the minimum speed and
it captures you: a card shows your speed on screen, and the run is stored against your
profile and the global record for that camera.

## Structure

| Side | File | Purpose |
|---|---|---|
| Shared | `shared/cameras.lua` | Camera positions and metadata |
| Server | `config.lua` | Detection and record settings |
| Server | `server/main.lua` | Capture validation, record persistence |
| Client | `config.lua` | Client-side settings |
| Client | `client/main.lua` | Proximity detection, capture card |
| Client | `client/blips.lua` | Map blips |
| UI | `ui/` | Capture card (plain HTML/CSS/JS) |

## Configuration

| Key | Default | Meaning |
|---|---|---|
| `Config.DetectionRadius` | `18.0` | Trigger sphere around a camera (m) |
| `Config.NearbyRadius` | `100.0` | Broad radius that enables fast polling (m) |
| `Config.MinSpeedKmh` | `40.0` | Minimum speed to register a capture |
| `Config.CooldownMs` | `25000` | Re-capture cooldown per camera per player |
| `Config.Units` | `'kmh'` | `'kmh'` or `'mph'` |
| `Config.CardDurationMs` | `6000` | Capture card on-screen time |
| `Config.RecordsCommand` | `'speedrecords'` | Command that opens the records list |
| `Config.ShowBlips` | `true` | Draw camera blips on the map |

## Exports

| Export | Description |
|---|---|
| `GetCameraRecords` | Records for a camera |
| `GetTopSpeed` | Top recorded speed |

## Commands

| Command | Effect |
|---|---|
| `/speedrecords` | Open the records list (name from `Config.RecordsCommand`) |

## Dependencies

`ox_lib` · `spz-identity` · `oxmysql`

---

Part of [SPiceZ-Core](../README.md) · GPL-3.0
