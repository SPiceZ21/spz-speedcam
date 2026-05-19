-- Speed camera network — GTA V key road locations
-- coords = trigger sphere centre  |  radius overrides Config.DetectionRadius if set

SpeedCams = {
    {
        id     = "del_perro_fwy",
        name   = "Del Perro Freeway",
        coords = vector3(-1032.5, -2730.2, 13.8),
    },
    {
        id     = "olympic_fwy_south",
        name   = "Olympic Freeway South",
        coords = vector3(1214.5, -1292.4, 34.9),
    },
    {
        id     = "great_ocean_hwy",
        name   = "Great Ocean Highway",
        coords = vector3(-3012.6, 63.1, 10.2),
    },
    {
        id     = "sandy_shores_hwy",
        name   = "Sandy Shores Highway",
        coords = vector3(2594.3, 362.1, 108.6),
    },
    {
        id     = "vinewood_hills_blvd",
        name   = "Vinewood Hills Boulevard",
        coords = vector3(-1278.5, 424.2, 98.3),
    },
    {
        id     = "route68_east",
        name   = "Route 68 East",
        coords = vector3(686.2, 2735.6, 42.1),
    },
    {
        id     = "lsia_approach",
        name   = "LSIA Approach Road",
        coords = vector3(-850.3, -2875.6, 13.9),
    },
    {
        id     = "east_ls_fwy",
        name   = "East Los Santos Freeway",
        coords = vector3(1462.8, -632.4, 112.7),
    },
    {
        id     = "chumash_pass",
        name   = "Chumash Coast Road",
        coords = vector3(-3254.1, 1047.5, 12.5),
    },
    {
        id     = "paleto_bay_rd",
        name   = "Paleto Bay Road",
        coords = vector3(-360.2, 6283.1, 31.5),
    },
    {
        id     = "rockford_hills",
        name   = "Rockford Hills Drive",
        coords = vector3(-780.5, 181.2, 73.5),
    },
    {
        id     = "ls_downtown_fwy",
        name   = "Downtown LS Freeway",
        coords = vector3(214.8, -955.3, 30.4),
    },
}

-- Lookup helper used by both client and server
SpeedCamById = {}
for _, cam in ipairs(SpeedCams) do
    SpeedCamById[cam.id] = cam
end
