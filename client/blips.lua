-- client/blips.lua
-- Static map blips for every speed camera (SpeedCams, shared/cameras.lua).

CreateThread(function()
    if Config.ShowBlips == false then return end
    if not SpeedCams then return end

    for _, cam in ipairs(SpeedCams) do
        local blip = AddBlipForCoord(cam.coords.x, cam.coords.y, cam.coords.z)
        SetBlipSprite(blip, Config.BlipSprite or 184)
        SetBlipColour(blip, Config.BlipColour or 1)
        SetBlipScale(blip, Config.BlipScale or 0.8)
        SetBlipAsShortRange(blip, true)   -- only on the minimap when close
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(cam.name or "Speed Camera")
        EndTextCommandSetBlipName(blip)
    end
end)
