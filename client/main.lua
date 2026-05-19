-- client/main.lua

local SPZ = nil
Citizen.CreateThread(function()
    while not SPZ do
        pcall(function() SPZ = exports["spz-lib"]:GetCoreObject() end)
        if not SPZ then Citizen.Wait(500) end
    end
end)

-- ── State ─────────────────────────────────────────────────────────────────────

local inZone      = {}   -- [camId] = true while player is inside radius
local onCooldown  = {}   -- [camId] = true while cooling down after capture

-- ── Detection loop (adaptive sleep) ──────────────────────────────────────────
-- When far from all cameras: sleeps 1000ms (cheap background check).
-- When within NearbyRadius of any camera: switches to 100ms for precise trigger.
-- Capture fires ONCE on zone-enter, then per-camera cooldown applies.

Citizen.CreateThread(function()
    while true do
        local ped     = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle == 0 then
            inZone = {}
            Citizen.Wait(1000)
        else
            local vPos      = GetEntityCoords(vehicle)
            local nearAny   = false

            for _, cam in ipairs(SpeedCams) do
                local dist   = #(vPos - cam.coords)
                local radius = cam.radius or Config.DetectionRadius

                if dist <= Config.NearbyRadius then
                    nearAny = true
                end

                local inside = dist <= radius

                if inside and not inZone[cam.id] and not onCooldown[cam.id] then
                    local speedMs  = GetEntitySpeed(vehicle)
                    local speedKmh = speedMs * 3.6

                    if speedKmh >= Config.MinSpeedKmh then
                        TriggerServerEvent("spz-speedcam:capture", cam.id, speedKmh, GetEntityModel(vehicle))

                        onCooldown[cam.id] = true
                        SetTimeout(Config.CooldownMs, function()
                            onCooldown[cam.id] = nil
                        end)
                    end
                end

                inZone[cam.id] = inside
            end

            -- Far from all cameras → sleep 1 s, near one → sleep 100 ms
            Citizen.Wait(nearAny and 100 or 1000)
        end
    end
end)

-- ── Server responses ──────────────────────────────────────────────────────────

RegisterNetEvent("spz-speedcam:captured", function(data)
    -- Build display speed string
    local displaySpeed
    if Config.Units == 'mph' then
        displaySpeed = math.floor(data.speedKmh * 0.621371)
    else
        displaySpeed = math.floor(data.speedKmh)
    end

    SendNUIMessage({
        type          = "capture",
        cameraName    = data.cameraName,
        speed         = displaySpeed,
        unit          = Config.Units == 'mph' and 'MPH' or 'KM/H',
        personalBest  = data.isPersonalBest,
        globalRecord  = data.isGlobalRecord,
        prevBest      = data.prevPersonalBest and math.floor(
                            Config.Units == 'mph' and data.prevPersonalBest * 0.621371 or data.prevPersonalBest
                        ) or nil,
        duration      = Config.CardDurationMs,
    })
end)

RegisterNetEvent("spz-speedcam:newGlobalRecord", function(data)
    local displaySpeed = math.floor(
        Config.Units == 'mph' and data.speedKmh * 0.621371 or data.speedKmh
    )
    local unit = Config.Units == 'mph' and 'MPH' or 'KM/H'

    -- Notify all players via SPZ notify if available
    if SPZ and SPZ.Notify then
        SPZ.Notify(
            ("🏎 NEW RECORD — %s\n%s reached %d %s on %s"):format(
                data.cameraName,
                data.playerName,
                displaySpeed,
                unit,
                data.vehicleModel or "unknown vehicle"
            ),
            "info"
        )
    end
end)

-- ── Records command ───────────────────────────────────────────────────────────

RegisterCommand(Config.RecordsCommand, function()
    if not SPZ then return end
    SPZ.Callbacks.Trigger("spz-speedcam:getPersonalBests", {}, function(records)
        if not records or #records == 0 then
            SendNUIMessage({ type = "records", records = {}, cameraList = SpeedCams })
            return
        end
        SendNUIMessage({ type = "records", records = records, cameraList = SpeedCams })
    end)
    SendNUIMessage({ type = "openRecords" })
    SetNuiFocus(true, true)
end, false)

RegisterKeyMapping(Config.RecordsCommand, "Speed Camera Records", "keyboard", "F7")

RegisterNUICallback("closeRecords", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "closeRecords" })
    cb("ok")
end)
