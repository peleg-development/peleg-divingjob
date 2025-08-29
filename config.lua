Config = {}

--[[
    Bridge configuration
    Set to 'auto' to detect at runtime
    Framework: 'auto' | 'qb' | 'qbx' | 'esx'
    Inventory: 'auto' | 'ox' | 'qb'  | 'qs'
    Target:    'auto' | 'ox' | 'qb'  | 'drawtext'
]]

Config.Framework = 'auto'
Config.Inventory = 'auto'
Config.Target = 'drawtext'
Config.TargetDistance = 13.2 -- Default interaction distance for target systems

-- Fuel System Configuration
Config.FuelSystem = 'auto' -- 'auto' | 'lc_fuel' | 'ox_fuel' | 'qb_fuel' | 'legacy'
Config.DefaultFuelLevel = 100 -- Default fuel level when spawning vehicles

-- Inventory Images Path (for item images in shop)
Config.InventoryImagesPath = 'ox_inventory/web/images/'

-- General Settings
Config.Debug = true


---Global diving shop ped configuration
Config.ShopPed = {
    enabled = true,
    model = 's_m_y_dockwork_01',
    coords = vec4(-2613.35, -216.17, 2.6, 68.14),
    scenario = 'WORLD_HUMAN_CLIPBOARD'
}

-- Oxygen System
Config.OxygenTime = 120 -- seconds without diving gear
Config.OxygenTimeWithGear = 500 -- seconds with diving gear
Config.DivingGearItem = 'diving_gear'
Config.Oxygen = {
    Enabled = true,                -- enable this resource's oxygen timer UI
    OverrideNativeBreath = true,   -- keep native underwater breath full to prevent drown
    KillOnDeplete = true          -- do not kill when oxygen reaches 0
}

-- Container Spawning
Config.ContainerSpawnInterval = 5000 -- 5 seconds
Config.MaxContainers = 20
Config.ContainerFallSpeed = 0.1
Config.ContainerSpawnHeight = -3.0 -- Height above water to spawn containers
Config.InitialContainers = 20 -- Number of containers to spawn initially
Config.InteractionDistance = 8.0 -- Distance to interact with containers
Config.MinContainers = 20 -- Minimum containers to maintain
Config.MinContainerDistance = 8.0 -- Minimum distance between containers (in meters)

