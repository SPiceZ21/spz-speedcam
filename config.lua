Config = {}

-- Detection
Config.DetectionRadius = 18.0    -- metres: trigger sphere around camera
Config.NearbyRadius    = 100.0   -- metres: broad radius — enables fast-poll mode
Config.MinSpeedKmh     = 40.0    -- minimum speed to register a capture
Config.CooldownMs      = 25000   -- ms before same camera can capture same player again

-- Display
Config.Units           = 'kmh'   -- 'kmh' or 'mph'
Config.CardDurationMs  = 6000    -- how long the capture card stays on screen

-- Records command
Config.RecordsCommand  = 'speedrecords'
