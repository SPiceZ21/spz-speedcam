-- server/main.lua

Citizen.CreateThread(function()
    -- ── Schema ────────────────────────────────────────────────────────────────

    MySQL.query([[
        CREATE TABLE IF NOT EXISTS `speedcam_bests` (
            `id`            INT           AUTO_INCREMENT PRIMARY KEY,
            `camera_id`     VARCHAR(32)   NOT NULL,
            `player_id`     INT           NOT NULL,
            `speed_kmh`     FLOAT         NOT NULL,
            `vehicle_model` VARCHAR(64)   NULL,
            `updated_at`    TIMESTAMP     DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            UNIQUE KEY uq_cam_player (camera_id, player_id),
            INDEX idx_camera (camera_id),
            INDEX idx_player (player_id)
        )
    ]])

    -- ── Capture event (Client → Server) ──────────────────────────────────────

    RegisterNetEvent("spz-speedcam:capture", function(camId, speedKmh, vehicleModel)
        local src = source

        -- Validate camera ID
        if not SpeedCamById[camId] then return end

        -- Validate speed is a reasonable number
        speedKmh = tonumber(speedKmh)
        if not speedKmh or speedKmh < 0 or speedKmh > 600 then return end

        local ok, profile = pcall(function() return exports["spz-identity"]:GetProfile(src) end)
        local playerId = ok and profile and profile.id or nil

        -- ── Check personal best ───────────────────────────────────────────────

        local isPersonalBest = false
        local prevPersonalBest = nil

        if playerId then
            local rows = MySQL.query.await(
                "SELECT speed_kmh FROM speedcam_bests WHERE camera_id = ? AND player_id = ? LIMIT 1",
                { camId, playerId }
            )
            local existing = rows and rows[1]
            prevPersonalBest = existing and existing.speed_kmh or nil
            isPersonalBest   = not existing or speedKmh > existing.speed_kmh

            if isPersonalBest then
                MySQL.query.await([[
                    INSERT INTO speedcam_bests (camera_id, player_id, speed_kmh, vehicle_model)
                    VALUES (?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE
                        speed_kmh     = VALUES(speed_kmh),
                        vehicle_model = VALUES(vehicle_model),
                        updated_at    = NOW()
                ]], { camId, playerId, speedKmh, vehicleModel })
            end
        end

        -- ── Check global record ───────────────────────────────────────────────

        local isGlobalRecord = false
        local globalRows = MySQL.query.await(
            "SELECT MAX(speed_kmh) AS top FROM speedcam_bests WHERE camera_id = ?",
            { camId }
        )
        local currentGlobal = globalRows and globalRows[1] and globalRows[1].top or nil

        -- After our INSERT, re-query (or just compare)
        if isPersonalBest then
            isGlobalRecord = not currentGlobal or speedKmh >= currentGlobal
        end

        -- ── Respond to client ─────────────────────────────────────────────────

        TriggerClientEvent("spz-speedcam:captured", src, {
            cameraId        = camId,
            cameraName      = SpeedCamById[camId].name,
            speedKmh        = speedKmh,
            isPersonalBest  = isPersonalBest,
            isGlobalRecord  = isGlobalRecord,
            prevPersonalBest = prevPersonalBest,
        })

        -- ── Broadcast global record to all players ────────────────────────────

        if isGlobalRecord then
            local playerName = GetPlayerName(src) or "Unknown"
            TriggerClientEvent("spz-speedcam:newGlobalRecord", -1, {
                cameraName   = SpeedCamById[camId].name,
                speedKmh     = speedKmh,
                playerName   = playerName,
                vehicleModel = vehicleModel,
            })
        end
    end)

    -- ── SPZ Callbacks ─────────────────────────────────────────────────────────

    -- Get top N speeds for a specific camera
    lib.callback.register("spz-speedcam:getCameraRecords", function(source, data)
        local camId = data and data.cameraId
        local limit = math.min(data and data.limit or 10, 50)

        if camId then
            local rows = MySQL.query.await([[
                SELECT sb.speed_kmh, sb.vehicle_model, sb.updated_at,
                       p.username AS player_name
                FROM speedcam_bests sb
                JOIN players p ON p.id = sb.player_id
                WHERE sb.camera_id = ?
                ORDER BY sb.speed_kmh DESC
                LIMIT ?
            ]], { camId, limit })
            return rows or {}
        else
            -- All cameras: global record per camera
            local rows = MySQL.query.await([[
                SELECT sb.camera_id, sb.speed_kmh, sb.vehicle_model, sb.updated_at,
                       p.username AS player_name
                FROM speedcam_bests sb
                JOIN players p ON p.id = sb.player_id
                WHERE (sb.camera_id, sb.speed_kmh) IN (
                    SELECT camera_id, MAX(speed_kmh)
                    FROM speedcam_bests
                    GROUP BY camera_id
                )
                ORDER BY sb.speed_kmh DESC
            ]], {})
            return rows or {}
        end
    end)

    -- Get player's personal bests across all cameras
    lib.callback.register("spz-speedcam:getPersonalBests", function(source)
        local ok, profile = pcall(function() return exports["spz-identity"]:GetProfile(source) end)
        if not ok or not profile then return {} end

        local rows = MySQL.query.await([[
            SELECT camera_id, speed_kmh, vehicle_model, updated_at
            FROM speedcam_bests
            WHERE player_id = ?
            ORDER BY speed_kmh DESC
        ]], { profile.id })
        return rows or {}
    end)

    print("^2[spz-speedcam] Server ready — " .. #SpeedCams .. " cameras active^7")
end)

-- ── Server exports ────────────────────────────────────────────────────────────

exports("GetCameraRecords", function(camId, limit)
    if not camId then return {} end
    local rows = MySQL.query.await(
        "SELECT * FROM speedcam_bests WHERE camera_id = ? ORDER BY speed_kmh DESC LIMIT ?",
        { camId, limit or 10 }
    )
    return rows or {}
end)

exports("GetTopSpeed", function(camId)
    if not camId then return nil end
    local rows = MySQL.query.await(
        "SELECT MAX(speed_kmh) AS top FROM speedcam_bests WHERE camera_id = ?",
        { camId }
    )
    return rows and rows[1] and rows[1].top or nil
end)
