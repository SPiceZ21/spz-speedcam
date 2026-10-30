# spz-speedcam

> Speed cameras around the map with personal and server records.

![version](https://img.shields.io/badge/version-1.3.0-ff6200) ![SPiceZ-Core](https://img.shields.io/badge/SPiceZ--Core-beta-18181b)

## Overview

Fixed speed cameras across the map. Drive through one fast to set your best; the fastest pass per camera is the server record.

## Features

- Camera network with blips
- Personal bests and server records
- Flash and readout on pass

## Requirements

| Resource | Type |
|---|---|
| `ox_lib` | third-party |
| `spz-core` | SPiceZ module |
| `spz-identity` | SPiceZ module |
| `oxmysql` | third-party |

## Installation

Included in the [txAdmin recipe](https://github.com/SPiceZ21/spz-txrecipe). Manual install:

1. Download `spz-speedcam` from GitHub (latest release, or the repository) into your `resources` folder.
2. Add to `server.cfg`, after its requirements:

```cfg
ensure spz-speedcam
```

## Configuration

- `config.lua`

See the file for every option.

## Key binds

Rebindable in **Settings → Key Bindings → FiveM**.

| Action | Default |
|---|---|
| Speed camera records | `F2` |

---

Part of **SPiceZ-Core** — [documentation](https://github.com/SPiceZ21/Docs) · [all modules](https://github.com/SPiceZ21/Docs/blob/main/modules/README.md)