-- Container Types and Loot
Config.Containers = {
    {
        name = 'small_box',
        label = 'Small Box',
        model = 'prop_box_wood02a',
        maxItems = 3,
        xpReward = 15,
        lootTable = {
            { item = 'copper', chance = 45, min = 2, max = 4 },
            { item = 'plastic', chance = 35, min = 2, max = 5 },
            { item = 'metalscrap', chance = 25, min = 2, max = 4 },
            { item = 'aluminum', chance = 20, min = 2, max = 4 },
            { item = 'steel', chance = 30, min = 2, max = 4 },
            { item = 'rubber', chance = 15, min = 1, max = 3 },
            { item = 'goldbar', chance = 3, min = 1, max = 1 },
            { item = 'weapon_dp9', chance = 1, min = 1, max = 1 }
        }
    },
    {
        name = 'safe',
        label = 'Safe',
        model = 'prop_safe_01',
        maxItems = 5,
        xpReward = 20,
        lootTable = {
            { item = 'copper', chance = 40, min = 3, max = 6 },
            { item = 'plastic', chance = 30, min = 3, max = 6 },
            { item = 'metalscrap', chance = 25, min = 3, max = 6 },
            { item = 'steel', chance = 35, min = 3, max = 6 },
            { item = 'aluminum', chance = 20, min = 3, max = 6 },
            { item = 'rubber', chance = 12, min = 1, max = 3 },
            { item = 'goldbar', chance = 4, min = 1, max = 2 },
            { item = 'weapon_dp9', chance = 1, min = 1, max = 1 }
        }
    },
    {
        name = 'crate',
        label = 'Crate',
        model = 'prop_box_wood04a',
        maxItems = 4,
        xpReward = 23,
        lootTable = {
            { item = 'copper', chance = 35, min = 2, max = 4 },
            { item = 'plastic', chance = 30, min = 2, max = 5 },
            { item = 'goldchain', chance = 25, min = 2, max = 4 },
            { item = 'rolex', chance = 20, min = 2, max = 5 },
            { item = 'diamond_ring', chance = 8, min = 1, max = 1 },
            { item = 'goldbar', chance = 5, min = 1, max = 2 }
        }
    },
    {
        name = 'coral_fragment',
        label = 'Coral Fragment',
        model = 'prop_rock_4_c_2_cr',
        maxItems = 2,
        xpReward = 15,
        lootTable = {
            { item = 'copper', chance = 45, min = 2, max = 4 },
            { item = 'plastic', chance = 35, min = 2, max = 4 },
            { item = 'rubber', chance = 15, min = 1, max = 3 },
            { item = 'goldbar', chance = 8, min = 1, max = 3 }
        }
    },
    {
        name = 'shipwreck_debris',
        label = 'Shipwreck Debris',
        model = 'prop_rub_carwreck_12',
        maxItems = 3,
        xpReward = 16,
        lootTable = {
            { item = 'copper', chance = 40, min = 2, max = 5 },
            { item = 'plastic', chance = 30, min = 2, max = 5 },
            { item = 'metalscrap', chance = 25, min = 2, max = 5 },
            { item = 'steel', chance = 30, min = 2, max = 5 },
            { item = 'aluminum', chance = 20, min = 2, max = 4 },
            { item = 'rubber', chance = 12, min = 1, max = 3 },
            { item = 'goldbar', chance = 4, min = 1, max = 2 },
            { item = 'weapon_dp9', chance = 1, min = 1, max = 1 }
        }
    },
    {
        name = 'deep_sea_crate',
        label = 'Deep Sea Crate',
        model = 'prop_box_wood05a',
        maxItems = 6,
        xpReward = 12,
        lootTable = {
            { item = 'copper', chance = 35, min = 2, max = 5 },
            { item = 'plastic', chance = 25, min = 2, max = 5 },
            { item = 'metalscrap', chance = 20, min = 2, max = 5 },
            { item = 'steel', chance = 25, min = 2, max = 5 },
            { item = 'aluminum', chance = 15, min = 2, max = 4 },
            { item = 'rubber', chance = 10, min = 1, max = 3 },
            { item = 'goldbar', chance = 3, min = 1, max = 2 },
            { item = 'weapon_dp9', chance = 1, min = 1, max = 1 }
        }
    },
    {
        name = 'treasure_chest',
        label = 'Treasure Chest',
        model = 'prop_treasure_chest',
        maxItems = 8,
        xpReward = 25,
        lootTable = {
            { item = 'copper', chance = 30, min = 3, max = 6 },
            { item = 'plastic', chance = 20, min = 3, max = 6 },
            { item = 'metalscrap', chance = 15, min = 3, max = 6 },
            { item = 'steel', chance = 20, min = 3, max = 6 },
            { item = 'aluminum', chance = 12, min = 3, max = 6 },
            { item = 'rubber', chance = 8, min = 1, max = 3 },
            { item = 'goldbar', chance = 6, min = 1, max = 3 },
            { item = 'diamond_ring', chance = 4, min = 1, max = 1 },
            { item = 'weapon_dp9', chance = 1, min = 1, max = 1 }
        }
    },
    {
        name = 'underwater_crate',
        label = 'Underwater Crate',
        model = 'prop_box_wood06a',
        maxItems = 4,
        xpReward = 45,
        lootTable = {
            { item = 'copper', chance = 35, min = 3, max = 6 },
            { item = 'plastic', chance = 25, min = 3, max = 6 },
            { item = 'metalscrap', chance = 20, min = 3, max = 6 },
            { item = 'steel', chance = 25, min = 3, max = 6 },
            { item = 'aluminum', chance = 15, min = 3, max = 6 },
            { item = 'rubber', chance = 10, min = 1, max = 3 },
            { item = 'goldbar', chance = 5, min = 1, max = 2 },
            { item = 'diamond_ring', chance = 3, min = 1, max = 1 },
            { item = 'weapon_dp9', chance = 1, min = 1, max = 1 }
        }
    },
    {
        name = 'metal_container',
        label = 'Metal Container',
        model = 'prop_container_01a',
        maxItems = 5,
        xpReward = 20,
        lootTable = {
            { item = 'copper', chance = 40, min = 3, max = 6 },
            { item = 'plastic', chance = 30, min = 3, max = 6 },
            { item = 'metalscrap', chance = 25, min = 3, max = 6 },
            { item = 'steel', chance = 35, min = 3, max = 6 },
            { item = 'aluminum', chance = 20, min = 3, max = 6 },
            { item = 'rubber', chance = 12, min = 1, max = 3 },
            { item = 'goldbar', chance = 4, min = 1, max = 2 },
            { item = 'weapon_dp9', chance = 1, min = 1, max = 1 }
        }
    },
    {
        name = 'ancient_vase',
        label = 'Ancient Vase',
        model = 'prop_vase_01',
        maxItems = 2,
        xpReward = 30,
        lootTable = {
            { item = 'copper', chance = 30, min = 2, max = 4 },
            { item = 'plastic', chance = 25, min = 2, max = 4 },
            { item = 'metalscrap', chance = 20, min = 2, max = 4 },
            { item = 'steel', chance = 25, min = 2, max = 4 },
            { item = 'aluminum', chance = 15, min = 2, max = 4 },
            { item = 'rubber', chance = 10, min = 1, max = 3 },
            { item = 'goldbar', chance = 8, min = 1, max = 2 },
            { item = 'diamond_ring', chance = 5, min = 1, max = 1 },
            { item = 'weapon_dp9', chance = 1, min = 1, max = 1 }
        }
    }
}

-- Diving Zones
Config.DivingZones = {
    {
        name = 'Coral Reef',
        coords = vector3(-2838.0, -376.0, 2.0),
        radius = 100.0,
        depth = 15.0,
        blip = {
            sprite = 597,
            color = 3,
            scale = 0.8,
            name = 'Coral Reef Diving'
        },
        vehicleSpawnPoint = vector4(-2617.39, -234.54, -0.56, 158.24),
        containers = {
            'small_box',
            'crate',
            'coral_fragment'
        },
        items = {
            { item = 'goldbar', chance = 5, min = 1, max = 2 },
            { item = 'copper', chance = 70, min = 3, max = 6 },
            { item = 'plastic', chance = 60, min = 3, max = 6 },
            { item = 'rubber', chance = 10, min = 1, max = 3 },
            { item = 'metalscrap', chance = 40, min = 3, max = 6 },
            { item = 'aluminum', chance = 30, min = 3, max = 6 },
            { item = 'steel', chance = 50, min = 3, max = 6 },
            { item = 'weapon_dp9', chance = 1, min = 1, max = 1 }
        }
    },
    {
        name = 'Shipwreck Bay',
        coords = vector3(-2950.0, -450.0, 2.0),
        radius = 80.0,
        depth = 25.0,
        blip = {
            sprite = 597,
            color = 5,
            scale = 0.8,
            name = 'Shipwreck Bay Diving'
        },
        vehicleSpawnPoint = vector4(-2945.0, -465.0, 2.0, 45.0),
        containers = {
            'safe',
            'crate',
            'shipwreck_debris'
        },
        items = {
            { item = 'gold_bar', chance = 25, min = 2, max = 4 },
            { item = 'jewelry', chance = 35, min = 2, max = 5 },
            { item = 'diamond', chance = 8, min = 1, max = 2 },
            { item = 'emerald', chance = 12, min = 1, max = 2 },
            { item = 'ruby', chance = 10, min = 1, max = 2 },
            { item = 'electronics', chance = 30, min = 2, max = 4 },
            { item = 'scrap_metal', chance = 50, min = 4, max = 10 }
        }
    },
    {
        name = 'Deep Trench',
        coords = vector3(-3100.0, -300.0, 2.0),
        radius = 120.0,
        depth = 35.0,
        blip = {
            sprite = 597,
            color = 1,
            scale = 0.8,
            name = 'Deep Trench Diving'
        },
        vehicleSpawnPoint = vector4(-3095.0, -315.0, 2.0, 45.0),
        containers = {
            'safe',
            'crate',
            'deep_sea_crate',
            'treasure_chest'
        },
        items = {
            { item = 'gold_bar', chance = 40, min = 3, max = 6 },
            { item = 'jewelry', chance = 50, min = 3, max = 7 },
            { item = 'diamond', chance = 20, min = 2, max = 4 },
            { item = 'emerald', chance = 25, min = 2, max = 4 },
            { item = 'ruby', chance = 22, min = 2, max = 4 },
            { item = 'electronics', chance = 45, min = 3, max = 6 },
            { item = 'scrap_metal', chance = 60, min = 5, max = 12 },
            { item = 'rare_gem', chance = 15, min = 1, max = 2 }
        }
    }
}

-- Shop Settings
Config.ShopItems = {
    { item = 'diving_gear', price = 5000, label = 'Diving Gear', image = 'diving_gear.png' },
}

--- Unit sell prices for items obtainable while diving.
Config.SellPrices = {
    copper = { price = 50, image = 'copper.png' },
    plastic = { price = 30, image = 'plastic.png' },
    metalscrap = { price = 40, image = 'metalscrap.png' },
    aluminum = { price = 45, image = 'aluminum.png' },
    steel = { price = 55, image = 'steel.png' },
    rubber = { price = 25, image = 'rubber.png' },
    goldbar = { price = 1500, image = 'goldbar.png' },
    gold_bar = { price = 1500, image = 'goldbar.png' },
    jewelry = { price = 250, image = 'jewelry.png' },
    diamond = { price = 1200, image = 'diamond.png' },
    emerald = { price = 900, image = 'emerald.png' },
    ruby = { price = 800, image = 'ruby.png' },
    electronics = { price = 180, image = 'electronics.png' },
    scrap_metal = { price = 35, image = 'scrap_metal.png' },
    diamond_ring = { price = 700, image = 'diamond_ring.png' },
}

-- Experience and Levels
Config.XP = {
    RareItemFound = 25,        -- Bonus XP per rare item found
}

Config.Levels = {
    0,     -- Level 1 (starting level)
    250,   -- Level 2
    450,   -- Level 3
    750,   -- Level 4
    1000,  -- Level 5
    2000,  -- Level 6
    3500,  -- Level 7
    5000,  -- Level 8
    7500,  -- Level 9
    10000  -- Level 10
}

Config.LevelColors = {
    [1] = { name = 'Novice', color = '#B72EE6' },
    [2] = { name = 'Beginner', color = '#4caf50' },
    [3] = { name = 'Amateur', color = '#2196f3' },
    [4] = { name = 'Intermediate', color = '#ff9800' },
    [5] = { name = 'Advanced', color = '#f44336' },
    [6] = { name = 'Expert', color = '#9c27b0' },
    [7] = { name = 'Master', color = '#ff5722' },
    [8] = { name = 'Professional', color = '#607d8b' },
    [9] = { name = 'Elite', color = '#e91e63' },
    [10] = { name = 'Legendary', color = '#ffd700' }
}

Config.VehicleRentals = {
    {
        name = 'dinghy',
        label = 'Dinghy',
        model = 'dinghy',
        price = 500,
        level = 1,
        description = 'Basic small boat',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/dinghy.webp'
    },
    {
        name = 'jetmax',
        label = 'Jetmax',
        model = 'jetmax',
        price = 1000,
        level = 2,
        description = 'Fast jet ski',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/jetmax.webp'
    },
    {
        name = 'marquis',
        label = 'Marquis',
        model = 'marquis',
        price = 2000,
        level = 3,
        description = 'Medium yacht',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/marquis.webp'
    },
    {
        name = 'seashark',
        label = 'Seashark',
        model = 'seashark',
        price = 1500,
        level = 4,
        description = 'High-speed jet ski',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/seashark.webp'
    },
    {
        name = 'tropic',
        label = 'Tropic',
        model = 'tropic',
        price = 3000,
        level = 5,
        description = 'Luxury yacht',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/tropic.webp'
    },
    {
        name = 'suntrap',
        label = 'Suntrap',
        model = 'suntrap',
        price = 2500,
        level = 6,
        description = 'Fishing boat',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/suntrap.webp'
    },
    {
        name = 'speeder',
        label = 'Speeder',
        model = 'speeder',
        price = 4000,
        level = 7,
        description = 'High-performance speedboat',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/speeder.webp'
    },
    {
        name = 'squalo',
        label = 'Squalo',
        model = 'squalo',
        price = 5000,
        level = 8,
        description = 'Premium speedboat',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/squalo.webp'
    },
    {
        name = 'toro',
        label = 'Toro',
        model = 'toro',
        price = 6000,
        level = 9,
        description = 'Luxury speedboat',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/toro.webp'
    },
    {
        name = 'submersible',
        label = 'Submersible',
        model = 'submersible',
        price = 8000,
        level = 10,
        description = 'Ultimate diving vessel',
        image = 'https://cdn.jsdelivr.net/gh/Stuyk/gtav-image-archive/vehicles/submersible.webp'
    }
}